import 'package:dio/dio.dart';
import '../../despensa/domain/producto.dart';
import '../../../core/constants/vida_util.dart';
import '../../../core/utils/categoria_mapper.dart';

class OpenFoodFactsService {
  final _dio = Dio();

  Future<Producto?> buscarPorCodigo(String codigoBarras) async {
  // Intentamos en este orden: Colombia → mundial
  final urls = [
    'https://co.openfoodfacts.org/api/v2/product/$codigoBarras.json',
    'https://world.openfoodfacts.org/api/v2/product/$codigoBarras.json',
  ];

  for (final url in urls) {
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'fields': 'product_name,categories_tags_en,image_front_url,quantity',
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['status'] != 1) continue; // ← prueba la siguiente URL

      final product = data['product'] as Map<String, dynamic>;
      final nombre = product['product_name']?.toString() ?? '';
      if (nombre.trim().isEmpty) continue;

      final categoriasRaw = product['categories_tags_en'];
      final categorias = categoriasRaw is List
          ? categoriasRaw.map((e) => e.toString()).toList()
          : <String>[];
      final categoria = mapearCategoria(categorias);

      final dias = vidaUtilPorCategoria[categoria] ?? 7;
      final fechaCaducidad = DateTime.now().add(Duration(days: dias));
      final imagenUrl = product['image_front_url']?.toString();
      final cantidad = product['quantity']?.toString() ?? '1 unidad';

      return Producto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        emoji: _emojiParaCategoria(categoria),
        categoria: categoria,
        cantidad: cantidad,
        fechaCaducidad: fechaCaducidad,
        esFresco: categoria == 'fruta' || categoria == 'verdura',
        imagenUrl: imagenUrl,
      );
    } on DioException {
      continue; // ← si falla la red prueba la siguiente
    } catch (_) {
      continue;
    }
  }

  return null; // ninguna URL encontró el producto
}

  String _emojiParaCategoria(String categoria) {
    switch (categoria) {
      case 'Verdura':     return '🥦';
      case 'Fruta':       return '🍎';
      case 'Pollo':       return '🍗';
      case 'Carne':       return '🥩';
      case 'Pescado':     return '🐟';
      case 'Huevo':       return '🥚';
      case 'Leche':       return '🥛';
      case 'Yogur':       return '🥛';
      case 'Queso':       return '🧀';
      case 'Mantequilla': return '🧈';
      case 'Pan':         return '🍞';
      case 'Grano':       return '🍝';
      case 'Jugo':        return '🧃';
      case 'Embutido':    return '🌭';
      case 'Conserva':    return '🥫';
      default:            return '🥫';
    }
  }
}