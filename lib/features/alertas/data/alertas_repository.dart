import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import '../domain/alerta.dart';
import 'package:lastbite/core/data/despensa_ref.dart';

class AlertasRepository {
  AlertasRepository({required this.userId, this.despensaCompartidaId});

  final String userId;

  /// Si no es null, el repositorio opera sobre la despensa compartida
  /// en vez de la despensa personal del usuario.
  final String? despensaCompartidaId;

  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _raiz => raizDespensa(
    userId: userId,
    despensaCompartidaId: despensaCompartidaId,
  );

  CollectionReference<Map<String, dynamic>> get _productosCol =>
      _raiz.collection('productos');

  CollectionReference<Map<String, dynamic>> get _alertasCol =>
      _raiz.collection('alertas');

  /// Documento de versiones anteriores (guardaba `lastClearAt`). Ya no se
  /// usa, pero puede existir en Firestore y no es una alerta.
  DocumentReference<Map<String, dynamic>> get _metaDoc => _alertasCol.doc('_meta');

  Future<List<Producto>> cargarProductos() async {
    final snapshot = await _productosCol.get();
    return snapshot.docs.map((doc) => Producto.fromMap(doc.data())).toList();
  }

  Future<List<Alerta>> cargarAlertas() async {
    final snapshot = await _alertasCol.get();
    return snapshot.docs
        .where((doc) => doc.id != _metaDoc.id)
        .map((doc) => Alerta.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> guardarAlertas(List<Alerta> alertas) async {
    if (alertas.isEmpty) return;

    final batch = _db.batch();
    for (final alerta in alertas) {
      batch.set(_alertasCol.doc(alerta.id), alerta.toMap());
    }
    await batch.commit();
  }

  Future<void> marcarAlertaBorrada(String id, DateTime momento) async {
    await _alertasCol.doc(id).set({
      'dismissedAt': momento.toIso8601String(),
    }, SetOptions(merge: true));
  }

  /// Deshace un descarte: la alerta vuelve a mostrarse.
  Future<void> restaurarAlerta(String id) async {
    await _alertasCol.doc(id).set({
      'dismissedAt': null,
    }, SetOptions(merge: true));
  }

  /// "Borrar todo": descarta las alertas visibles en vez de borrar los
  /// documentos. Asi esas mismas no vuelven a crearse, pero las de productos
  /// nuevos o de un umbral nuevo si aparecen.
  Future<void> borrarTodasAlertas(DateTime momento) async {
    final snapshot = await _alertasCol.get();
    final visibles = snapshot.docs
        .where((doc) => doc.id != _metaDoc.id)
        .where((doc) => doc.data()['dismissedAt'] == null)
        .toList();

    // En la despensa compartida cada escritura evalua una regla que lee otro
    // documento y Firestore corta en 20 lecturas por request.
    final porLote = despensaCompartidaId == null ? 400 : 10;
    for (var i = 0; i < visibles.length; i += porLote) {
      final batch = _db.batch();
      for (final doc in visibles.skip(i).take(porLote)) {
        batch.set(doc.reference, {
          'dismissedAt': momento.toIso8601String(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
    }
  }
}
