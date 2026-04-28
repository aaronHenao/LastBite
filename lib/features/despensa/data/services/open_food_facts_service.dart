import 'package:dio/dio.dart';

import '../datasources/open_food_facts_remote_exception.dart';

const String _openFoodFactsBaseUrl =
    'https://world.openfoodfacts.org/api/v2/product';

class OpenFoodFactsService {
  OpenFoodFactsService({Dio? dio, String? apiKey})
    : _dio = dio ?? Dio(),
      _apiKey =
          apiKey ?? const String.fromEnvironment('OPEN_FOOD_FACTS_API_KEY');

  final Dio _dio;
  final String _apiKey;

  Future<Map<String, dynamic>> getProductRaw({required String code}) async {
    _validateApiKey();

    try {
      final queryParameters = <String, dynamic>{
        'fields': 'product_name,product_name_es,brands,serving_size,nutriments',
        'api_key': _apiKey,
      };

      final response = await _dio.get<Map<String, dynamic>>(
        '$_openFoodFactsBaseUrl/$code',
        queryParameters: queryParameters,
      );

      final data = response.data;
      if (data == null) {
        throw const OpenFoodFactsRemoteException(
          message: 'Respuesta vacia de Open Food Facts',
        );
      }

      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      throw _mapRemoteError(e);
    }
  }

  OpenFoodFactsRemoteException _mapRemoteError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map<String, dynamic>
        ? (data['status_verbose']?.toString() ??
              data['message']?.toString() ??
              e.message ??
              'Error remoto')
        : (e.message ?? 'Error remoto');

    return OpenFoodFactsRemoteException(
      statusCode: statusCode,
      message: message,
    );
  }

  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      throw const OpenFoodFactsRemoteException(
        message:
            'Falta OPEN_FOOD_FACTS_API_KEY. Usa --dart-define=OPEN_FOOD_FACTS_API_KEY=... ',
      );
    }
  }
}
