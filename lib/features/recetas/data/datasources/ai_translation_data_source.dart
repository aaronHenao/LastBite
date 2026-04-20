import 'dart:convert';

import 'package:dio/dio.dart';

const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com';
const String _hardcodedGeminiModel = 'gemini-2.0-flash';

class AiTranslationDataSource {
  AiTranslationDataSource({
    Dio? dio,
    String? apiKey,
    bool fallbackToOriginalOnFailure = true,
  }) : _dio = dio ?? Dio(),
       _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY'),
       _fallbackToOriginalOnFailure = fallbackToOriginalOnFailure;

  final Dio _dio;
  final String _apiKey;
  final bool _fallbackToOriginalOnFailure;

  String? _lastWarning;
  bool _sessionDisabled = false;

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
      sourceLanguage: 'Spanish',
      targetLanguage: 'English',
      context:
          'Food ingredients for Spoonacular API query parameters. Use concise ingredient nouns.',
    );
  }

  Future<List<String>> translateTermsToSpanish(
    List<String> terms, {
    String context = 'Food and recipe terms for app UI',
  }) {
    return _translateList(
      texts: terms,
      sourceLanguage: 'English',
      targetLanguage: 'Spanish',
      context: context,
    );
  }

  Future<String> translateTextToSpanish(String text, {String? context}) async {
    if (text.trim().isEmpty) return text;
    final translated = await _translateList(
      texts: [text],
      sourceLanguage: 'English',
      targetLanguage: 'Spanish',
      context: context ?? 'Recipe instructions for app UI',
    );
    return translated.first;
  }

  Future<List<String>> _translateList({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
    required String context,
  }) async {
    clearWarning();
    if (texts.isEmpty) return texts;

    if (!isEnabled) {
      _lastWarning =
          'La traduccion IA esta deshabilitada: falta GEMINI_API_KEY.';
      return texts;
    }

    if (_sessionDisabled) {
      _lastWarning =
          'La traduccion IA esta temporalmente deshabilitada por error de configuracion (GEMINI).';
      return texts;
    }

    final output = List<String>.from(texts);
    final pending = <String>[];
    final pendingIndexes = <int>[];

    for (var i = 0; i < texts.length; i++) {
      final text = texts[i].trim();
      if (text.isEmpty) continue;

      final cacheKey = _cacheKey(text, sourceLanguage, targetLanguage);
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
      final translatedPending = await _translatePending(
        pending: pending,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        context: context,
      );

      for (var i = 0; i < translatedPending.length; i++) {
        final translated = translatedPending[i].trim();
        final original = pending[i];
        final index = pendingIndexes[i];

        final safeTranslated = translated.isEmpty ? original : translated;
        output[index] = safeTranslated;
        _cache[_cacheKey(original, sourceLanguage, targetLanguage)] =
            safeTranslated;
      }

      return output;
    } on _GeminiConfigurationException catch (e) {
      _sessionDisabled = true;
      _lastWarning = e.message;

      if (_fallbackToOriginalOnFailure) {
        return texts;
      }
      rethrow;
    } catch (_) {
      _lastWarning =
          'La traduccion IA fallo; se mostraran textos originales temporalmente.';

      if (_fallbackToOriginalOnFailure) {
        return texts;
      }
      rethrow;
    }
  }

  Future<List<String>> _translatePending({
    required List<String> pending,
    required String sourceLanguage,
    required String targetLanguage,
    required String context,
  }) async {
    final prompt =
        '''
You are a professional translator.
Translate the following list from $sourceLanguage to $targetLanguage.
Context: $context

Rules:
- Preserve order and list length exactly.
- Return ONLY valid JSON array of strings.
- Do not include markdown, comments or explanations.

Input JSON array:
${jsonEncode(pending)}
''';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_geminiBaseUrl/v1beta/models/$_hardcodedGeminiModel:generateContent',
        queryParameters: {'key': _apiKey},
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.1},
        },
      );

      return _parseResponse(response.data, pending.length);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        throw _GeminiConfigurationException(
          'La traduccion IA fallo: revisa GEMINI_API_KEY de AI Studio y permisos del proyecto.',
        );
      }

      if (statusCode == 404) {
        throw _GeminiConfigurationException(
          'Modelo Gemini no disponible: $_hardcodedGeminiModel. Cambia el modelo hardcodeado en ai_translation_data_source.dart.',
        );
      }

      throw FormatException(
        'Error Gemini ${statusCode ?? 'sin-codigo'}: ${e.message ?? 'fallo remoto'}',
      );
    }
  }

  List<String> _parseResponse(Map<String, dynamic>? data, int expectedLength) {
    if (data == null) {
      throw const FormatException('Respuesta vacia del modelo de traduccion');
    }

    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const FormatException(
        'No hay candidatos en la respuesta del modelo',
      );
    }

    final first = candidates.first;
    if (first is! Map<String, dynamic>) {
      throw const FormatException('Formato invalido de candidato del modelo');
    }

    final content = first['content'];
    if (content is! Map<String, dynamic>) {
      throw const FormatException('Formato invalido de contenido del modelo');
    }

    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) {
      throw const FormatException('El modelo no devolvio partes de contenido');
    }

    final text = _extractText(parts);
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('El modelo devolvio texto vacio');
    }

    final decoded = jsonDecode(text);
    if (decoded is! List) {
      throw const FormatException(
        'El modelo no devolvio un arreglo JSON valido',
      );
    }

    final translated = decoded.map((e) => e?.toString() ?? '').toList();
    if (translated.length != expectedLength) {
      throw const FormatException(
        'El modelo devolvio una cantidad distinta de elementos traducidos',
      );
    }

    return translated;
  }

  String? _extractText(List<dynamic> parts) {
    final buffer = StringBuffer();

    for (final part in parts) {
      if (part is! Map<String, dynamic>) continue;
      final text = part['text'];
      if (text is String && text.isNotEmpty) {
        buffer.write(text);
      }
    }

    final raw = buffer.toString();
    return raw.isEmpty ? null : raw;
  }

  String _cacheKey(String text, String sourceLanguage, String targetLanguage) {
    return '$sourceLanguage->$targetLanguage::$text';
  }
}

class _GeminiConfigurationException implements Exception {
  const _GeminiConfigurationException(this.message);

  final String message;
}
