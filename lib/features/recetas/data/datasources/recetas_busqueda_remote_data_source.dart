import 'package:dio/dio.dart';

import 'ai_translation_data_source.dart';
import '../services/recetas_service.dart';
import '../services/spoon_service.dart';
import '../services/translation_service.dart';

const int _maxRecetasPorBusqueda = RecetasService.maxRecetasPorBusqueda;

class RecetasBusquedaRemoteDataSource {
  RecetasBusquedaRemoteDataSource({
    Dio? dio,
    String? apiKey,
    AiTranslationDataSource? translator,
  }) : _service = RecetasService(
         spoon: SpoonService(dio: dio, apiKey: apiKey),
         translation: TranslationService(translator: translator),
       );

  final RecetasService _service;

  String? get lastTranslationWarning => _service.lastTranslationWarning;

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
