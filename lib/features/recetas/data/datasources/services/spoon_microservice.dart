import 'package:dio/dio.dart';

import '../recetas_remote_exception.dart';

const String _recipesBaseUrl = 'https://api.spoonacular.com/recipes';

class SpoonService {
  SpoonService({Dio? dio, String? apiKey})
    : _dio = dio ?? Dio(),
      _apiKey = apiKey ?? const String.fromEnvironment('SPOONACULAR_API_KEY');

  final Dio _dio;
  final String _apiKey;

  Future<List<Map<String, dynamic>>> findByIngredients({
    required List<String> ingredients,
    required int number,
    required bool ignorePantry,
    int ranking = 1,
  }) async {
    _validateApiKey();

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_recipesBaseUrl/findByIngredients',
        queryParameters: {
          'ingredients': ingredients.join(','),
          'number': number,
          'ranking': ranking,
          'ignorePantry': ignorePantry,
          'apiKey': _apiKey,
        },
      );

      return (response.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } on DioException catch (e) {
      throw _mapRemoteError(e);
    }
  }

  Future<Map<String, dynamic>> getRecipeInformation({
    required int recipeId,
  }) async {
    _validateApiKey();

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_recipesBaseUrl/$recipeId/information',
        queryParameters: {'apiKey': _apiKey},
      );

      final infoData = response.data;
      if (infoData == null) {
        throw const RecetasRemoteException(
          message: 'Respuesta vacia de Spoonacular',
        );
      }

      return Map<String, dynamic>.from(infoData);
    } on DioException catch (e) {
      throw _mapRemoteError(e);
    }
  }

  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      throw const RecetasRemoteException(
        message:
            'Falta SPOONACULAR_API_KEY. Usa --dart-define=SPOONACULAR_API_KEY=... ',
      );
    }
  }

  RecetasRemoteException _mapRemoteError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map<String, dynamic>
        ? (data['message']?.toString() ?? e.message ?? 'Error remoto')
        : (e.message ?? 'Error remoto');

    return RecetasRemoteException(statusCode: statusCode, message: message);
  }
}
