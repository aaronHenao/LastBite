import 'package:dio/dio.dart';
import '../services/recetas_service.dart';
import '../services/spoon_service.dart';
import '../datasources/my_memory_translate_service.dart';

class RecetasBusquedaRemoteDataSource {
  RecetasBusquedaRemoteDataSource({Dio? dio, String? apiKey})
      : _service = RecetasService(
          spoon: SpoonService(dio: dio, apiKey: apiKey),
          translator: MyMemoryTranslateService(dio: dio),
        );

  final RecetasService _service;

  String? get lastTranslationWarning => _service.lastTranslationWarning;

  Future<List<Map<String, dynamic>>> buscarRecetasPorDespensaRaw({
    required List<String> productosDespensa,
    int number = 3,
    bool ignorePantry = false,
  }) {
    return _service.buscarRecetasPorDespensaRaw(
      productosDespensa: productosDespensa,
      number: number,
      ignorePantry: ignorePantry,
    );
  }
}