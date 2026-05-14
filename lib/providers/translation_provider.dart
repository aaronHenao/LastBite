import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/services/translation_service.dart';

/// Instancia del servicio de traducción (Together AI).
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

/// Traduce título de receta EN→ES. Parámetro: título en inglés.
final recipeTitleProvider = FutureProvider.family<String, String>(
  (ref, title) async {
    final service = ref.read(translationServiceProvider);
    return service.translateRecipeTitle(title);
  },
);

/// Traduce lista de ingredientes EN→ES en una sola llamada.
/// Parámetro: `jsonEncode(lista)` (clave estable para Riverpod family).
final recipeIngredientsProvider = FutureProvider.family<List<String>, String>(
  (ref, ingredientsJson) async {
    final service = ref.read(translationServiceProvider);
    final raw = jsonDecode(ingredientsJson) as List<dynamic>;
    final items = raw.map((e) => e.toString()).toList();
    return service.translateIngredients(items);
  },
);

/// Traduce instrucciones EN→ES (pantalla de detalle).
final recipeInstructionsProvider = FutureProvider.family<String, String>(
  (ref, instructions) async {
    final service = ref.read(translationServiceProvider);
    return service.translateInstructions(instructions);
  },
);
