import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const String _defaultChatApiBaseUrl =
    'https://api.together.xyz/v1/chat/completions';

const String _modelShort = 'Qwen/Qwen3.5-9B';
const String _modelLong = 'Qwen/Qwen3.5-397B-A17B';

const Duration _translationTimeout = Duration(seconds: 12);
const Duration _retryDelay = Duration(seconds: 1);
const int _maxRetries = 2;

const String _systemPromptPantryToEnglish = '''
Eres un asistente de cocina especializado en ingredientes y productos alimenticios.
Tu tarea es traducir nombres de ingredientes del espanol al ingles de forma precisa
y estandar, usando los terminos que reconoceria una base de datos de recetas americana
(por ejemplo: "aguacate" -> "avocado", "maiz" -> "corn", "cilantro" -> "cilantro").
Responde UNICAMENTE con un array JSON de strings en ingles, sin explicaciones,
sin backticks, sin texto adicional. El orden del array debe conservarse exactamente.
''';

const String _systemPromptRecipeShort = '''
Eres un chef traductor especializado en recetas de cocina.
Traduce del ingles al espanol latinoamericano de forma natural y apetitosa.
Usa terminos culinarios propios del espanol hablado en Latinoamerica.
Adapta las unidades de medida: "cup" -> "taza", "tablespoon" -> "cucharada",
"teaspoon" -> "cucharadita", "oz" -> "oz", "lb" -> "lb", "pound" -> "libra".
Responde UNICAMENTE con un array JSON de strings traducidos, sin explicaciones,
sin backticks, sin texto adicional. Conserva el mismo numero de elementos
y el mismo orden del array original.
''';

const String _systemPromptInstructions = '''
Eres un chef redactor especializado en recetas de cocina para publico latinoamericano.
Tu tarea es traducir instrucciones de preparacion del ingles al espanol latinoamericano.

Reglas estrictas:
1. Usa verbos imperativos propios de recetas: "precalienta", "mezcla", "vierte",
   "hornea", "saltea", "deja reposar", "incorpora".
2. Conserva los tiempos exactos: "bake for 25 minutes" -> "hornea durante 25 minutos".
3. Conserva las temperaturas: "350°F" -> "350°F (175°C)".
4. Adapta las medidas: "cup" -> "taza", "tablespoon" -> "cucharada".
5. No anadas pasos que no existan. No elimines pasos.
6. El resultado debe sonar como una receta escrita por un chef, no como una
   traduccion automatica.
7. Responde UNICAMENTE con el texto traducido, sin explicaciones adicionales.
''';

class AiTranslationDataSource {
  AiTranslationDataSource({
    Dio? dio,
    String? apiKey,
    String? chatApiBaseUrl,
  }) : _dio = dio ?? Dio(),
       _apiKey = apiKey ?? _resolveApiKey(),
       _chatApiBaseUrl = _normalizeBaseUrl(
         chatApiBaseUrl ??
             const String.fromEnvironment(
               'TRANSLATION_CHAT_API_BASE_URL',
               defaultValue: _defaultChatApiBaseUrl,
             ),
       );

  final Dio _dio;
  final String _apiKey;
  final String _chatApiBaseUrl;

  String? _lastWarning;
  final Map<String, String> _cache = {};

  bool get isEnabled => _apiKey.isNotEmpty;
  String? get lastWarning => _lastWarning;

  void clearWarning() {
    _lastWarning = null;
  }

  Future<List<String>> translateIngredientsToEnglish(
    List<String> ingredientes,
  ) {
    return _translateList(
      texts: ingredientes,
      cacheKeyPrefix: 'es-en',
      systemPrompt: _systemPromptPantryToEnglish,
      userPromptBuilder: _buildPantryUserPrompt,
      model: _modelShort,
    );
  }

  Future<List<String>> translateTermsToSpanish(
    List<String> terms, {
    String context = 'Food and recipe terms for app UI',
  }) {
    return _translateList(
      texts: terms,
      cacheKeyPrefix: 'en-es',
      systemPrompt: _systemPromptRecipeShort,
      userPromptBuilder: (items) => _buildRecipeItemsPrompt(
        items,
        label: 'terminos culinarios',
        context: context,
      ),
      model: _modelShort,
    );
  }

