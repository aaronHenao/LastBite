import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/producto.dart';
import 'app_database.dart';

class DespensaRepository {
  DespensaRepository({required this.userId, required this.db});

  final String userId;
  final AppDatabase db;
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users').doc(userId).collection('productos');

  CollectionReference<Map<String, dynamic>> get _recetasCol =>
      _firestore.collection('users').doc(userId).collection('recetas_sugeridas');

  DocumentReference<Map<String, dynamic>> get _statsDoc => _firestore
      .collection('users')
      .doc(userId)
      .collection('estadisticas')
      .doc('resumen');

  DocumentReference<Map<String, dynamic>> get _notifDoc => _firestore
      .collection('users')
      .doc(userId)
      .collection('estadisticas')
      .doc('notificaciones');

  /// Carga desde DB local primero; si está vacía, baja de Firestore y cachea.
  Future<List<Producto>> cargarProductos() async {
    final locales = await db.obtenerProductos(userId);

    if (locales.isNotEmpty) {
      return locales;
    }


    // Primera carga: bajar de Firestore y guardar local
    try {
      final snapshot = await _col.get();

      final remotos = snapshot.docs
          .map((doc) => Producto.fromMap(doc.data()))
          .toList();

      for (final p in remotos) {
        await db.insertarOActualizar(userId, p);
      }

      return remotos;
    } catch (_) {
      return [];
    }
  }

  /// Guarda localmente siempre. Si hay conexión, también sube a Firestore.
  Future<void> guardar(Producto producto) async {
    await db.insertarOActualizar(userId, producto);

    if (producto.syncStatus == SyncStatus.synced) {
      await _col.doc(producto.id).set(producto.toMap());
    }
  }

  Future<void> eliminar(String id) async {
    await db.eliminarProducto(userId, id);

    try {
      await _col.doc(id).delete();
    } catch (_) {
      // Si falla, queda pendingSync para el próximo intento
    }
  }

  /// Sube los pendientes a Firestore y los marca como sincronizados.
  Future<void> sincronizarPendientes() async {
    final pendientes = await db.obtenerPendientes(userId);

    for (final producto in pendientes) {
      try {
        final sincronizado = producto.copyWith(
          syncStatus: SyncStatus.synced,
        );

        await _col.doc(producto.id).set(sincronizado.toMap());

        await db.insertarOActualizar(userId, sincronizado);
      } catch (_) {
        // Se intentará nuevamente más adelante
      }
    }
  }

  Future<int> cargarSalvados() async {
    try {
      final doc = await _statsDoc.get();

      if (!doc.exists) {
        return 0;
      }

      return (doc.data()?['salvados'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> incrementarSalvados() async {
    await _statsDoc.set({
      'salvados': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Borra recetas cacheadas que usaban un ingrediente modificado/eliminado.
  Future<void> invalidarRecetasPorIngrediente(
    String nombreIngrediente,
  ) async {
    final snapshot = await _recetasCol.get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    final nombreNorm = nombreIngrediente.toLowerCase().trim();

    for (final doc in snapshot.docs) {
      final urgentes =
          (doc.data()['ingredientesUrgentesUsados'] as List?)
              ?.map((e) => e.toString().toLowerCase().trim())
              .toList() ??
          [];

      if (urgentes.contains(nombreNorm)) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
  }

  /// Controla que no se envíen notificaciones más de una vez cada ~24h.
  Future<bool> debeEnviarNotificaciones() async {
    try {
      final doc = await _notifDoc.get();

      if (!doc.exists) {
        return true;
      }

      final raw = doc.data()?['ultimoEnvio']?.toString();

      if (raw == null) {
        return true;
      }

      final ultimo = DateTime.tryParse(raw);

      if (ultimo == null) {
        return true;
      }

      return DateTime.now().difference(ultimo).inHours >= 23;
    } catch (_) {
      return true;
    }
  }

  Future<void> registrarEnvioNotificaciones() async {
    try {
      await _notifDoc.set({
        'ultimoEnvio': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}