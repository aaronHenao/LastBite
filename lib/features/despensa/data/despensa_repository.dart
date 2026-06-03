import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/producto.dart';

class DespensaRepository {
  DespensaRepository({required this.userId});

  final String userId;
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(userId).collection('productos');

  CollectionReference<Map<String, dynamic>> get _recetasCol =>
      _db.collection('users').doc(userId).collection('recetas_sugeridas');

  Future<void> invalidarRecetasPorIngrediente(String nombreIngrediente) async {
    final snapshot = await _recetasCol.get();
    if (snapshot.docs.isEmpty) return;

    final batch = _db.batch();
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

  DocumentReference<Map<String, dynamic>> get _notifDoc => _db
      .collection('users')
      .doc(userId)
      .collection('estadisticas')
      .doc('notificaciones');

  Future<bool> debeEnviarNotificaciones() async {
    final doc = await _notifDoc.get();
    if (!doc.exists) return true;

    final raw = doc.data()?['ultimoEnvio']?.toString();
    if (raw == null) return true;

    final ultimo = DateTime.tryParse(raw);
    if (ultimo == null) return true;

    return DateTime.now().difference(ultimo).inHours >= 23;
  }

  Future<void> registrarEnvioNotificaciones() async {
    await _notifDoc.set({
      'ultimoEnvio': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}
