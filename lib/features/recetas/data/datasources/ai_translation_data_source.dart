import 'dart:convert';
import 'dart:async';

import 'package:dio/dio.dart';

const String _defaultChatApiBaseUrl = 'https://openrouter.ai/api/v1';
const String _defaultTranslationModelsCsv =
    'liquid/lfm-2.5-1.2b-instruct:free,'
    'inclusionai/ling-2.6-flash:free,'
    'nvidia/nemotron-3-nano-30b-a3b:free';

class AiTranslationDataSource {
  AiTranslationDataSource({
    Dio? dio,
    String? apiKey,
    String? chatApiBaseUrl,
    String? model,
  }) : _dio = dio ?? Dio(),
       _apiKey = apiKey ?? _resolveApiKey(),
       _chatApiBaseUrl = _normalizeBaseUrl(
         chatApiBaseUrl ??
             const String.fromEnvironment(
               'TRANSLATION_CHAT_API_BASE_URL',
               defaultValue: _defaultChatApiBaseUrl,
             ),
       ),
       _models = _resolveModels(
         preferredModel: model,
         modelsCsv: const String.fromEnvironment(
           'TRANSLATION_MODELS',
           defaultValue: _defaultTranslationModelsCsv,
         ),
         legacyModel: const String.fromEnvironment('TRANSLATION_MODEL'),
       ),
       _openRouterReferer = const String.fromEnvironment(
         'OPENROUTER_HTTP_REFERER',
       ),
       _openRouterTitle = const String.fromEnvironment(
         'OPENROUTER_APP_TITLE',
         defaultValue: 'LastBite',
       );

  static const Duration _translationTimeout = Duration(seconds: 8);

