import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lastbite/core/data/despensa_ref.dart';

import '../domain/despensa_compartida.dart';

/// Por que no se pudo hacer algo con la despensa compartida.
enum ErrorCompartida {
  largoCodigo,
  codigoInexistente,
  noExiste,
  unicoMiembro,
  elegirAdmin,
  adminInvalido,
  soloAdminMiembros,
  adminNoSeElimina,
  soloAdminEliminar,
  yaPerteneces,
  sinCodigo,
  sinSesion,
}

/// Error de dominio de la despensa compartida. Lleva el motivo, no la frase:
/// la pantalla la pone en el idioma activo.
class DespensaCompartidaException implements Exception {
  DespensaCompartidaException(this.motivo);
  final ErrorCompartida motivo;

  @override
  String toString() => 'DespensaCompartidaException(${motivo.name})';
}

class DespensaCompartidaRepository {
  DespensaCompartidaRepository();

  final _db = FirebaseFirestore.instance;

  // Sin 0/O/1/I para que el codigo se dicte sin confusiones.
  static const _alfabeto = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const largoCodigo = 6;
  static const _subcolecciones = [
    'productos',
    'alertas',
    'recetas_sugeridas',
    'estadisticas',
  ];

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(coleccionDespensasCompartidas);

  /// Indice codigo -> despensa. Existe para que unirse sea un `get` directo:
  /// buscar por consulta obligaria a abrir la lectura de todas las despensas.
  CollectionReference<Map<String, dynamic>> get _codigos =>
      _db.collection(coleccionCodigosDespensa);

  // consultas

  /// Id de la despensa compartida en la que esta el usuario, o null si esta
  /// en su despensa personal.
  Stream<String?> idCompartidaStream(String userId) => docUsuario(userId)
      .snapshots()
      .map((doc) => _idValido(doc.data()?['despensaCompartidaId']));

  Future<String?> idCompartidaDe(String userId) async {
    final doc = await docUsuario(userId).get();
    return _idValido(doc.data()?['despensaCompartidaId']);
  }

  String? _idValido(Object? raw) {
    final id = raw?.toString().trim();
    return (id == null || id.isEmpty) ? null : id;
  }

  Stream<DespensaCompartida?> despensaStream(String despensaId) => _col
      .doc(despensaId)
      .snapshots()
      .map((doc) {
        final data = doc.data();
        if (!doc.exists || data == null) return null;
        return DespensaCompartida.fromMap({...data, 'id': doc.id});
      })
      // Al salir o ser expulsado se pierde el permiso sobre el documento:
      // eso no es un error que mostrar, es quedarse sin despensa.
      .handleError(
        (Object _) {},
        test: (e) => e is FirebaseException && e.code == 'permission-denied',
      );

