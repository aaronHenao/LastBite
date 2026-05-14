import 'package:dio/dio.dart';

import '../services/recetas_service.dart';
import '../services/spoon_service.dart';

const int _maxRecetasPorBusqueda = RecetasService.maxRecetasPorBusqueda;

class RecetasBusquedaRemoteDataSource {
  RecetasBusquedaRemoteDataSource({
    Dio? dio,
    String? apiKey,
  }) : _service = RecetasService(
         spoon: SpoonService(dio: dio, apiKey: apiKey),
       );

  final RecetasService _service;

  Future<List<Map<String, dynamic>>> buscarRecetasPorDespensaRaw({
    required List<String> productosDespensa,
    int number = 3,
    bool ignorePantry = false,
  }) async {
    final raw = await _service.buscarRecetasPorDespensaRaw(
      productosDespensa: productosDespensa,
      number: number,
      ignorePantry: ignorePantry,
    );

    return raw.take(_maxRecetasPorBusqueda).toList();
  }
}