  Future<String> translateTextToSpanish(String text, {String? context}) async {
    if (text.trim().isEmpty) return text;

    final lower = (context ?? '').toLowerCase();
    final useLong = lower.contains('instruction') || lower.contains('receta');
    final systemPrompt = useLong
        ? _systemPromptInstructions
        : _systemPromptRecipeShort;
    final model = useLong ? _modelLong : _modelShort;

    final translated = await _translateText(
      text: text,
      cacheKeyPrefix: 'en-es-text',
      systemPrompt: systemPrompt,
      userPrompt: useLong
          ? _buildInstructionsUserPrompt(text)
          : _buildRecipeTitlePrompt(text),
      model: model,
    );

    return translated ?? text;
  }

  Future<RecipeSectionsTranslation> translateRecipeSectionsToSpanish({
    List<String> titles = const [],
    List<String> ingredients = const [],
    List<String> instructions = const [],
  }) async {
    clearWarning();

    final original = RecipeSectionsTranslation(
      titles: List<String>.from(titles),
      ingredients: List<String>.from(ingredients),
      instructions: List<String>.from(instructions),
    );

    if (titles.isEmpty && ingredients.isEmpty && instructions.isEmpty) {
      return original;
    }

    if (!isEnabled) {
      _lastWarning =
          'La traduccion IA esta deshabilitada: falta TOGETHER_API_KEY.';
      return original;
    }

    final futures = <Future<List<String>>>[];

    futures.add(
      titles.isEmpty
          ? Future.value(const <String>[]) 
          : _translateList(
              texts: titles,
              cacheKeyPrefix: 'en-es-title',
              systemPrompt: _systemPromptRecipeShort,
              userPromptBuilder: _buildRecipeTitlesPrompt,
              model: _modelShort,
            ),
    );

    futures.add(
      ingredients.isEmpty
          ? Future.value(const <String>[]) 
          : _translateList(
              texts: ingredients,
              cacheKeyPrefix: 'en-es-ing',
              systemPrompt: _systemPromptRecipeShort,
              userPromptBuilder: _buildRecipeIngredientsPrompt,
              model: _modelShort,
            ),
    );

    futures.add(
      instructions.isEmpty
          ? Future.value(const <String>[]) 
          : _translateInstructions(instructions),
    );

    try {
      final results = await Future.wait(futures);

      return RecipeSectionsTranslation(
        titles: _ensureNonEmptyFallback(results[0], original.titles),
        ingredients: _ensureNonEmptyFallback(results[1], original.ingredients),
        instructions: _ensureNonEmptyFallback(results[2], original.instructions),
      );
    } on _AiTranslationRemoteException {
      return original;
    } on FormatException catch (e) {
      debugPrint('Translation parse error: ${e.message}');
      return original;
    }
  }

  Future<List<String>> _translateInstructions(List<String> instructions) async {
    final results = <String>[];

    for (final instruction in instructions) {
      final translated = await _translateText(
        text: instruction,
        cacheKeyPrefix: 'en-es-instr',
        systemPrompt: _systemPromptInstructions,
        userPrompt: _buildInstructionsUserPrompt(instruction),
        model: _modelLong,
      );
      results.add(translated ?? instruction);
    }

    return results;
  }

  Future<List<String>> _translateList({
    required List<String> texts,
    required String cacheKeyPrefix,
    required String systemPrompt,
    required String model,
    required String Function(List<String>) userPromptBuilder,
  }) async {
    clearWarning();
    if (texts.isEmpty) return texts;

    if (!isEnabled) {
      _lastWarning =
          'La traduccion IA esta deshabilitada: falta TOGETHER_API_KEY.';
      return texts;
    }

    final output = List<String>.from(texts);
    final pending = <String>[];
    final pendingIndexes = <int>[];

    for (var i = 0; i < texts.length; i++) {
      final text = texts[i].trim();
      if (text.isEmpty) continue;

      final cacheKey = _cacheKey(cacheKeyPrefix, text);
      final cached = _cache[cacheKey];
      if (cached != null) {
        output[i] = cached;
      } else {
        pending.add(text);
        pendingIndexes.add(i);
      }
    }

    if (pending.isEmpty) return output;

    try {
      final userPrompt = userPromptBuilder(pending);
      final content = await _callTogetherAI(
        model: model,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
      );

      final translatedPending = _parseJsonArray(content, pending.length);
      for (var i = 0; i < translatedPending.length; i++) {
        final translated = translatedPending[i].trim();
        final original = pending[i];
        final index = pendingIndexes[i];
        final safeTranslated = translated.isEmpty ? original : translated;
        output[index] = safeTranslated;
        _cache[_cacheKey(cacheKeyPrefix, original)] = safeTranslated;
      }

      return output;
    } on FormatException catch (e) {
      _lastWarning = 'La traduccion IA devolvio un formato invalido.';
      debugPrint('Translation parse error: ${e.message}');
      return output;
    } on _AiTranslationRemoteException {
      return output;
    }
  }

