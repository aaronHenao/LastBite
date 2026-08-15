import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/item_compra.dart';

class ListaComprasRepository {
  ListaComprasRepository({required this.userId});

  final String userId;
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(userId).collection('lista_compras');

  Future<List<ItemCompra>> cargar() async {
    final snapshot = await _col.orderBy('agregadoEn', descending: false).get();
    return snapshot.docs
        .map((doc) => ItemCompra.fromMap(doc.data()))
        .toList();
  }

  //solo si ya no está el producto en la lista, lo agrega
  Future<void> agregarSiNoExiste(ItemCompra item) async {
    final existing = await _col
        .where('nombre', isEqualTo: item.nombre)
        .where('comprado', isEqualTo: false)
        .get();

    if (existing.docs.isNotEmpty) return;

    await _col.doc(item.id).set(item.toMap());
  }

  Future<void> marcarComprado(String id, bool comprado) async {
    await _col.doc(id).update({'comprado': comprado});
  }

  //solo los marcados como comprados son eliminados
  Future<void> limpiarComprados() async {
    final snapshot = await _col.where('comprado', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> eliminar(String id) async {
    await _col.doc(id).delete();
  }
}