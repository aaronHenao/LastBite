import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Together AI chat completions — traducciones para LastBite.
/// No lanza hacia arriba: ante error de red devuelve el input original.
class TranslationService {
  TranslationService({Dio? dio, String? apiKey})
    : _apiKey = (apiKey ?? const String.fromEnvironment('TOGETHER_API_KEY'))
          .trim(),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.together.xyz/v1',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Authorization':
                    'Bearer ${(apiKey ?? const String.fromEnvironment('TOGETHER_API_KEY')).trim()}',
                'Content-Type': 'application/json',
              },
            ),
          );

  final Dio _dio;
  final String _apiKey;

  static final Map<String, dynamic> _cache = {};

  static const String _modelShort = 'Qwen/Qwen3.5-9B';
  static const String _modelInstructions = 'Qwen/Qwen3.5-72B-Instruct-Turbo';
  static const int _maxTokensShort = 11512;
  static const int _maxTokensInstructions = 11512;

  static const Map<String, dynamic> _schemaTranslationList = {
    'type': 'object',
    'properties': {
      'items': {
        'type': 'array',
        'items': {'type': 'string'},
        'description': 'Translated ingredients in same order as input',
      },
    },
    'required': ['items'],
  };

  static const Map<String, dynamic> _schemaTranslationTitle = {
    'type': 'object',
    'properties': {
      'title': {
        'type': 'string',
        'description':
            'Translated recipe title in Latin American Spanish',
      },
    },
    'required': ['title'],
  };

  static const Map<String, dynamic> _schemaTranslationInstructions = {
    'type': 'object',
    'properties': {
      'instructions': {
        'type': 'string',
        'description':
            'Full cooking instructions translated to Latin American Spanish',
      },
    },
    'required': ['instructions'],
  };

  static const Map<String, dynamic> _jsonSchemaList = {
    'name': 'translation_list',
    'schema': _schemaTranslationList,
  };

  static const Map<String, dynamic> _jsonSchemaTitle = {
    'name': 'translation_title',
    'schema': _schemaTranslationTitle,
  };

  static const Map<String, dynamic> _jsonSchemaInstructions = {
    'name': 'translation_instructions',
    'schema': _schemaTranslationInstructions,
  };

  static const String _systemPantry = '''
You are a food ingredient translator. Translate ingredient names 
from Spanish to English. Respond ONLY in JSON following this schema:
{"type":"object","properties":{"items":{"type":"array","items":{"type":"string"}}},"required":["items"]}
Same order and count as input. Use standard culinary English terms.
''';

  static const String _systemTitle = '''
You are a culinary translator. Translate recipe titles from English 
to Latin American Spanish naturally and appetizingly. Respond ONLY 
in JSON following this schema:
{"type":"object","properties":{"title":{"type":"string"}},"required":["title"]}
''';

  static const String _systemIngredients = '''
You are a culinary translator. Translate ingredient list from 
English to Latin American Spanish. Adapt measures: cup→taza, tablespoon→cucharada,
teaspoon→cucharadita. Respond ONLY in JSON following this schema:
{"type":"object","properties":{"items":{"type":"array","items":{"type":"string"}}},"required":["items"]}
Same order and count as input.
''';

  static const String _systemInstructions = '''
Eres un chef redactor. Traduce instrucciones de receta del inglés 
al español latinoamericano. Usa verbos imperativos: precalienta, 
mezcla, vierte, hornea, saltea. Conserva tiempos y temperaturas exactos.
Convierte: 350°F→350°F (175°C). Responde SOLO en JSON siguiendo 
este schema:
{"type":"object","properties":{"instructions":{"type":"string"}},"required":["instructions"]}
''';

  bool get _hasKey => _apiKey.isNotEmpty;

  Future<List<String>> translatePantryToEnglish(List<String> items) async {
    if (items.isEmpty) return items;
    final key = jsonEncode(items);
    final cached = _cache[key];
    if (cached is List<String>) return cached;

    if (!_hasKey) return List<String>.from(items);

    try {
      final user = 'Translate to English: ${jsonEncode(items)}';
      final raw = await _callTogetherAI(
        model: _modelShort,
        systemPrompt: _systemPantry,
        userPrompt: user,
        jsonSchema: _jsonSchemaList,
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final out = (decoded['items'] as List).cast<String>();
      if (out.length != items.length) return List<String>.from(items);
      _cache[key] = out;
      return out;
    } on DioException catch (e) {
      debugPrint('TranslationService error: $e');
      return List<String>.from(items);
    }
  }

  Future<String> translateRecipeTitle(String title) async {
    final t = title.trim();
    if (t.isEmpty) return title;
    final key = 'title_es::$t';
    final cached = _cache[key];
    if (cached is String) return cached;
    if (!_hasKey) return title;

    try {
      final user = 'Translate this recipe title: $t';
      final raw = await _callTogetherAI(
        model: _modelShort,
        systemPrompt: _systemTitle,
        userPrompt: user,
        jsonSchema: _jsonSchemaTitle,
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final translated = decoded['title'] as String;
      if (translated.trim().isEmpty) return title;
      _cache[key] = translated;
      return translated;
    } on DioException catch (e) {
      debugPrint('TranslationService error: $e');
      return title;
    }
  }

  Future<List<String>> translateIngredients(List<String> ingredients) async {
    if (ingredients.isEmpty) return ingredients;
    final key = jsonEncode(ingredients);
    final cached = _cache[key];
    if (cached is List<String>) return cached;
    if (!_hasKey) return List<String>.from(ingredients);

    try {
      final user = 'Translate to Spanish: ${jsonEncode(ingredients)}';
      final raw = await _callTogetherAI(
        model: _modelShort,
        systemPrompt: _systemIngredients,
        userPrompt: user,
        jsonSchema: _jsonSchemaList,
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final out = (decoded['items'] as List).cast<String>();
      if (out.length != ingredients.length) return List<String>.from(ingredients);
      _cache[key] = out;
      return out;
    } on DioException catch (e) {
      debugPrint('TranslationService error: $e');
      return List<String>.from(ingredients);
    }
  }

  Future<String> translateInstructions(String instructions) async {
    final t = instructions.trim();
    if (t.isEmpty) return instructions;
    final key = 'instr_es::${t.hashCode}_${t.length}';
    final cached = _cache[key];
    if (cached is String) return cached;
    if (!_hasKey) return instructions;

    try {
      final user = 'Traduce estas instrucciones: $t';
      final raw = await _callTogetherAI(
        model: _modelInstructions,
        systemPrompt: _systemInstructions,
        userPrompt: user,
        jsonSchema: _jsonSchemaInstructions,
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final translated = decoded['instructions'] as String;
      if (translated.trim().isEmpty) return instructions;
      _cache[key] = translated;
      return translated;
    } on DioException catch (e) {
      debugPrint('TranslationService error: $e');
      return instructions;
    }
  }

  Future<String> _callTogetherAI({
    required String model,
    required String systemPrompt,
    required String userPrompt,
    required Map<String, dynamic> jsonSchema,
  }) async {
    final maxTokens =
        model == _modelInstructions ? _maxTokensInstructions : _maxTokensShort;
    final response = await _dio.post<dynamic>(
      '/chat/completions',
      data: <String, dynamic>{
        'model': model,
        'max_tokens': maxTokens,
        'temperature': 0.1,
        'reasoning': {'enabled': false},
        'messages': <Map<String, String>>[
          {'role': 'system', 'content': systemPrompt.trim()},
          {'role': 'user', 'content': userPrompt.trim()},
        ],
        'response_format': {
          'type': 'json_schema',
          'json_schema': jsonSchema,
        },
      },
    );

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    final first = choices.first as Map<String, dynamic>;
    final message = first['message'] as Map<String, dynamic>;
    return message['content'] as String;
  }
}