  Future<String?> _translateText({
    required String text,
    required String cacheKeyPrefix,
    required String systemPrompt,
    required String userPrompt,
    required String model,
  }) async {
    clearWarning();

    if (!isEnabled) {
      _lastWarning =
          'La traduccion IA esta deshabilitada: falta TOGETHER_API_KEY.';
      return null;
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;

    final cacheKey = _cacheKey(cacheKeyPrefix, trimmed);
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    try {
      final content = await _callTogetherAI(
        model: model,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
      );
      final normalized = _normalizePlainText(content);
      final result = normalized.isEmpty ? trimmed : normalized;
      _cache[cacheKey] = result;
      return result;
    } on FormatException catch (e) {
      _lastWarning = 'La traduccion IA devolvio un formato invalido.';
      debugPrint('Translation parse error: ${e.message}');
      return null;
    } on _AiTranslationRemoteException {
      return null;
    }
  }

  Future<String> _callTogetherAI({
    required String model,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    _AiTranslationRemoteException? lastRemoteError;

    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _dio
            .post<dynamic>(
              _chatApiBaseUrl,
              options: Options(headers: _buildHeaders()),
              data: {
                'model': model,
                'messages': [
                  {'role': 'system', 'content': systemPrompt.trim()},
                  {'role': 'user', 'content': userPrompt.trim()},
                ],
                'temperature': 0.2,
                'stream': false,
              },
            )
            .timeout(_translationTimeout);

        return _parseChatContent(response.data);
      } on DioException catch (e) {
        lastRemoteError = _buildRemoteException(e);
      } on TimeoutException {
        lastRemoteError = const _AiTranslationRemoteException(
          'Timeout al traducir con Together AI.',
        );
      } on FormatException catch (e) {
        lastRemoteError = _AiTranslationRemoteException(
          'Respuesta invalida del modelo. ${e.message}',
        );
      }

      if (attempt < _maxRetries) {
        await Future.delayed(_retryDelay);
      }
    }

    throw lastRemoteError ??
        const _AiTranslationRemoteException(
          'No fue posible completar la traduccion.',
        );
  }

