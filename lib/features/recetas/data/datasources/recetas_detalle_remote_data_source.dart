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
      final respuestas = await Future.wait([
        _dio.get<Map<String, dynamic>>(
          '$_recipesBaseUrl/$recetaId/information',
          queryParameters: {'apiKey': _apiKey},
        ),
        _dio.get<Map<String, dynamic>>(
          '$_recipesBaseUrl/$recetaId/equipmentWidget.json',
          queryParameters: {'apiKey': _apiKey},
        ),
      ]);

      final infoData = respuestas[0].data;
      final equipmentData = respuestas[1].data;

      if (infoData == null || equipmentData == null) {
        throw const RecetasRemoteException(
          message: 'Respuesta vacia de Spoonacular',
        );
      }

      final translatedInfo = await _traducirInfo(infoData);
      final translatedEquipment = await _traducirEquipamiento(equipmentData);

      return {'information': translatedInfo, 'equipment': translatedEquipment};
    } on DioException catch (e) {
      throw _mapearErrorRemoto(e);
    }
  }

  Future<Map<String, dynamic>> _traducirInfo(Map<String, dynamic> info) async {
    final copy = Map<String, dynamic>.from(info);

    final title = copy['title']?.toString() ?? '';
    if (title.trim().isNotEmpty) {
      final translated = await _translator.translateTermsToSpanish([
        title,
      ], context: 'Recipe title for app UI');
      copy['title'] = translated.first;
    }

    final instructions = copy['instructions']?.toString() ?? '';
    if (instructions.trim().isNotEmpty) {
      copy['instructions'] = await _translator.translateTextToSpanish(
        instructions,
        context: 'Recipe instructions for app UI',
      );
    }

    final extendedIngredients = copy['extendedIngredients'];
    if (extendedIngredients is List && extendedIngredients.isNotEmpty) {
      final names = extendedIngredients
          .whereType<Map<String, dynamic>>()
          .map((item) => item['name']?.toString() ?? '')
          .where((name) => name.trim().isNotEmpty)
          .toList();

      final translatedNames = names.isEmpty
          ? const <String>[]
          : await _translator.translateTermsToSpanish(
              names,
              context: 'Recipe ingredient names for app UI',
            );

      var idx = 0;
      copy['extendedIngredients'] = extendedIngredients.map((item) {
        if (item is! Map<String, dynamic>) return item;
        final itemCopy = Map<String, dynamic>.from(item);
        final originalName = itemCopy['name']?.toString() ?? '';
        if (originalName.trim().isNotEmpty && idx < translatedNames.length) {
          itemCopy['name'] = translatedNames[idx];
          idx++;
        }
        return itemCopy;
      }).toList();
    }

    return copy;
  }

  Future<Map<String, dynamic>> _traducirEquipamiento(
    Map<String, dynamic> equipment,
  ) async {
    final copy = Map<String, dynamic>.from(equipment);
    final raw = copy['equipment'];
    if (raw is! List || raw.isEmpty) return copy;

    final names = raw
        .whereType<Map<String, dynamic>>()
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.trim().isNotEmpty)
        .toList();

    final translatedNames = names.isEmpty
        ? const <String>[]
        : await _translator.translateTermsToSpanish(
            names,
            context: 'Kitchen equipment names for app UI',
          );

    var idx = 0;
    copy['equipment'] = raw.map((item) {
      if (item is! Map<String, dynamic>) return item;
      final itemCopy = Map<String, dynamic>.from(item);
      final originalName = itemCopy['name']?.toString() ?? '';
      if (originalName.trim().isNotEmpty && idx < translatedNames.length) {
        itemCopy['name'] = translatedNames[idx];
        idx++;
      }
      return itemCopy;
    }).toList();

    return copy;
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
