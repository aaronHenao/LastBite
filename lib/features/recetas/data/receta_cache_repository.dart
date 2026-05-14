import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/receta.dart';

class RecetaCacheRepository {
  RecetaCacheRepository({required this.userId});

  final String userId;
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(userId).collection('recetas_sugeridas');

  //carga recetas del caché
  Future<List<Receta>> cargarRecetas() async {
    final snapshot = await _col.get();
    if (snapshot.docs.isEmpty) return [];
    return snapshot.docs.map((doc) => Receta.fromMap(doc.data())).toList();
  }

  //guarda lista de recetas — reemplaza todo el caché
  Future<void> guardarRecetas({
    required List<Receta> recetas,
    required List<String> ingredientesUrgentes,
  }) async {
    
    try {
      final batch = _db.batch();

      final existing = await _col.get();
      
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      for (final receta in recetas) {
        final ref = _col.doc(receta.id.toString());
        final map = receta.toMap(
          ingredientesUrgentesUsados: ingredientesUrgentes,
        );
        batch.set(ref, map);
      }

      await batch.commit();
      
    } catch (e) {
      print('❌ Error guardando en Firestore: $e');
    }
  }

  //borra recetas que usen un ingrediente urgente específico
  Future<void> invalidarPorIngrediente(String nombreIngrediente) async {
    final snapshot = await _col.get();
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

  //verifica si el caché es válido para los ingredientes actuales
  Future<bool> cacheEsValido(List<String> ingredientesUrgentesActuales) async {
    final snapshot = await _col.get();
    
    if (snapshot.docs.isEmpty) return false;

    // Obtiene todos los ingredientes urgentes guardados en el caché
    final ingredientesEnCache = <String>{};
    for (final doc in snapshot.docs) {
      final urgentes =
          (doc.data()['ingredientesUrgentesUsados'] as List?)
              ?.map((e) => e.toString().toLowerCase().trim())
              .toList() ??
          [];
      ingredientesEnCache.addAll(urgentes);
    }

    final actualesNorm = ingredientesUrgentesActuales
        .map((e) => e.toLowerCase().trim())
        .toSet();

    //el caché es válido si los ingredientes urgentes no cambiaron
    return ingredientesEnCache.containsAll(actualesNorm) &&
        actualesNorm.containsAll(ingredientesEnCache);
  }
}
