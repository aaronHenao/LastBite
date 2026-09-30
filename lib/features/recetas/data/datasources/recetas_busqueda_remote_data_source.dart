import 'package:dio/dio.dart';
import '../services/imagenes_recetas_service.dart';
import '../services/nvidia_nim_service.dart';
import '../services/recetas_service.dart';
import 'package:lastbite/features/perfil/domain/perfil_nutricional.dart';

class RecetasBusquedaRemoteDataSource {
  RecetasBusquedaRemoteDataSource({Dio? dio, String? apiKey})
    : _service = RecetasService(
        ia: NvidiaNimService(dio: dio, apiKey: apiKey),
        imagenes: ImagenesRecetasService(dio: dio, apiKey: apiKey),
      );

  final RecetasService _service;

  String? get lastTranslationWarning => _service.lastTranslationWarning;

  Future<List<Map<String, dynamic>>> buscarRecetasPorDespensaRaw({
    required List<String> productosDespensa,
    int number = 3,
    bool ignorePantry = false,
    PerfilNutricional? perfil,
    String? ingredientePrincipal,
  }) {
    return _service.buscarRecetasPorDespensaRaw(
      productosDespensa: productosDespensa,
      number: number,
      ignorePantry: ignorePantry,
      perfil: perfil,
      ingredientePrincipal: ingredientePrincipal,
    );
  }

  /// Emite la lista cada vez que llega una receta o su imagen.
  Stream<List<Map<String, dynamic>>> buscarRecetasPorDespensaStream({
    required List<String> productosDespensa,
    int number = 3,
    PerfilNutricional? perfil,
    String? ingredientePrincipal,
  }) {
    return _service.buscarRecetasPorDespensaStream(
      productosDespensa: productosDespensa,
      number: number,
      perfil: perfil,
      ingredientePrincipal: ingredientePrincipal,
    );
  }
}
