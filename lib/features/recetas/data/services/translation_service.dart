import '../datasources/ai_translation_data_source.dart';

class TranslationService {
  TranslationService({AiTranslationDataSource? translator})
    : _translator = translator ?? AiTranslationDataSource();

  final AiTranslationDataSource _translator;

  String? get lastWarning => _translator.lastWarning;

  void clearWarning() {
    _translator.clearWarning();
  }

  Future<List<String>> translateIngredientsToEnglish(List<String> ingredients) {
    return _translator.translateIngredientsToEnglish(ingredients);
  }

  Future<RecipeSectionsTranslation> translateRecipeSectionsToSpanish({
    List<String> titles = const [],
    List<String> ingredients = const [],
    List<String> instructions = const [],
  }) {
    return _translator.translateRecipeSectionsToSpanish(
      titles: titles,
      ingredients: ingredients,
      instructions: instructions,
    );
  }
}
