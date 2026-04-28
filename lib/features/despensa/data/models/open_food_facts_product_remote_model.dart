import '../../domain/info_nutricional.dart';

class OpenFoodFactsProductRemoteModel {
  OpenFoodFactsProductRemoteModel({
    this.nombre,
    this.marcas,
    this.porcion,
    required this.nutriments,
  });

  final String? nombre;
  final String? marcas;
  final String? porcion;
  final Map<String, dynamic> nutriments;

  static OpenFoodFactsProductRemoteModel? fromApiRaw(Map<String, dynamic> raw) {
    final status = raw['status'];
    if (status is num && status == 0) {
      return null;
    }

    final product = raw['product'];
    if (product is! Map<String, dynamic>) {
      return null;
    }

    return OpenFoodFactsProductRemoteModel(
      nombre: (product['product_name_es'] ?? product['product_name'])
          ?.toString(),
      marcas: product['brands']?.toString(),
      porcion: product['serving_size']?.toString(),
      nutriments: _asMap(product['nutriments']),
    );
  }

  InfoNutricional toDomain() {
    return InfoNutricional(
      nombreProducto: nombre,
      marcas: marcas,
      porcion: porcion,
      energiaKcal100g: _toDouble(nutriments['energy-kcal_100g']),
      grasas100g: _toDouble(nutriments['fat_100g']),
      grasasSaturadas100g: _toDouble(nutriments['saturated-fat_100g']),
      carbohidratos100g: _toDouble(nutriments['carbohydrates_100g']),
      azucares100g: _toDouble(nutriments['sugars_100g']),
      proteinas100g: _toDouble(nutriments['proteins_100g']),
      sal100g: _toDouble(nutriments['salt_100g']),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
