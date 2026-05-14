import 'package:dio/dio.dart';

class MyMemoryTranslateService {
  MyMemoryTranslateService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final Map<String, String> _cache = {};

  static const _baseUrl = 'https://api.mymemory.translated.net/get';

  // Traduce un texto con contexto culinario
  Future<String> traducir({
    required String texto,
    required String de,
    required String a,
    String? contexto,
  }) async {
    final trimmed = texto.trim();
    if (trimmed.isEmpty) return texto;

    final key = '$de→$a::$trimmed';
    if (_cache.containsKey(key)) return _cache[key]!;

    try {
      // MyMemory acepta un campo "context" que mejora la calidad
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {
          'q': trimmed,
          'langpair': '$de|$a',
          if (contexto != null) 'context': contexto,
          'de': 'lastbite@app.com', // mejora el rate limit
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      final data = response.data;
      final traducido =
          data?['responseData']?['translatedText']?.toString() ?? '';

      if (traducido.isEmpty || traducido == 'NULL') return trimmed;

      // MyMemory a veces devuelve el texto con "MYMEMORY WARNING" al final
      final limpio = _limpiarRespuesta(traducido);
      _cache[key] = limpio;
      return limpio;
    } on DioException {
      return trimmed; // fallback al original
    }
  }

  // Traduce una lista en paralelo
  Future<List<String>> traducirLista({
    required List<String> textos,
    required String de,
    required String a,
    String? contexto,
  }) async {
    if (textos.isEmpty) return textos;

    // Filtra los que ya están en caché
    final output = List<String>.from(textos);
    final futures = <Future<void>>[];

    for (var i = 0; i < textos.length; i++) {
      final index = i;
      final texto = textos[i].trim();
      if (texto.isEmpty) continue;

      final key = '$de→$a::$texto';
      if (_cache.containsKey(key)) {
        output[index] = _cache[key]!;
        continue;
      }

      futures.add(
        traducir(texto: texto, de: de, a: a, contexto: contexto).then((t) {
          output[index] = t;
        }),
      );
    }

    // Ejecuta en paralelo — mucho más rápido que secuencial
    await Future.wait(futures);
    return output;
  }

  // ── Helpers específicos para LastBite ──────────────────

  Future<List<String>> ingredientesEsAEn(List<String> ingredientes) =>
      traducirLista(
        textos: ingredientes,
        de: 'es',
        a: 'en',
        contexto: 'cooking ingredients pantry food',
      );

  Future<List<String>> ingredientesEnAEs(List<String> ingredientes) =>
      traducirLista(
        textos: ingredientes,
        de: 'en',
        a: 'es',
        contexto: 'recipe cooking ingredients latin american cuisine',
      );

  Future<String> tituloEnAEs(String titulo) => traducir(
        texto: titulo,
        de: 'en',
        a: 'es',
        contexto: 'recipe title latin american cooking food',
      );

  Future<String> instruccionesEnAEs(String instrucciones) => traducir(
        texto: instrucciones,
        de: 'en',
        a: 'es',
        contexto: 'cooking recipe preparation instructions chef latin america',
      );

  String _limpiarRespuesta(String texto) {
    return texto
        .replaceAll(RegExp(r'MYMEMORY WARNING.*$', multiLine: true), '')
        .trim();
  }
}