import 'package:dio/dio.dart';

/// Ilustraciones de platos generadas con IA (NVIDIA NIM, FLUX.2 klein).
///
/// Se eligio sobre fotos de banco porque una foto "parecida" casi nunca era
/// el plato de la receta; una ilustracion sencilla se genera a partir de la
/// propia receta. Tarda ~1,7 s y las de una busqueda se piden en paralelo.
///
/// Devuelve la imagen como data URI (`data:image/jpeg;base64,...`, ~60 KB):
/// asi viaja dentro de `Receta.imagenUrl` y queda guardada con la receta en
/// la cache y en las alertas sin necesitar Firebase Storage.
///
/// Cada imagen es una llamada mas a la API (creditos): solo se genera una vez
/// por receta, despues sale de la cache.
class ImagenesRecetasService {
  ImagenesRecetasService({Dio? dio, String? apiKey, String? modelo})
    : _dio = dio ?? Dio(),
      _apiKey = apiKey ?? const String.fromEnvironment('NVIDIA_API_KEY'),
      _modelo = modelo ?? _modeloConfigurado;

  /// Probado con la cuenta del proyecto: flux.2-klein-4b ~1,7 s por imagen;
  /// flux.1-dev ~9,5 s; stable-diffusion-3 y sdxl dan 404.
  static const _modeloConfigurado = String.fromEnvironment(
    'NVIDIA_IMAGE_MODEL',
    defaultValue: 'black-forest-labs/flux.2-klein-4b',
  );

  static const _baseUrl = String.fromEnvironment(
    'NVIDIA_IMAGE_BASE_URL',
    defaultValue: 'https://ai.api.nvidia.com/v1/genai',
  );

  /// Estilo fijo para que todas las recetas se vean de la misma familia. El
  /// modelo entiende mucho mejor una descripcion visual en ingles que el
  /// nombre del plato en español.
  static const _estilo =
      'Cute flat vector illustration, food icon style, bold outlines, '
      'simple shapes, soft pastel background, centered, no text. ';

  final Dio _dio;
  final String _apiKey;
  final String _modelo;

  // Misma descripcion en la sesion = misma imagen, sin otra llamada.
  static final Map<String, String?> _porDescripcion = {};

  /// null si no hay key, si falla o si el filtro de contenido de NVIDIA la
  /// bloquea (pasa con falsos positivos): la UI pone un emoji.
  Future<String?> generar(String descripcion, {int semilla = 0}) async {
    final limpia = descripcion.trim();
    if (limpia.isEmpty || _apiKey.trim().isEmpty) return null;
    if (_porDescripcion.containsKey(limpia)) return _porDescripcion[limpia];

    String? imagen;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/$_modelo',
        data: {
          'prompt': '$_estilo$limpia',
          // El modelo solo acepta ciertos tamaños (minimo 512 de alto).
          'width': 768,
          'height': 512,
          'seed': semilla,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final artifacts = response.data?['artifacts'];
      if (artifacts is List && artifacts.isNotEmpty) {
        final artefacto = artifacts.first as Map?;
        final base64 = artefacto?['base64']?.toString() ?? '';
        if (artefacto?['finishReason'] == 'SUCCESS' && base64.isNotEmpty) {
          imagen = 'data:image/jpeg;base64,$base64';
        }
      }
    } catch (_) {
      // Sin imagen la receta sigue sirviendo.
    }

    _porDescripcion[limpia] = imagen;
    return imagen;
  }
}