  String _parseChatContent(dynamic data) {
    if (data == null) {
      throw const FormatException('Respuesta vacia del modelo.');
    }

    if (data is Map<String, dynamic> && data['error'] != null) {
      throw FormatException('Together AI error: ${data['error']}');
    }

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Formato de respuesta no soportado.');
    }

    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const FormatException('No hay choices en la respuesta del modelo.');
    }

    final first = choices.first;
    if (first is! Map<String, dynamic>) {
      throw const FormatException('Choice invalido en respuesta del modelo.');
    }

    final message = first['message'];
    if (message is! Map<String, dynamic>) {
      throw const FormatException('Message invalido en respuesta del modelo.');
    }

    final content = message['content']?.toString() ?? '';
    if (content.trim().isEmpty) {
      throw const FormatException('El modelo devolvio contenido vacio.');
    }

    return content;
  }

  String _buildPantryUserPrompt(List<String> ingredientes) {
    return '''
Traduce estos ingredientes al ingles en el mismo orden:
${jsonEncode(ingredientes)}

Responde solo con el array JSON. Ejemplo de formato esperado:
["chicken breast", "avocado", "lime", "garlic"]
''';
  }

  String _buildRecipeTitlesPrompt(List<String> titles) {
    return '''
Traduce estos titulos de receta al espanol latinoamericano:
${jsonEncode(titles)}

Responde solo con el array JSON traducido.
''';
  }

  String _buildRecipeIngredientsPrompt(List<String> ingredients) {
    return '''
Traduce estos ingredientes de receta al espanol latinoamericano:
${jsonEncode(ingredients)}

Responde solo con el array JSON traducido. Ejemplo de formato:
["2 pechugas de pollo", "1 taza de arroz", "3 dientes de ajo picados"]
''';
  }

  String _buildRecipeItemsPrompt(
    List<String> items, {
    required String label,
    String? context,
  }) {
    final suffix = context == null ? '' : '\nContexto: $context';
    return '''
Traduce estos $label al espanol latinoamericano:
${jsonEncode(items)}$suffix

Responde solo con el array JSON traducido.
''';
  }

  String _buildRecipeTitlePrompt(String title) {
    return '''
Traduce este titulo de receta al espanol latinoamericano:
"$title"

Responde solo con el string traducido entre comillas dobles.
''';
  }

  String _buildInstructionsUserPrompt(String instructions) {
    return '''
Traduce estas instrucciones de preparacion al espanol latinoamericano:

$instructions

Recuerda: solo el texto traducido, nada mas.
''';
  }

  List<String> _parseJsonArray(String content, int expectedLength) {
    final decoded = jsonDecode(_extractJsonArray(content));

    if (decoded is! List) {
      throw const FormatException(
        'El modelo no devolvio un arreglo JSON valido.',
      );
    }

    final translated = decoded.map((e) => e?.toString() ?? '').toList();

    if (translated.length != expectedLength) {
      throw FormatException(
        'El modelo devolvio ${translated.length} traducciones y se esperaban $expectedLength.',
      );
    }

    return translated;
  }

  String _extractJsonArray(String content) {
    final trimmed = content.trim();

    if (trimmed.startsWith('```')) {
      return trimmed
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }

    final start = trimmed.indexOf('[');
    final end = trimmed.lastIndexOf(']');
    if (start >= 0 && end > start) {
      return trimmed.substring(start, end + 1);
    }

    return trimmed;
  }

  String _normalizePlainText(String content) {
    var text = content.trim();

    if (text.startsWith('```')) {
      text = text
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }

    if (text.startsWith('"') && text.endsWith('"')) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is String) return decoded.trim();
      } on FormatException {
        // Keep original text if it is not valid JSON string.
      }
    }

    return text.trim();
  }

  List<String> _ensureNonEmptyFallback(
    List<String> translated,
    List<String> original,
  ) {
    if (translated.length != original.length) {
      return original;
    }

    final safe = <String>[];
    for (var i = 0; i < translated.length; i++) {
      final value = translated[i].trim();
      safe.add(value.isEmpty ? original[i] : translated[i]);
    }
    return safe;
  }

  _AiTranslationRemoteException _buildRemoteException(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    final details = responseData?.toString() ?? e.message ?? 'Error remoto';

    if (statusCode == 401 || statusCode == 403) {
      _lastWarning =
          'La traduccion IA fallo: token de Together AI invalido o sin permisos.';
    } else if (statusCode == 402) {
      _lastWarning =
          'La traduccion IA fallo: esta cuenta de Together AI requiere pago para ese endpoint.';
    } else if (statusCode == 429) {
      _lastWarning =
          'La traduccion IA fallo: limite de requests en Together AI (429).';
    } else if (statusCode == 404) {
      _lastWarning =
          'La traduccion IA fallo en Together AI (404). Revisa la URL base del endpoint.';
    } else {
      _lastWarning =
          'La traduccion IA fallo en Together AI (${statusCode ?? 'sin-codigo'}).';
    }

    return _AiTranslationRemoteException(
      '${_lastWarning!} Detalle: $details',
    );
  }

  String _cacheKey(String prefix, String text) {
    return '$prefix::$text';
  }

  static String _resolveApiKey() {
    return const String.fromEnvironment('TOGETHER_API_KEY');
  }

  Map<String, String> _buildHeaders() {
    return {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };
  }

  static String _normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}

class _AiTranslationConfigurationException implements Exception {
  const _AiTranslationConfigurationException(this.message);

  final String message;
}

class _AiTranslationRemoteException implements Exception {
  const _AiTranslationRemoteException(this.message);

  final String message;
}

class RecipeSectionsTranslation {
  const RecipeSectionsTranslation({
    required this.titles,
    required this.ingredients,
    required this.instructions,
  });

  final List<String> titles;
  final List<String> ingredients;
  final List<String> instructions;
}
