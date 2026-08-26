import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/perfil_nutricional.dart';

class PerfilNutricionalRepository {
  PerfilNutricionalRepository({required this.userId});

  final String userId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _doc => _db
      .collection('users')
      .doc(userId)
      .collection('perfil_nutricional')
      .doc('configuracion');

  Future<PerfilNutricional?> cargar() async {
    final snapshot = await _doc.get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return PerfilNutricional.fromMap(snapshot.data()!);
  }

  Future<void> guardar(PerfilNutricional perfil) async {
    await _doc.set({
      ...perfil.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
