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

  Future<DateTime?> cargarUltimoBorrado() async {
    final doc = await _metaDoc.get();
    if (!doc.exists) return null;

    final data = doc.data();
    final raw = data?['lastClearAt']?.toString();
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw);
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

  Future<void> borrarTodasAlertas(DateTime momento) async {
    final snapshot = await _alertasCol.get();
    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      if (doc.id == _metaDoc.id) continue;
      batch.delete(doc.reference);
    }

    await batch.commit();
    await _metaDoc.set({
      'lastClearAt': momento.toIso8601String(),
    }, SetOptions(merge: true));
  }
}