  Future<DespensaCompartida?> cargar(String despensaId) async {
    final doc = await _col.doc(despensaId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return DespensaCompartida.fromMap({...data, 'id': doc.id});
  }

  /// Resuelve un codigo sin unirse todavia. La pantalla lo usa para validar
  /// antes de preguntar por la migracion: preguntar primero hacia que el
  /// usuario decidiera sobre sus productos para una despensa inexistente.
  Future<String?> buscarPorCodigo(String codigo) async {
    final normalizado = _normalizarCodigo(codigo);
    if (normalizado.length != largoCodigo) return null;
    final indice = await _codigos.doc(normalizado).get();
    return indice.data()?['despensaId'] as String?;
  }

  static String _normalizarCodigo(String codigo) =>
      codigo.replaceAll(RegExp(r'\s'), '').toUpperCase();

  Future<int> contarProductosPersonales(String userId) async {
    final snapshot = await docUsuario(userId).collection('productos').get();
    return snapshot.docs.length;
  }

  // creacion y membresia

  Future<DespensaCompartida> crear({
    required String nombre,
    required MiembroDespensa admin,
  }) async {
    await _verificarSinDespensa(admin.uid);

    final codigo = await _generarCodigoUnico();
    final ref = _col.doc();
    final despensa = DespensaCompartida(
      id: ref.id,
      nombre: nombre.trim(),
      codigo: codigo,
      adminUid: admin.uid,
      creadaEn: DateTime.now(),
      miembros: [admin],
    );

    final batch = _db.batch();
    batch.set(ref, despensa.toMap());
    batch.set(_codigos.doc(codigo), {
      'despensaId': ref.id,
      'creadoEn': DateTime.now().toIso8601String(),
    });
    await batch.commit();

    await _apuntarUsuarioA(admin.uid, ref.id);
    return despensa;
  }

  Future<DespensaCompartida> unirsePorCodigo({
    required String codigo,
    required MiembroDespensa usuario,
  }) async {
    await _verificarSinDespensa(usuario.uid);

    final normalizado = _normalizarCodigo(codigo);
    if (normalizado.length != largoCodigo) {
      throw DespensaCompartidaException(ErrorCompartida.largoCodigo);
    }

    final indice = await _codigos.doc(normalizado).get();
    final despensaId = indice.data()?['despensaId'] as String?;
    if (!indice.exists || despensaId == null) {
      throw DespensaCompartidaException(ErrorCompartida.codigoInexistente);
    }

    await _col.doc(despensaId).update({
      'miembrosUids': FieldValue.arrayUnion([usuario.uid]),
      'miembros.${usuario.uid}': usuario.toMap(),
    });
    await _apuntarUsuarioA(usuario.uid, despensaId);

    final actualizada = await cargar(despensaId);
    if (actualizada == null) {
      throw DespensaCompartidaException(ErrorCompartida.noExiste);
    }
    return actualizada;
  }

  /// Mueve los productos de la despensa personal a la compartida. Los
  /// productos personales quedan eliminados: viven ahora en la compartida.
  Future<int> migrarProductosPersonales({
    required String userId,
    required String despensaId,
  }) async {
    final personales = await docUsuario(userId).collection('productos').get();
    if (personales.docs.isEmpty) return 0;

    final destino = _col.doc(despensaId).collection('productos');
    await _enBatches(personales.docs, (batch, doc) {
      batch.set(destino.doc(doc.id), doc.data());
      batch.delete(doc.reference);
    }, docsPorBatch: _docsPorBatchCompartida);
    return personales.docs.length;
  }

  /// Un miembro deja la despensa y vuelve a la suya personal. Los productos
  /// que aporto se quedan en la compartida.
  ///
  /// El administrador tambien puede salir, pero antes tiene que pasarle la
  /// administracion a otro miembro con [nuevoAdminUid]: una despensa sin admin
  /// no tendria quien agregue ni saque gente.
  Future<void> salir({
    required String despensaId,
    required String userId,
    String? nuevoAdminUid,
  }) async {
    final despensa = await cargar(despensaId);
    if (despensa == null) {
      throw DespensaCompartidaException(ErrorCompartida.noExiste);
    }

    if (despensa.esAdmin(userId)) {
      if (despensa.miembros.length == 1) {
        throw DespensaCompartidaException(ErrorCompartida.unicoMiembro);
      }
      if (nuevoAdminUid == null) {
        throw DespensaCompartidaException(ErrorCompartida.elegirAdmin);
      }
      if (nuevoAdminUid == userId || despensa.miembro(nuevoAdminUid) == null) {
        throw DespensaCompartidaException(ErrorCompartida.adminInvalido);
      }
      // Primero la transferencia, todavia como admin; despues la salida, que
      // las reglas permiten porque cada quien puede quitarse a si mismo.
      await _col.doc(despensaId).update({'adminUid': nuevoAdminUid});
    }

    await _quitarMiembro(despensaId: despensaId, userId: userId);
  }

  /// Solo el admin expulsa miembros.
  Future<void> expulsar({
    required String despensaId,
    required String adminUid,
    required String userId,
  }) async {
    final despensa = await cargar(despensaId);
    if (despensa == null) {
      throw DespensaCompartidaException(ErrorCompartida.noExiste);
    }
    if (!despensa.esAdmin(adminUid)) {
      throw DespensaCompartidaException(ErrorCompartida.soloAdminMiembros);
    }
    if (userId == adminUid) {
      throw DespensaCompartidaException(ErrorCompartida.adminNoSeElimina);
    }
    await _quitarMiembro(despensaId: despensaId, userId: userId);
  }

  /// Solo el admin elimina la despensa. Los productos compartidos pasan a su
  /// despensa personal para no perderlos, y todos los miembros quedan libres.
  Future<void> eliminar({
    required String despensaId,
    required String adminUid,
  }) async {
    final despensa = await cargar(despensaId);
    if (despensa == null) {
      throw DespensaCompartidaException(ErrorCompartida.noExiste);
    }
    if (!despensa.esAdmin(adminUid)) {
      throw DespensaCompartidaException(ErrorCompartida.soloAdminEliminar);
    }

    final ref = _col.doc(despensaId);

    // Los productos compartidos se devuelven al admin.
    final productos = await ref.collection('productos').get();
    if (productos.docs.isNotEmpty) {
      final destino = docUsuario(adminUid).collection('productos');
      await _enBatches(
        productos.docs,
        (batch, doc) => batch.set(destino.doc(doc.id), doc.data()),
        docsPorBatch: _docsPorBatchPersonal,
      );
    }

    for (final miembro in despensa.miembros) {
      await _apuntarUsuarioA(miembro.uid, null);
    }

    for (final sub in _subcolecciones) {
      final snapshot = await ref.collection(sub).get();
      if (snapshot.docs.isEmpty) continue;
      await _enBatches(
        snapshot.docs,
        (batch, doc) => batch.delete(doc.reference),
        docsPorBatch: _docsPorBatchCompartida,
      );
    }

    if (despensa.codigo.isNotEmpty) {
      await _codigos.doc(despensa.codigo).delete();
    }
    await ref.delete();
  }

  // helpers

  /// Lote para escrituras en la despensa personal: solo topa con el limite de
  /// 500 operaciones por batch.
  static const _docsPorBatchPersonal = 250;

  /// Lote para escrituras dentro de la despensa compartida. Sus reglas hacen
  /// una busqueda por documento y Firestore corta en 20 por request, asi que
  /// el lote va muy por debajo de ese techo.
  static const _docsPorBatchCompartida = 10;

  Future<void> _enBatches(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    void Function(
      WriteBatch batch,
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
    )
    operacion, {
    required int docsPorBatch,
  }) async {
    for (var i = 0; i < docs.length; i += docsPorBatch) {
      final batch = _db.batch();
      for (final doc in docs.skip(i).take(docsPorBatch)) {
        operacion(batch, doc);
      }
      await batch.commit();
    }
  }

  Future<void> _quitarMiembro({
    required String despensaId,
    required String userId,
  }) async {
    await _col.doc(despensaId).update({
      'miembrosUids': FieldValue.arrayRemove([userId]),
      'miembros.$userId': FieldValue.delete(),
    });
    await _apuntarUsuarioA(userId, null);
  }

  Future<void> _verificarSinDespensa(String userId) async {
    final actual = await idCompartidaDe(userId);
    if (actual != null) {
      throw DespensaCompartidaException(ErrorCompartida.yaPerteneces);
    }
  }

  Future<void> _apuntarUsuarioA(String userId, String? despensaId) async {
    await docUsuario(userId).set({
      'despensaCompartidaId': despensaId,
    }, SetOptions(merge: true));
  }

  Future<String> _generarCodigoUnico() async {
    final random = Random.secure();
    for (var intento = 0; intento < 8; intento++) {
      final codigo = List.generate(
        largoCodigo,
        (_) => _alfabeto[random.nextInt(_alfabeto.length)],
      ).join();

      final existe = await _codigos.doc(codigo).get();
      if (!existe.exists) return codigo;
    }
    throw DespensaCompartidaException(ErrorCompartida.sinCodigo);
  }
}
