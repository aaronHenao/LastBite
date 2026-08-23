import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/features/recetas/data/models/receta_busqueda_remote_model.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';

void main() {
  group('Receta round-trip por el cache', () {
    test('dishTypes sobrevive a toMap/fromMap', () {
      final original = Receta(
        id: 641836,
        titulo: 'Easy Baked Parmesan Chicken',
        imagenUrl: 'https://img.spoonacular.com/recipes/641836-312x231.jpg',
        ingredientesUsados: 2,
        ingredientesFaltantes: 1,
        likes: 3,
        minutosPreparacion: 45,
        // dishTypes reales que devolvio Spoonacular para esta receta.
        dishTypes: const ['lunch', 'main course', 'main dish', 'dinner'],
      );

      final revivida = Receta.fromMap(original.toMap());

      expect(revivida.dishTypes, original.dishTypes);
      expect(revivida.minutosPreparacion, 45);
      expect(revivida.id, 641836);
    });

    test('una receta sin dishTypes no rompe el round-trip', () {
      // 1 de las 30 recetas reales vino con dishTypes vacio.
      final original = Receta(
        id: 1,
        titulo: 'sin tipos',
        imagenUrl: '',
        ingredientesUsados: 1,
        ingredientesFaltantes: 1,
        likes: 0,
      );

      final revivida = Receta.fromMap(original.toMap());

      expect(revivida.dishTypes, isNull);
      expect(revivida.titulo, 'sin tipos');
    });

    test('un documento viejo, sin la clave dishTypes, se lee como null', () {
      // Asi luce un doc guardado antes de la v2 del cache.
      final docViejo = <String, dynamic>{
        'id': 665573,
        'titulo': 'Pudin de Yokshire',
        'imagenUrl': '',
        'ingredientesUsados': 2,
        'ingredientesFaltantes': 3,
        'likes': 1,
        'minutosPreparacion': 45,
      };

      final receta = Receta.fromMap(docViejo);

      expect(receta.dishTypes, isNull);
      expect(receta.minutosPreparacion, 45);
    });
  });

  group('RecetaBusquedaRemoteModel', () {
    test('lee dishTypes del json enriquecido con informationBulk', () {
      final json = <String, dynamic>{
        'id': 649985,
        'title': 'Light and Chunky Chicken Soup',
        'image': '',
        'usedIngredientCount': 2,
        'missedIngredientCount': 2,
        'likes': 0,
        'readyInMinutes': 45,
        'dishTypes': ['lunch', 'soup', 'main course', 'main dish', 'dinner'],
      };

      final model = RecetaBusquedaRemoteModel.fromJson(json);

      expect(model.dishTypes, contains('soup'));
      expect(model.minutosPreparacion, 45);
      expect(model.toDomain().dishTypes, model.dishTypes);
    });

    test('si informationBulk fallo, dishTypes queda null y no rompe', () {
      final json = <String, dynamic>{
        'id': 1,
        'title': 'sin enriquecer',
        'image': '',
        'usedIngredientCount': 1,
        'missedIngredientCount': 1,
        'likes': 0,
      };

      final model = RecetaBusquedaRemoteModel.fromJson(json);

      expect(model.dishTypes, isNull);
      expect(model.minutosPreparacion, isNull);
      expect(model.toDomain().dishTypes, isNull);
    });
  });
}
