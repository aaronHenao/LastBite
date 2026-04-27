import 'package:dio/dio.dart';

import 'ai_translation_data_source.dart';
import 'recetas_remote_exception.dart';

const String _recipesBaseUrl = 'https://api.spoonacular.com/recipes';

class RecetasDetalleRemoteDataSource {
  RecetasDetalleRemoteDataSource({
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

  Future<Map<String, dynamic>> obtenerDetalleRecetaRaw({
    required int recetaId,
  }) async {
    _validarApiKey();
    _translator.clearWarning();

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_recipesBaseUrl/$recetaId/information',
        queryParameters: {'apiKey': _apiKey},
      );

      final infoData = response.data;

      if (infoData == null) {
        throw const RecetasRemoteException(
          message: 'Respuesta vacia de Spoonacular',
        );
      }

      final translatedInfo = await _traducirInfo(infoData);
      return {
        'information': translatedInfo,
        'equipment': {'equipment': <Map<String, dynamic>>[]},
      };
    } on DioException catch (e) {
      throw _mapearErrorRemoto(e);
    }
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

    final translatedSections = await _translator
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

  bool _esInstruccionPlaceholder(String texto) {
    final t = texto.toLowerCase().trim();
    return t.contains('interfaz de la app') ||
        t == 'instrucciones de la receta para la interfaz de la app' ||
        t == 'recipe instructions for app ui';
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
