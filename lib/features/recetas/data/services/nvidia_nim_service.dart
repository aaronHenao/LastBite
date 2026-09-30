import 'dart:convert';

import 'package:dio/dio.dart';

import '../datasources/recetas_remote_exception.dart';

/// Cliente de NVIDIA NIM (API compatible con OpenAI).
///
/// La key llega por `--dart-define=NVIDIA_API_KEY=...`. El modelo y la URL
/// base tambien se pueden cambiar sin tocar codigo: la URL existe porque la
/// API no manda cabeceras CORS y en web hay que pasar por un proxy propio.
class NvidiaNimService {
  NvidiaNimService({Dio? dio, String? apiKey, String? modelo, String? baseUrl})
    : _dio = dio ?? Dio(),
      _apiKey = apiKey ?? const String.fromEnvironment('NVIDIA_API_KEY'),
      _modelo = modelo ?? _modeloConfigurado,
      _baseUrl = baseUrl ?? _baseUrlConfigurada;

  /// Probado con la cuenta del proyecto (sep. 2026): de los modelos que
  /// responden, es el unico que genera 3 recetas en ~10 s. Mistral, Llama y
  /// Qwen dan 404 o 410 (retirados); Gemma 4 tarda mas de 50 s.
  static const _modeloConfigurado = String.fromEnvironment(
    'NVIDIA_MODEL',
    defaultValue: 'openai/gpt-oss-20b',
  );

  static const _baseUrlConfigurada = String.fromEnvironment(
    'NVIDIA_BASE_URL',
    defaultValue: 'https://integrate.api.nvidia.com/v1',
  );

  final Dio _dio;
  final String _apiKey;
  final String _modelo;
  final String _baseUrl;

  /// Respuesta del modelo en streaming: cada evento es **todo el texto
  /// recibido hasta ahora**. Asi la pantalla puede mostrar la primera receta
  /// en cuanto esta completa (3-9 s) en vez de esperar las tres (9-21 s).
  ///
  /// [esquemaJson] obliga al modelo a responder JSON valido con esa forma
  /// (`response_format: json_schema`). Sin el, gpt-oss-20b devolvia JSON roto
  /// en ~1 de cada 5 respuestas. Si el modelo configurado no lo soporta (400)
  /// se reintenta una vez sin el.
  ///
  /// En web Dio no entrega el cuerpo por partes: llega un solo evento al
  /// final, que funciona igual.
  Stream<String> completarStream({
    required String sistema,
    required String usuario,
    int maxTokens = 2000,
    double temperatura = 0.5,
    Map<String, dynamic>? esquemaJson,
  }) async* {
    try {
      yield* _stream(
        sistema: sistema,
        usuario: usuario,
        maxTokens: maxTokens,
        temperatura: temperatura,
        esquemaJson: esquemaJson,
      );
    } on RecetasRemoteException catch (e) {
      if (esquemaJson == null || e.statusCode != 400) rethrow;
      yield* _stream(
        sistema: sistema,
        usuario: usuario,
        maxTokens: maxTokens,
        temperatura: temperatura,
      );
    }
  }

  Stream<String> _stream({
    required String sistema,
    required String usuario,
    required int maxTokens,
    required double temperatura,
    Map<String, dynamic>? esquemaJson,
  }) async* {
    if (_apiKey.trim().isEmpty) {
      throw const RecetasRemoteException(
        message:
            'Falta la clave de la IA. Ejecuta la app con '
            '--dart-define-from-file=env.json',
      );
    }

    final Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        '$_baseUrl/chat/completions',
        data: {
          'model': _modelo,
          'messages': [
            {'role': 'system', 'content': sistema},
            {'role': 'user', 'content': usuario},
          ],
          'temperature': temperatura,
          'max_tokens': maxTokens,
          'stream': true,
          // gpt-oss razona antes de responder: con el esfuerzo por defecto
          // tardaba ~85 s y gastaba 2.000 tokens pensando; en bajo, ~10 s.
          if (_modelo.contains('gpt-oss')) 'reasoning_effort': 'low',
          if (esquemaJson != null)
            'response_format': {
              'type': 'json_schema',
              'json_schema': {'name': 'respuesta', 'schema': esquemaJson},
            },
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 90),
        ),
      );
    } on DioException catch (e) {
      throw RecetasRemoteException(
        statusCode: e.response?.statusCode,
        message: mensajeErrorNim(e),
      );
    }

    final body = response.data;
    if (body == null) {
      throw const RecetasRemoteException(
        message: 'La IA respondió vacío. Intenta de nuevo.',
      );
    }

    final texto = StringBuffer();
    try {
      final lineas = body.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final linea in lineas) {
        if (!linea.startsWith('data:')) continue;
        final dato = linea.substring(5).trim();
        if (dato == '[DONE]') break;

        final Object? evento;
        try {
          evento = jsonDecode(dato);
        } on FormatException {
          continue;
        }
        if (evento is! Map) continue;
        final choices = evento['choices'];
        if (choices is! List || choices.isEmpty) continue;
        final delta = (choices.first as Map?)?['delta'];
        final contenido = (delta as Map?)?['content'];
        if (contenido is String && contenido.isNotEmpty) {
          texto.write(contenido);
          yield texto.toString();
        }
      }
    } on DioException catch (e) {
      throw RecetasRemoteException(
        statusCode: e.response?.statusCode,
        message: mensajeErrorNim(e),
      );
    }

    if (texto.isEmpty) {
      throw const RecetasRemoteException(
        message: 'La IA respondió vacío. Intenta de nuevo.',
      );
    }
  }
}

/// Mensaje en español para un error de cualquier endpoint de NVIDIA.
String mensajeErrorNim(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'La IA tardó demasiado en responder. Intenta de nuevo.';
    case DioExceptionType.connectionError:
      return 'No hay conexión con el servicio de recetas. Revisa tu internet.';
    default:
      break;
  }

  return switch (e.response?.statusCode) {
    401 || 403 => 'La clave de la IA no es válida o expiró.',
    402 => 'Se agotaron los créditos del servicio de IA.',
    404 => 'El modelo de IA configurado no existe.',
    410 => 'El modelo de IA configurado fue retirado por NVIDIA.',
    429 => 'Demasiadas consultas a la IA. Espera un momento.',
    final int code when code >= 500 =>
      'El servicio de IA no está disponible ahora mismo.',
    _ => 'No se pudieron generar recetas.',
  };
}
