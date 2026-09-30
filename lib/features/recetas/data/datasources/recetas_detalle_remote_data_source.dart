import 'package:dio/dio.dart';
import '../services/nvidia_nim_service.dart';
import '../services/recetas_service.dart';

class RecetasDetalleRemoteDataSource {
  RecetasDetalleRemoteDataSource({Dio? dio, String? apiKey})
    : _service = RecetasService(
        ia: NvidiaNimService(dio: dio, apiKey: apiKey),
      );

  final RecetasService _service;

  String? get lastTranslationWarning => _service.lastTranslationWarning;

  Future<Map<String, dynamic>> obtenerDetalleRecetaRaw({
    required int recetaId,
  }) {
    return _service.obtenerDetalleRecetaRaw(recetaId: recetaId);
  }
}
