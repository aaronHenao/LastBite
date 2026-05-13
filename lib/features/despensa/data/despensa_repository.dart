import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/producto.dart';

class DespensaRepository {
  DespensaRepository({required this.userId});

  final String userId;
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(userId).collection('productos');

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

  DocumentReference<Map<String, dynamic>> get _statsDoc => _db
      .collection('users')
      .doc(userId)
      .collection('estadisticas')
      .doc('resumen');

  Future<int> cargarSalvados() async {
    final doc = await _statsDoc.get();
    if (!doc.exists) return 0;
    return (doc.data()?['salvados'] as int?) ?? 0;
  }

  Future<void> incrementarSalvados() async {
    await _statsDoc.set({
      'salvados': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }
}
