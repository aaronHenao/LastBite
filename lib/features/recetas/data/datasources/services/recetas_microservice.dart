import '../recetas_remote_exception.dart';
import 'spoon_microservice.dart';
import 'translation_microservice.dart';

class RecetasService {
  RecetasService({SpoonService? spoon, TranslationService? translation})
    : _spoon = spoon ?? SpoonService(),
      _translation = translation ?? TranslationService();

  static const int maxRecetasPorBusqueda = 3;

  final SpoonService _spoon;
  final TranslationService _translation;

  String? get lastTranslationWarning => _translation.lastWarning;

  Future<List<Map<String, dynamic>>> buscarRecetasPorDespensaRaw({
    required List<String> productosDespensa,
    int number = 3,
    bool ignorePantry = false,
  }) async {
    _translation.clearWarning();
    final numberLimitado = number.clamp(1, maxRecetasPorBusqueda).toInt();

    final ingredientesNormalizados = _normalizarIngredientes(productosDespensa);
    final ingredientes = await _translation.translateIngredientsToEnglish(
      ingredientesNormalizados,
    );

    if (ingredientes.isEmpty) {
      throw const RecetasRemoteException(
        message: 'No hay ingredientes validos en despensa para buscar recetas',
      );
    }

    final raw = await _spoon.findByIngredients(
      ingredients: ingredientes,
      number: numberLimitado,
      ignorePantry: ignorePantry,
      ranking: 1,
    );

    final capped = raw.take(maxRecetasPorBusqueda).toList();
    return _traducirResultadosBusqueda(capped);
  }

  Future<Map<String, dynamic>> obtenerDetalleRecetaRaw({
    required int recetaId,
  }) async {
    _translation.clearWarning();

    final infoData = await _spoon.getRecipeInformation(recipeId: recetaId);
    final translatedInfo = await _traducirInfo(infoData);

    return {
      'information': translatedInfo,
      'equipment': {'equipment': <Map<String, dynamic>>[]},
    };
  }

  Future<List<Map<String, dynamic>>> _traducirResultadosBusqueda(
    List<Map<String, dynamic>> raw,
  ) async {
    if (raw.isEmpty) return raw;

    final titles = raw
        .map((item) => item['title']?.toString() ?? '')
        .where((title) => title.trim().isNotEmpty)
        .toList();

    final ingredientNames = <String>{};

    for (final recipe in raw) {
      for (final key in const ['usedIngredients', 'missedIngredients']) {
        final list = recipe[key];
        if (list is! List) continue;

        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;
          final name = item['name']?.toString() ?? '';
          if (name.trim().isNotEmpty) ingredientNames.add(name);
        }
      }
    }

    final ingredientList = ingredientNames.toList();

    final translatedSections = await _translation
        .translateRecipeSectionsToSpanish(
          titles: titles,
          ingredients: ingredientList,
        );

    final translatedTitles = translatedSections.titles;
    final translatedIngredients = translatedSections.ingredients;

    final ingredientMap = <String, String>{};
    for (var i = 0; i < ingredientList.length; i++) {
      ingredientMap[ingredientList[i]] = translatedIngredients[i];
    }

    final translated = <Map<String, dynamic>>[];
    var titleIndex = 0;

    for (final recipe in raw) {
      final copy = Map<String, dynamic>.from(recipe);

      final originalTitle = copy['title']?.toString() ?? '';
      if (originalTitle.trim().isNotEmpty &&
          titleIndex < translatedTitles.length) {
        copy['title'] = translatedTitles[titleIndex];
        titleIndex++;
      }

      for (final key in const ['usedIngredients', 'missedIngredients']) {
        final list = copy[key];
        if (list is! List) continue;

        copy[key] = list.map((item) {
          if (item is! Map<String, dynamic>) return item;
          final itemCopy = Map<String, dynamic>.from(item);
          final original = itemCopy['name']?.toString() ?? '';
          final translatedName = ingredientMap[original];
          if (translatedName != null && translatedName.trim().isNotEmpty) {
            itemCopy['name'] = translatedName;
          }
          return itemCopy;
        }).toList();
      }

      translated.add(copy);
    }

    return translated;
  }

  Future<Map<String, dynamic>> _traducirInfo(Map<String, dynamic> info) async {
    final copy = Map<String, dynamic>.from(info);

    final title = copy['title']?.toString() ?? '';
    final instructions = copy['instructions']?.toString() ?? '';

    final extendedIngredients = copy['extendedIngredients'];
    final names = extendedIngredients is List
        ? extendedIngredients
              .whereType<Map<String, dynamic>>()
              .map((item) => item['name']?.toString() ?? '')
              .where((name) => name.trim().isNotEmpty)
              .toList()
        : <String>[];

    final translatedSections = await _translation
        .translateRecipeSectionsToSpanish(
          titles: title.trim().isEmpty ? const <String>[] : [title],
          ingredients: names,
          instructions: instructions.trim().isEmpty
              ? const <String>[]
              : [instructions],
        );

    if (translatedSections.titles.isNotEmpty) {
      copy['title'] = translatedSections.titles.first;
    }

    if (translatedSections.instructions.isNotEmpty) {
      final translatedInstructions = translatedSections.instructions.first;
      copy['instructions'] = _esInstruccionPlaceholder(translatedInstructions)
          ? instructions
          : translatedInstructions;
    }

    if (extendedIngredients is List && extendedIngredients.isNotEmpty) {
      var idx = 0;
      copy['extendedIngredients'] = extendedIngredients.map((item) {
        if (item is! Map<String, dynamic>) return item;
        final itemCopy = Map<String, dynamic>.from(item);
        final originalName = itemCopy['name']?.toString() ?? '';
        if (originalName.trim().isNotEmpty &&
            idx < translatedSections.ingredients.length) {
          itemCopy['name'] = translatedSections.ingredients[idx];
          idx++;
        }
        return itemCopy;
      }).toList();
    }

    return copy;
  }

  List<String> _normalizarIngredientes(List<String> productosDespensa) {
    return productosDespensa
        .map((producto) => producto.trim().toLowerCase())
        .where((producto) => producto.isNotEmpty)
        .toSet()
        .toList();
  }

  bool _esInstruccionPlaceholder(String texto) {
    final t = texto.toLowerCase().trim();
    return t.contains('interfaz de la app') ||
        t == 'instrucciones de la receta para la interfaz de la app' ||
        t == 'recipe instructions for app ui';
  }
}
