import 'package:dio/dio.dart';
import '../../despensa/domain/producto.dart';
import '../../../core/constants/vida_util.dart';
import '../../../core/utils/categoria_mapper.dart';

/// Se lanza cuando ninguna consulta llego a responder. Distinta de devolver
/// null, que significa que el producto no existe en el catalogo: antes ambos
/// casos se mostraban como "producto no encontrado" y mandaban al usuario a
/// tipear todo a mano por un problema de red.
class SinConexionException implements Exception {
  const SinConexionException();

  @override
  String toString() => 'Sin conexión con el catálogo de productos.';
}

class OpenFoodFactsService {
  final _dio = Dio();

  Future<Producto?> buscarPorCodigo(String codigoBarras) async {
    // Intentamos en este orden: Colombia → mundial
    final urls = [
      'https://co.openfoodfacts.org/api/v2/product/$codigoBarras.json',
      'https://world.openfoodfacts.org/api/v2/product/$codigoBarras.json',
    ];

    var falloLaRed = false;

    for (final url in urls) {
      try {
        final response = await _dio.get(
          url,
          queryParameters: {
            'fields':
                'product_name,categories_tags_en,image_front_url,quantity',
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
          emoji: emojiParaCategoria(categoria),
          categoria: categoria,
          cantidad: cantidad,
          fechaCaducidad: fechaCaducidad,
          esFresco: esCategoriaFresca(categoria),
          imagenUrl: imagenUrl,
        );
      } on DioException {
        falloLaRed = true;
        continue; // ← si falla la red prueba la siguiente
      } catch (_) {
        continue;
      }
    }

    if (falloLaRed) throw const SinConexionException();
    return null; // ninguna URL encontró el producto
  }

}
