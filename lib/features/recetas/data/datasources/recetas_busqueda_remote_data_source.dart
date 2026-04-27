import 'package:dio/dio.dart';

import 'ai_translation_data_source.dart';
import 'recetas_remote_exception.dart';

const String _recipesBaseUrl = 'https://api.spoonacular.com/recipes';
const int _maxRecetasPorBusqueda = 3;

class RecetasBusquedaRemoteDataSource {
  RecetasBusquedaRemoteDataSource({
    Dio? dio,
    String? apiKey,
    AiTranslationDataSource? translator,
  }) : _dio = dio ?? Dio(),
       _apiKey = apiKey ?? const String.fromEnvironment('SPOONACULAR_API_KEY'),
       _translator = translator ?? AiTranslationDataSource();

  final Dio _dio;
  final String _apiKey;
  final AiTranslationDataSource _translator;

  String? get lastTranslationWarning => _translator.lastWarning;

  Future<List<Map<String, dynamic>>> buscarRecetasPorDespensaRaw({
    required List<String> productosDespensa,
    int number = 3,
    bool ignorePantry = false,
  }) async {
    _validarApiKey();
    _translator.clearWarning();
    final numberLimitado = number.clamp(1, _maxRecetasPorBusqueda).toInt();

    final ingredientesNormalizados = _normalizarIngredientes(productosDespensa);
    final ingredientes = await _translator.translateIngredientsToEnglish(
      ingredientesNormalizados,
    );

    if (ingredientes.isEmpty) {
      throw const RecetasRemoteException(
        message: 'No hay ingredientes validos en despensa para buscar recetas',
      );
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_recipesBaseUrl/findByIngredients',
        queryParameters: {
          'ingredients': ingredientes.join(','),
          'number': numberLimitado,
          'ranking': 1,
          'ignorePantry': ignorePantry,
          'apiKey': _apiKey,
        },
      );

      final data = response.data;
      if (data == null) return const [];

      final raw = data
          .whereType<Map<String, dynamic>>()
          .take(_maxRecetasPorBusqueda)
          .toList();
      return _traducirResultadosBusqueda(raw);
    } on DioException catch (e) {
      throw _mapearErrorRemoto(e);
    }
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

    final translatedSections = await _translator
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

  List<String> _normalizarIngredientes(List<String> productosDespensa) {
    return productosDespensa
        .map((producto) => producto.trim().toLowerCase())
        .where((producto) => producto.isNotEmpty)
        .toSet()
        .toList();
  }

  void _validarApiKey() {
    if (_apiKey.isEmpty) {
      throw const RecetasRemoteException(
        message:
            'Falta SPOONACULAR_API_KEY. Usa --dart-define=SPOONACULAR_API_KEY=... ',
      );
    }
  }

  RecetasRemoteException _mapearErrorRemoto(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map<String, dynamic>
        ? (data['message']?.toString() ?? e.message ?? 'Error remoto')
        : (e.message ?? 'Error remoto');

    return RecetasRemoteException(statusCode: statusCode, message: message);
  }
}
