import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/producto.dart';

class DespensaRepository {
  DespensaRepository({required this.userId});

  final String userId;
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users').doc(userId).collection('productos');

  CollectionReference<Map<String, dynamic>> get _recetasCol =>
      _firestore.collection('users').doc(userId).collection('recetas_sugeridas');

  Future<List<Producto>> cargarProductos() async {
    final snapshot = await _col.get();
    return snapshot.docs.map((doc) => Producto.fromMap(doc.data())).toList();
  }

  Future<void> guardar(Producto producto) async {
    await _col.doc(producto.id).set(producto.toMap());
  }

  Future<void> eliminar(String id) async {
    await _col.doc(id).delete();
  }

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
    await _statsDoc.set({
      'salvados': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<void> invalidarRecetasPorIngrediente(String nombreIngrediente) async {
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
  }

  Future<bool> _verificarConexion() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  Future<void> sincronizarPendientes() async {
    await _verificarConexion();
  }
}
