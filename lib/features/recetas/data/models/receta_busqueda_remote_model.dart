import '../../domain/receta.dart';

class RecetaBusquedaRemoteModel {
  const RecetaBusquedaRemoteModel({
    required this.id,
    required this.titulo,
    required this.imagenUrl,
    required this.ingredientesUsados,
    required this.ingredientesFaltantes,
    required this.likes,
    required this.nombresIngredientesUsados,
    required this.nombresIngredientesFaltantes,
  });

  final int id;
  final String titulo;
  final String imagenUrl;
  final int ingredientesUsados;
  final int ingredientesFaltantes;
  final int likes;
  final List<String> nombresIngredientesUsados;
  final List<String> nombresIngredientesFaltantes;

  factory RecetaBusquedaRemoteModel.fromJson(Map<String, dynamic> json) {
    final used = (json['usedIngredients'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final missed = (json['missedIngredients'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final usadosNombres = used
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    final faltantesNombres = missed
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return RecetaBusquedaRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: json['title']?.toString() ?? '',
      imagenUrl: json['image']?.toString() ?? '',
      ingredientesUsados:
          (json['usedIngredientCount'] as num?)?.toInt() ??
          usadosNombres.length,
      ingredientesFaltantes:
          (json['missedIngredientCount'] as num?)?.toInt() ??
          faltantesNombres.length,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      nombresIngredientesUsados: usadosNombres,
      nombresIngredientesFaltantes: faltantesNombres,
    );
  }

  static List<RecetaBusquedaRemoteModel> fromApiRawList(
    List<Map<String, dynamic>> rawList,
  ) {
    return rawList.map(RecetaBusquedaRemoteModel.fromJson).toList();
  }

  Receta toDomain() {
    return Receta(
      id: id,
      titulo: titulo,
      imagenUrl: imagenUrl,
      ingredientesUsados: ingredientesUsados,
      ingredientesFaltantes: ingredientesFaltantes,
      likes: likes,
      ingredientes: [
        ...nombresIngredientesUsados,
        ...nombresIngredientesFaltantes,
      ],
    );
  }
}
