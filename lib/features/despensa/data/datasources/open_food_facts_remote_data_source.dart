import '../models/open_food_facts_product_remote_model.dart';
import '../services/open_food_facts_service.dart';
import '../../domain/info_nutricional.dart';

class OpenFoodFactsRemoteDataSource {
  OpenFoodFactsRemoteDataSource({OpenFoodFactsService? service})
    : _service = service ?? OpenFoodFactsService();

  final OpenFoodFactsService _service;

  Future<InfoNutricional?> obtenerNutricionPorCodigo({
    required String codigo,
  }) async {
    final raw = await _service.getProductRaw(code: codigo);
    final model = OpenFoodFactsProductRemoteModel.fromApiRaw(raw);
    return model?.toDomain();
  }
}
