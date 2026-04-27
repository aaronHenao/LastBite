import 'package:dio/dio.dart';

import 'ai_translation_data_source.dart';
import 'services/recetas_microservice.dart';
import 'services/spoon_microservice.dart';
import 'services/translation_microservice.dart';

class RecetasDetalleRemoteDataSource {
  RecetasDetalleRemoteDataSource({
    Dio? dio,
    String? apiKey,
    AiTranslationDataSource? translator,
  }) : _service = RecetasService(
         spoon: SpoonService(dio: dio, apiKey: apiKey),
         translation: TranslationService(translator: translator),
       );

  final RecetasService _service;

  String? get lastTranslationWarning => _service.lastTranslationWarning;

  Future<Map<String, dynamic>> obtenerDetalleRecetaRaw({
    required int recetaId,
  }) async {
    return _service.obtenerDetalleRecetaRaw(recetaId: recetaId);
  }
}