  final Dio _dio;
  final String _apiKey;
  final String _chatApiBaseUrl;
  final List<String> _models;
  final String _openRouterReferer;
  final String _openRouterTitle;

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
          'La traduccion IA esta deshabilitada: falta OPENROUTER_API_KEY.';
      return original;
    }

    if (_chatApiBaseUrl.contains('openrouter.ai') &&
        _apiKey.startsWith('hf_')) {
      _lastWarning =
          'La traduccion IA se omite: estas usando una clave de Hugging Face en OpenRouter.';
      return original;
    }

    try {
      final translated = await _translateRecipeSectionsPending(
        titles: titles,
        ingredients: ingredients,
        instructions: instructions,
        sourceLanguage: 'English',
        targetLanguage: 'Spanish',
      );

      return RecipeSectionsTranslation(
        titles: _ensureNonEmptyFallback(translated.titles, original.titles),
        ingredients: _ensureNonEmptyFallback(
          translated.ingredients,
          original.ingredients,
        ),
        instructions: _ensureNonEmptyFallback(
          translated.instructions,
          original.instructions,
        ),
      );
    } on TimeoutException {
      _lastWarning =
          'La traduccion IA tardó demasiado y se omitió para no bloquear recetas.';
      return original;
    } on FormatException catch (e) {
      _lastWarning = e.message;
      return original;
    } on _AiTranslationRemoteException {
      return original;
    }
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
          'La traduccion IA esta deshabilitada: falta OPENROUTER_API_KEY.';
      return texts;
    }

    if (_chatApiBaseUrl.contains('openrouter.ai') &&
        _apiKey.startsWith('hf_')) {
      _lastWarning =
          'La traduccion IA se omite: estas usando una clave de Hugging Face en OpenRouter.';
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

        final safeTranslated = _postProcessTranslation(
          translated: translated.isEmpty ? original : translated,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          context: context,
        );
        output[index] = safeTranslated;
        _cache[_cacheKey(original, sourceLanguage, targetLanguage)] =
            safeTranslated;
      }

      return output;
    } on TimeoutException {
      _lastWarning =
          'La traduccion IA tardó demasiado y se omitió para no bloquear recetas.';
      return texts;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      final details = responseData?.toString() ?? e.message ?? 'Error remoto';
      final remoteMessage = _extractRemoteMessage(responseData);

      if (statusCode == 401 || statusCode == 403) {
        _lastWarning =
            'La traduccion IA fallo: token de OpenRouter invalido o sin permisos.';
      } else if (statusCode == 402) {
        _lastWarning =
            'La traduccion IA fallo: esta cuenta de OpenRouter requiere pago para ese endpoint.';
      } else if (statusCode == 429) {
        _lastWarning =
            'La traduccion IA fallo: limite de requests en OpenRouter (429).';
      } else if (statusCode == 404) {
        _lastWarning =
            'La traduccion IA fallo en OpenRouter (404). Revisa la URL base del endpoint.';
      } else if (statusCode == 400 &&
          remoteMessage.toLowerCase().contains('not a chat model')) {
        _lastWarning =
            'La traduccion IA fallo: el modelo seleccionado no es compatible con chat completions.';
      } else if (statusCode == 400 &&
          remoteMessage.toLowerCase().contains(
            'not supported by any provider',
          )) {
        _lastWarning =
            'La traduccion IA fallo: el modelo no esta disponible en el proveedor configurado.';
      } else {
        _lastWarning =
            'La traduccion IA fallo en OpenRouter (${statusCode ?? 'sin-codigo'}).';
      }

      throw _AiTranslationRemoteException(
        '${_lastWarning!} Detalle: ${remoteMessage.isNotEmpty ? remoteMessage : details}',
      );
    } on FormatException catch (e) {
      _lastWarning = e.message;
      return texts;
    } on _AiTranslationRemoteException {
      return texts;
    }
  }

  Future<List<String>> _translatePending({
    required List<String> pending,
    required String sourceLanguage,
    required String targetLanguage,
    required String context,
  }) async {
    _validateDirection(sourceLanguage, targetLanguage);

    final systemPrompt = _buildSystemPrompt(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      context: context,
      isIngredientContext: context.toLowerCase().contains('ingredient'),
      isTitleContext: context.toLowerCase().contains('title'),
      isInstructionContext: context.toLowerCase().contains('instruction'),
    );

    final prompt =
        '''
Translate from $sourceLanguage to $targetLanguage.
Context: $context

Rules:
- Preserve order and list length exactly.
- Return ONLY a valid JSON array of strings.
- Do not add markdown, labels or explanations.
- Keep culinary meaning precise and natural for cooking/shopping vocabulary.
- Do not invent ingredients or omit important qualifiers.
- Keep brand/product names when present.

Input JSON array:
${jsonEncode(pending)}
''';

    _AiTranslationRemoteException? lastRemoteError;

    for (var i = 0; i < _models.length; i++) {
      final model = _models[i];
      try {
        final response = await _dio
            .post<dynamic>(
              _buildChatCompletionsUrl(),
              options: Options(headers: _buildHeaders()),
              data: {
                'model': model,
                'messages': [
                  {'role': 'system', 'content': systemPrompt},
                  {'role': 'user', 'content': prompt},
                ],
                'temperature': 0.1,
                'stream': false,
              },
            )
            .timeout(_translationTimeout);

        if (i > 0) {
          _lastWarning = 'Se uso modelo de respaldo para traduccion: $model.';
        }

        return _parseOpenRouterChatResponse(response.data, pending.length);
      } on DioException catch (e) {
        lastRemoteError = _buildRemoteExceptionForModel(model, e);
      } on FormatException catch (e) {
        lastRemoteError = _AiTranslationRemoteException(
          'El modelo $model devolvio un formato invalido. ${e.message}',
        );
      } on TimeoutException {
        lastRemoteError = _AiTranslationRemoteException(
          'Timeout al traducir con el modelo $model.',
        );
      }
    }

    throw lastRemoteError ??
        const _AiTranslationRemoteException(
          'No hay modelos de traduccion disponibles.',
        );
  }

  Future<RecipeSectionsTranslation> _translateRecipeSectionsPending({
    required List<String> titles,
    required List<String> ingredients,
    required List<String> instructions,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    _validateDirection(sourceLanguage, targetLanguage);

    final systemPrompt = _buildUnifiedSystemPrompt(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    final prompt = _buildUnifiedPrompt(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      titles: titles,
      ingredients: ingredients,
      instructions: instructions,
    );

    _AiTranslationRemoteException? lastRemoteError;

    for (var i = 0; i < _models.length; i++) {
      final model = _models[i];
      try {
        final response = await _dio
            .post<dynamic>(
              _buildChatCompletionsUrl(),
              options: Options(headers: _buildHeaders()),
              data: {
                'model': model,
                'messages': [
                  {'role': 'system', 'content': systemPrompt},
                  {'role': 'user', 'content': prompt},
                ],
                'temperature': 0.1,
                'stream': false,
              },
            )
            .timeout(_translationTimeout);

        if (i > 0) {
          _lastWarning = 'Se uso modelo de respaldo para traduccion: $model.';
        }

        return _parseUnifiedRecipeResponse(
          response.data,
          expectedTitles: titles.length,
          expectedIngredients: ingredients.length,
          expectedInstructions: instructions.length,
        );
      } on DioException catch (e) {
        lastRemoteError = _buildRemoteExceptionForModel(model, e);
      } on FormatException catch (e) {
        lastRemoteError = _AiTranslationRemoteException(
          'El modelo $model devolvio un formato invalido. ${e.message}',
        );
      } on TimeoutException {
        lastRemoteError = _AiTranslationRemoteException(
          'Timeout al traducir con el modelo $model.',
        );
      }
    }

    throw lastRemoteError ??
        const _AiTranslationRemoteException(
          'No hay modelos de traduccion disponibles.',
        );
  }

  List<String> _parseOpenRouterChatResponse(dynamic data, int expectedLength) {
    if (data == null) {
      throw const FormatException(
        'Respuesta vacia de OpenRouter para traduccion.',
      );
    }

    if (data is Map<String, dynamic> && data['error'] != null) {
      throw FormatException('OpenRouter error: ${data['error']}');
    }

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'Formato de respuesta no soportado de OpenRouter.',
      );
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

    dynamic decoded;
    try {
      decoded = jsonDecode(_extractJsonArray(content));
    } on FormatException {
      if (expectedLength == 1) {
        final normalized = _normalizeSingleTextContent(content);
        if (normalized.isNotEmpty) return [normalized];
      }
      rethrow;
    }

    if (decoded is! List) {
      throw const FormatException(
        'El modelo no devolvio un arreglo JSON valido.',
      );
    }

    final translated = decoded.map((e) => e?.toString() ?? '').toList();

    if (translated.length != expectedLength) {
      throw FormatException(
        'OpenRouter devolvio ${translated.length} traducciones y se esperaban $expectedLength.',
      );
    }

    return translated;
  }

  RecipeSectionsTranslation _parseUnifiedRecipeResponse(
    dynamic data, {
    required int expectedTitles,
    required int expectedIngredients,
    required int expectedInstructions,
  }) {
    if (data == null) {
      throw const FormatException(
        'Respuesta vacia de OpenRouter para traduccion.',
      );
    }

    if (data is Map<String, dynamic> && data['error'] != null) {
      throw FormatException('OpenRouter error: ${data['error']}');
    }

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'Formato de respuesta no soportado de OpenRouter.',
      );
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

    final decoded = jsonDecode(_extractJsonObject(content));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'El modelo no devolvio un objeto JSON valido para secciones.',
      );
    }

    List<String> parseSection(String key, int expectedLength) {
      if (expectedLength == 0) return const [];

      final raw = decoded[key];
      if (raw is String && expectedLength == 1) {
        return [raw];
      }

      if (raw is! List) {
        throw FormatException('La seccion $key no es una lista valida.');
      }

      final values = raw.map((e) => e?.toString() ?? '').toList();
      if (values.length != expectedLength) {
        throw FormatException(
          'La seccion $key devolvio ${values.length} elementos y se esperaban $expectedLength.',
        );
      }

      return values;
    }

    return RecipeSectionsTranslation(
      titles: parseSection('titles', expectedTitles),
      ingredients: parseSection('ingredients', expectedIngredients),
      instructions: parseSection('instructions', expectedInstructions),
    );
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

  String _extractJsonObject(String content) {
    final trimmed = content.trim();

    if (trimmed.startsWith('```')) {
      return trimmed
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }

    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return trimmed.substring(start, end + 1);
    }

    return trimmed;
  }

  String _normalizeSingleTextContent(String content) {
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

    return text;
  }

  void _validateDirection(String sourceLanguage, String targetLanguage) {
    final source = sourceLanguage.toLowerCase();
    final target = targetLanguage.toLowerCase();

    final isSupportedPair =
        (source == 'english' && target == 'spanish') ||
        (source == 'spanish' && target == 'english');

    if (isSupportedPair) return;

    throw _AiTranslationConfigurationException(
      'Direccion de traduccion no soportada: $sourceLanguage -> $targetLanguage.',
    );
  }

  String _cacheKey(String text, String sourceLanguage, String targetLanguage) {
    return '$sourceLanguage->$targetLanguage::$text';
  }

  static List<String> _resolveModels({
    String? preferredModel,
    required String modelsCsv,
    required String legacyModel,
  }) {
    final ordered = <String>[];

    void addModel(String raw) {
      final normalized = _normalizeModel(raw);
      if (normalized.isEmpty || ordered.contains(normalized)) return;
      ordered.add(normalized);
    }

    if (preferredModel != null && preferredModel.trim().isNotEmpty) {
      addModel(preferredModel);
    }

    if (legacyModel.trim().isNotEmpty) {
      addModel(legacyModel);
    }

    for (final raw in modelsCsv.split(',')) {
      addModel(raw);
    }

    if (ordered.isEmpty) {
      for (final raw in _defaultTranslationModelsCsv.split(',')) {
        addModel(raw);
      }
    }

    return ordered;
  }

  static String _normalizeModel(String model) {
    final trimmed = model.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.endsWith(':free')) return trimmed;
    return '$trimmed:free';
  }

  static String _resolveApiKey() {
    const openRouterApiKey = String.fromEnvironment('OPENROUTER_API_KEY');
    if (openRouterApiKey.isNotEmpty) return openRouterApiKey;

    // Backward compatibility while migrating from old env var.
    return String.fromEnvironment('HUGGINGFACE_API_KEY');
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    if (_openRouterReferer.trim().isNotEmpty) {
      headers['HTTP-Referer'] = _openRouterReferer.trim();
    }

    if (_openRouterTitle.trim().isNotEmpty) {
      headers['X-OpenRouter-Title'] = _openRouterTitle.trim();
    }

    return headers;
  }

  static String _normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  String _buildChatCompletionsUrl() {
    if (_chatApiBaseUrl.endsWith('/api/v1') ||
        _chatApiBaseUrl.endsWith('/v1')) {
      return '$_chatApiBaseUrl/chat/completions';
    }

    return '$_chatApiBaseUrl/v1/chat/completions';
  }

  String _buildSystemPrompt({
    required String sourceLanguage,
    required String targetLanguage,
    required String context,
    required bool isIngredientContext,
    required bool isTitleContext,
    required bool isInstructionContext,
  }) {
    if (isIngredientContext) {
      return '''
You are a professional culinary translator specializing in recipe apps for Latin American Spanish speakers.
Translate ingredient lists from $sourceLanguage to $targetLanguage.

Your goal is NATURAL, CONTEXTUAL translation - not word-for-word.

Core principles:
- Translate how a Colombian/LATAM cook would say it in a real kitchen or supermarket, not how a dictionary would.
- Prioritize meaning and usability over literal accuracy.
- A shopper should immediately recognize the ingredient on a supermarket shelf.

Ingredient rules:
- Drop redundant or implied words when they add no meaning in Spanish.
  * "all-purpose flour" -> "harina de trigo" (not "harina para todo uso")
  * "heavy cream" -> "crema de leche" (not "crema pesada")
  * "unsalted butter" -> "mantequilla sin sal"
  * "baby spinach, stems removed" -> "espinaca baby sin tallo"
- Preserve key cooking qualifiers: fresh/dry, skinless/boneless, raw/cooked, whole/ground.
- For cuts of meat, use the LATAM supermarket name, not a literal translation.
  * "chicken thighs" -> "muslos de pollo" or "pernil de pollo" depending on cut
  * "pork belly" -> "panceta de cerdo"
- For uncommon ingredients in LATAM, add a short clarification in parentheses.
  * "pine nuts" -> "piñones (nueces de pino)"
  * "tahini" -> "tahini (pasta de ajonjolí)"
  * "miso paste" -> "pasta miso"
- Keep brand names and proper nouns unchanged.
- Never invent substitutions or omit ingredients.
- Output ONLY a valid JSON array of strings, same order and length as input. No markdown, no labels, no explanations.
''';
    }

    if (isTitleContext) {
      return '''
You are a professional culinary translator for a recipe app targeting Latin American Spanish speakers.
Translate recipe titles from $sourceLanguage to $targetLanguage.

Your goal is a title that sounds APPETIZING and NATURAL in Spanish - not a literal translation.

Title rules:
- Think of how a cooking magazine or food blog in Colombia/LATAM would name the dish.
- If a dish has a well-known Spanish name, use it.
  * "Beef Stew" -> "Estofado de res" (not "Guiso de carne de vaca")
  * "Scrambled Eggs" -> "Huevos revueltos"
  * "Pulled Pork" -> "Cerdo desmechado"
- Preserve key ingredients or descriptors that define the dish (crispy, creamy, spicy, etc.).
- Avoid awkward literal phrasing that no native speaker would say.
- Keep the title concise and appealing.
- Output ONLY a valid JSON array of strings, same order and length as input. No markdown, no labels, no explanations.
''';
    }

    if (isInstructionContext) {
      return '''
You are a professional culinary translator for a recipe app targeting Latin American Spanish speakers.
Translate cooking instructions from $sourceLanguage to $targetLanguage.

Your goal is clear, NATURAL cooking language - as if written by a LATAM recipe author, not translated by a machine.

Instruction rules:
- Use imperative cooking verbs naturally.
  * "Fold in" -> "Incorpora con movimientos envolventes" (not "Dobla adentro")
  * "Sauté" -> "Sofríe" or "Saltea"
  * "Simmer" -> "Cocina a fuego lento"
  * "Deglaze" -> "Desglasa"
  * "Whisk" -> "Bate" or "Mezcla con batidor de globo"
- Preserve all quantities, temperatures, and times exactly as given.
- Preserve the sequence of steps - do not reorder or summarize.
- Use natural connectors and transitions (Luego, A continuación, Una vez que...).
- Never add commentary, app UI text, or translation notes.
- Output ONLY a valid JSON array of strings, same order and length as input. No markdown, no labels, no explanations.
''';
    }

    return '''
You are a professional translator for a cooking app targeting Latin American Spanish speakers.
Translate from $sourceLanguage to $targetLanguage.
Context: $context.

Use natural, contextual translation - not literal word-for-word.
Adapt phrasing so it sounds native and idiomatic in LATAM Spanish.
Output ONLY a valid JSON array of strings, same order and length as input. No markdown, no labels, no explanations.
''';
  }

  String _buildUnifiedSystemPrompt({
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    return '''
You are a professional culinary translator for a recipe app targeting Latin American Spanish speakers.
Translate from $sourceLanguage to $targetLanguage.

CRITICAL: Use the SAME translation for any ingredient or dish that appears in multiple sections.
If a term appears in titles, ingredients and instructions, keep it consistent everywhere.

Return ONLY valid JSON, with no markdown, no labels and no explanations.
''';
  }

  String _buildUnifiedPrompt({
    required String sourceLanguage,
    required String targetLanguage,
    required List<String> titles,
    required List<String> ingredients,
    required List<String> instructions,
  }) {
    return '''
Translate from $sourceLanguage to $targetLanguage.

Rules per section:
- titles: Appetizing, natural dish names in LATAM Spanish.
- ingredients: Natural supermarket-style ingredient labels in LATAM Spanish.
- instructions: Clear imperative cooking steps in LATAM Spanish.
- Preserve quantities, temperatures and times exactly.
- Preserve order and list length exactly for each section.

Input JSON object:
${jsonEncode({'titles': titles, 'ingredients': ingredients, 'instructions': instructions})}

Output ONLY a valid JSON object with keys "titles", "ingredients", "instructions".
''';
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

  String _extractRemoteMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is String) return error;
      if (error is Map<String, dynamic>) {
        final nested = error['message'];
        if (nested is String) return nested;
      }
      final message = data['message'];
      if (message is String) return message;
    }

    return '';
  }

  _AiTranslationRemoteException _buildRemoteExceptionForModel(
    String model,
    DioException e,
  ) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    final details = responseData?.toString() ?? e.message ?? 'Error remoto';
    final remoteMessage = _extractRemoteMessage(responseData);

    if (statusCode == 401 || statusCode == 403) {
      _lastWarning =
          'La traduccion IA fallo: token de OpenRouter invalido o sin permisos.';
    } else if (statusCode == 402) {
      _lastWarning =
          'La traduccion IA fallo: esta cuenta de OpenRouter requiere pago para ese endpoint.';
    } else if (statusCode == 429) {
      _lastWarning =
          'La traduccion IA fallo: limite de requests en OpenRouter (429).';
    } else if (statusCode == 404) {
      _lastWarning =
          'La traduccion IA fallo en OpenRouter (404). Revisa la URL base del endpoint.';
    } else if (statusCode == 400 &&
        remoteMessage.toLowerCase().contains('not a chat model')) {
      _lastWarning =
          'La traduccion IA fallo: el modelo seleccionado no es compatible con chat completions.';
    } else if (statusCode == 400 &&
        remoteMessage.toLowerCase().contains('not supported by any provider')) {
      _lastWarning =
          'La traduccion IA fallo: el modelo no esta disponible en el proveedor configurado.';
    } else {
      _lastWarning =
          'La traduccion IA fallo en OpenRouter (${statusCode ?? 'sin-codigo'}).';
    }

    return _AiTranslationRemoteException(
      'Modelo $model. ${_lastWarning!} '
      'Detalle: ${remoteMessage.isNotEmpty ? remoteMessage : details}',
    );
  }

  String _postProcessTranslation({
    required String translated,
    required String sourceLanguage,
    required String targetLanguage,
    required String context,
  }) {
    final source = sourceLanguage.toLowerCase();
    final target = targetLanguage.toLowerCase();
    final isIngredientContext = context.toLowerCase().contains('ingredient');

    if (!(source == 'english' && target == 'spanish' && isIngredientContext)) {
      return translated;
    }

    var result = translated.trim();

    // Avoid overly literal phrasing for common grocery labels.
    result = result.replaceAll(
      RegExp(
        r'^espinacas? pequeñ(?:a|as)\s+con\s+tallos?\s+quitados?$',
        caseSensitive: false,
      ),
      'espinaca baby sin tallo',
    );

    // Clarify uncommon ingredient names for users.
    if (RegExp(r'\bpiñones?\b', caseSensitive: false).hasMatch(result) &&
        !RegExp(
          r'nueces?\s+de\s+pino',
          caseSensitive: false,
        ).hasMatch(result)) {
      result = result.replaceAll(
        RegExp(r'\bpiñones?\b', caseSensitive: false),
        'nueces de pino (piñones)',
      );
    }

    return result;
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
