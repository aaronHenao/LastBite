import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../datasources/recetas_remote_exception.dart';

const String _logName = 'LastBite:Spoonacular';
const String _recipesBaseUrl = 'https://api.spoonacular.com/recipes';

void _spoonLog(String event, [Object? detail]) {
  final buf = StringBuffer('[$_logName] $event');
  if (detail != null) {
    buf.writeln();
    try {
      if (detail is String) {
        buf.write(detail);
      } else {
        buf.write(const JsonEncoder.withIndent('  ').convert(detail));
      }
    } catch (_) {
      buf.write(detail.toString());
    }
  }
  final text = buf.toString();
  const chunk = 1200;
  for (var i = 0; i < text.length; i += chunk) {
    final end = (i + chunk < text.length) ? i + chunk : text.length;
    debugPrint(text.substring(i, end));
  }
}

String _truncateForLog(String s, {int max = 24000}) {
  if (s.length <= max) return s;
  return '${s.substring(0, max)}\n... [truncado: ${s.length - max} caracteres más]';
}

Map<String, dynamic> _queryForLog(Map<String, dynamic> q) {
  final copy = Map<String, dynamic>.from(q);
  if (copy.containsKey('apiKey')) {
    copy['apiKey'] = '***';
  }
  return copy;
}

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

    final queryParameters = <String, dynamic>{
      'ingredients': ingredients.join(','),
      'number': number,
      'ranking': ranking,
      'ignorePantry': ignorePantry,
      'apiKey': _apiKey,
    };

    _spoonLog('findByIngredients REQUEST', {
      'method': 'GET',
      'url': '$_recipesBaseUrl/findByIngredients',
      'query': _queryForLog(queryParameters),
      'ingredientsList': ingredients,
    });

    try {
      final response = await _dio.get<List<dynamic>>(
        '$_recipesBaseUrl/findByIngredients',
        queryParameters: queryParameters,
      );

      _spoonLog('findByIngredients RESPONSE_META', {
        'statusCode': response.statusCode,
        'itemCount': (response.data ?? const []).length,
      });

      final list = (response.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      _spoonLog(
        'findByIngredients RESPONSE_BODY',
        _truncateForLog(const JsonEncoder.withIndent('  ').convert(list)),
      );

      return list;
    } on DioException catch (e) {
      _spoonLog('findByIngredients DioException', {
        'message': e.message,
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data,
      });
      throw _mapRemoteError(e);
    }
  }

  Future<Map<String, dynamic>> getRecipeInformation({
    required int recipeId,
  }) async {
    _validateApiKey();

    final queryParameters = <String, dynamic>{'apiKey': _apiKey};

    _spoonLog('getRecipeInformation REQUEST', {
      'method': 'GET',
      'url': '$_recipesBaseUrl/$recipeId/information',
      'recipeId': recipeId,
      'query': _queryForLog(queryParameters),
    });

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_recipesBaseUrl/$recipeId/information',
        queryParameters: queryParameters,
      );

      _spoonLog('getRecipeInformation RESPONSE_META', {
        'statusCode': response.statusCode,
        'recipeId': recipeId,
      });

      final infoData = response.data;
      if (infoData == null) {
        throw const RecetasRemoteException(
          message: 'Respuesta vacia de Spoonacular',
        );
      }

      final copy = Map<String, dynamic>.from(infoData);
      _spoonLog(
        'getRecipeInformation RESPONSE_BODY',
        _truncateForLog(const JsonEncoder.withIndent('  ').convert(copy)),
      );

      return copy;
    } on DioException catch (e) {
      _spoonLog('getRecipeInformation DioException', {
        'recipeId': recipeId,
        'message': e.message,
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data,
      });
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
