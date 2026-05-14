import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/alerta.dart';

class AlertasRepository {
  AlertasRepository({required this.userId});

  final String userId;
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(userId).collection('alertas');

  Future<List<Alerta>> cargarAlertas() async {
    final snapshot = await _col.get();
    return snapshot.docs.map((doc) => Alerta.fromMap(doc.data())).toList();
  }

  Future<void> guardarAlerta(Alerta alerta) async {
    await _col.doc(alerta.id).set(alerta.toMap());
  }

  Future<void> eliminarAlerta(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> eliminarTodas() async {
    final snapshot = await _col.get();
    if (snapshot.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
