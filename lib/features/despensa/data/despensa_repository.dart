import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/producto.dart';
import 'app_database.dart';

/// Repositorio offline-first:
/// 1. Guarda primero en Drift (local)
/// 2. Intenta sincronizar con Firestore
/// 3. Si falla → syncStatus = pendingSync
/// 4. Al recuperar conexión → reintenta los pendientes
class DespensaRepository {
  DespensaRepository({required this.userId, required this.db});

  final String userId;
  final AppDatabase db;
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users').doc(userId).collection('productos');

  CollectionReference<Map<String, dynamic>> get _recetasCol =>
      _firestore.collection('users').doc(userId).collection('recetas_sugeridas');

  // ── Cargar productos ──────────────────────────────────────────────────────

  /// Carga primero desde Drift. Si está vacío, intenta desde Firestore.
  Future<List<Producto>> cargarProductos() async {
    final locales = await db.obtenerProductos(userId);

    if (locales.isNotEmpty) return locales;

    // Primer arranque: traer de Firestore y guardar local
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

  // ── Guardar producto (offline-first) ──────────────────────────────────────

  /// Guarda local primero. Si hay conexión → sincroniza. Si no → pendingSync.
  Future<Producto> guardar(Producto producto) async {
    // 1. Guardar local con pendingSync
    final pendiente = producto.copyWith(syncStatus: SyncStatus.pendingSync);
    await db.insertarOActualizar(userId, pendiente);

    // 2. Intentar sincronizar con Firestore
    final tieneConexion = await _verificarConexion();
    if (tieneConexion) {
      try {
        await _col.doc(producto.id).set(producto.toMap());
        final sincronizado = producto.copyWith(syncStatus: SyncStatus.synced);
        await db.insertarOActualizar(userId, sincronizado);
        return sincronizado;
      } catch (_) {
        // Firestore falló → queda como pendingSync
        return pendiente;
      }
    }

    // Sin conexión → queda pendingSync
    return pendiente;
  }

  // ── Eliminar producto ─────────────────────────────────────────────────────

  Future<void> eliminar(String id) async {
    await db.eliminarProducto(userId, id);
    try {
      await _col.doc(id).delete();
    } catch (_) {
      // Si Firestore falla, ya fue eliminado local — no es crítico
    }
  }

  // ── Retry: sincronizar pendientes al recuperar conexión ───────────────────

  /// Reintenta subir a Firestore todos los productos con syncStatus = pendingSync.
  /// Llamar este método cuando se detecte reconexión a internet.
  Future<void> sincronizarPendientes() async {
    final pendientes = await db.obtenerPendientes(userId);
    if (pendientes.isEmpty) return;

    final tieneConexion = await _verificarConexion();
    if (!tieneConexion) return;

    for (final producto in pendientes) {
      try {
        await _col.doc(producto.id).set(producto.toMap());
        final sincronizado = producto.copyWith(syncStatus: SyncStatus.synced);
        await db.insertarOActualizar(userId, sincronizado);
      } catch (_) {
        // Si falla un producto, continuar con los demás
        final fallido = producto.copyWith(syncStatus: SyncStatus.failedSync);
        await db.insertarOActualizar(userId, fallido);
      }
    }
  }

  // ── Estadísticas ──────────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> get _statsDoc => _firestore
      .collection('users')
      .doc(userId)
      .collection('estadisticas')
      .doc('resumen');

  Future<int> cargarSalvados() async {
    try {
      final doc = await _statsDoc.get();
      if (!doc.exists) return 0;
      return (doc.data()?['salvados'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> incrementarSalvados() async {
    try {
      await _statsDoc.set({
        'salvados': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (_) {
      // Sin conexión: no es crítico, se reintentará después
    }
  }

  // ── Recetas ───────────────────────────────────────────────────────────────

  Future<void> invalidarRecetasPorIngrediente(String nombreIngrediente) async {
    try {
      final snapshot = await _recetasCol.get();
      if (snapshot.docs.isEmpty) return;

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
    } catch (_) {
      // Sin conexión: no es crítico
    }
  }

  // ── Helper de conectividad ────────────────────────────────────────────────

  Future<bool> _verificarConexion() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (_) {
      return false;
    }
  }
}
