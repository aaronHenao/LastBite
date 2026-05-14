import 'package:dio/dio.dart';

import '../services/recetas_service.dart';
import '../services/spoon_service.dart';

class RecetasDetalleRemoteDataSource {
  RecetasDetalleRemoteDataSource({
    Dio? dio,
    String? apiKey,
  }) : _service = RecetasService(
         spoon: SpoonService(dio: dio, apiKey: apiKey),
       );

  final RecetasService _service;

  Future<Map<String, dynamic>> obtenerDetalleRecetaRaw({
    required int recetaId,
  }) async {
    return _service.obtenerDetalleRecetaRaw(recetaId: recetaId);
  }
}
