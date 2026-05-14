import 'package:dio/dio.dart';
import '../services/recetas_service.dart';
import '../services/spoon_service.dart';
import '../datasources/my_memory_translate_service.dart';

class RecetasDetalleRemoteDataSource {
  RecetasDetalleRemoteDataSource({Dio? dio, String? apiKey})
      : _service = RecetasService(
          spoon: SpoonService(dio: dio, apiKey: apiKey),
          translator: MyMemoryTranslateService(dio: dio),
        );

  final RecetasService _service;

  String? get lastTranslationWarning => _service.lastTranslationWarning;

  Future<Map<String, dynamic>> obtenerDetalleRecetaRaw({
    required int recetaId,
  }) {
    return _service.obtenerDetalleRecetaRaw(recetaId: recetaId);
  }
}
