import '../datasources/ai_translation_data_source.dart';

class TranslationService {
  TranslationService({AiTranslationDataSource? translator})
    : _translator = translator ?? AiTranslationDataSource();

  final AiTranslationDataSource _translator;

  static final Map<String, String> _cache = {};
  static final Map<String, Future<String>> _inFlightText = {};
  static final Map<String, Future<List<String>>> _inFlightList = {};

  String? get lastWarning => _translator.lastWarning;

  void clearWarning() {
    _translator.clearWarning();
  }

  Future<List<String>> translateIngredientsToEnglish(List<String> ingredients) {
    if (ingredients.isEmpty) return Future.value(ingredients);

    final trimmed = ingredients.map((item) => item.trim()).toList();
    final allCached = trimmed.every(
      (item) => _cache.containsKey(_cacheKey('es-en', item)),
    );

    if (allCached) {
      return Future.value(
        trimmed.map((item) => _cache[_cacheKey('es-en', item)] ?? item)
            .toList(),
      );
    }

    final listKey = _cacheKey('es-en-list', trimmed.join('|'));
    final inFlight = _inFlightList[listKey];
    if (inFlight != null) return inFlight;

    final future = _translator
        .translateIngredientsToEnglish(trimmed)
        .then((translated) {
          if (translated.length != trimmed.length) {
            _inFlightList.remove(listKey);
            return trimmed;
          }

          for (var i = 0; i < trimmed.length; i++) {
            final original = trimmed[i];
            final result = translated[i].trim().isEmpty
                ? original
                : translated[i];
            _cache[_cacheKey('es-en', original)] = result;
          }
          _inFlightList.remove(listKey);
          return translated;
        })
        .catchError((_) {
          _inFlightList.remove(listKey);
          return trimmed;
        });

    _inFlightList[listKey] = future;
    return future;
  }

  Future<String> translateRecipeTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return Future.value(title);

    final cacheKey = _cacheKey('title', trimmed);
    final cached = _cache[cacheKey];
    if (cached != null) return Future.value(cached);

    final inFlight = _inFlightText[cacheKey];
    if (inFlight != null) return inFlight;

    final future = _translator
        .translateTextToSpanish(
          trimmed,
          context: 'recipe title for app UI',
        )
        .then((translated) {
          final result = translated.trim().isEmpty ? trimmed : translated;
          _cache[cacheKey] = result;
          _inFlightText.remove(cacheKey);
          return result;
        })
        .catchError((_) {
          _inFlightText.remove(cacheKey);
          return trimmed;
        });

    _inFlightText[cacheKey] = future;
    return future;
  }

  Future<List<String>> translateIngredients(List<String> ingredients) {
    if (ingredients.isEmpty) return Future.value(ingredients);

    final trimmed = ingredients.map((item) => item.trim()).toList();
    final cacheKey = _cacheKey('ingredients', trimmed.join('|'));

    final allCached = trimmed.every(
      (item) => _cache.containsKey(_cacheKey('ingredient', item)),
    );

    if (allCached) {
      return Future.value(
        trimmed.map((item) => _cache[_cacheKey('ingredient', item)] ?? item)
            .toList(),
      );
    }

    final inFlight = _inFlightList[cacheKey];
    if (inFlight != null) return inFlight;

    final future = _translator
        .translateTermsToSpanish(
          trimmed,
          context: 'recipe ingredients for app UI',
        )
        .then((translated) {
          if (translated.length != trimmed.length) {
            _inFlightList.remove(cacheKey);
            return trimmed;
          }

          for (var i = 0; i < trimmed.length; i++) {
            final original = trimmed[i];
            final result = translated[i].trim().isEmpty
                ? original
                : translated[i];
            _cache[_cacheKey('ingredient', original)] = result;
          }
          _inFlightList.remove(cacheKey);
          return translated;
        })
        .catchError((_) {
          _inFlightList.remove(cacheKey);
          return trimmed;
        });

    _inFlightList[cacheKey] = future;
    return future;
  }

  Future<String> translateInstructions(String instructions) {
    final trimmed = instructions.trim();
    if (trimmed.isEmpty) return Future.value(instructions);

    final cacheKey = _cacheKey('instruction', trimmed);
    final cached = _cache[cacheKey];
    if (cached != null) return Future.value(cached);

    final inFlight = _inFlightText[cacheKey];
    if (inFlight != null) return inFlight;

    final future = _translator
        .translateTextToSpanish(
          trimmed,
          context: 'recipe instructions for app UI',
        )
        .then((translated) {
          final result = translated.trim().isEmpty ? trimmed : translated;
          _cache[cacheKey] = result;
          _inFlightText.remove(cacheKey);
          return result;
        })
        .catchError((_) {
          _inFlightText.remove(cacheKey);
          return trimmed;
        });

    _inFlightText[cacheKey] = future;
    return future;
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

  static String _cacheKey(String prefix, String value) {
    return '$prefix::$value';
  }
}
