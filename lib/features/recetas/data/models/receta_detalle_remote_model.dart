class RecetaDetalleRemoteModel {
  const RecetaDetalleRemoteModel({
    required this.informacion,
    required this.ingredientes,
    required this.equipamiento,
  });

  final RecetaInfoRemoteModel informacion;
  final List<String> ingredientes;
  final List<String> equipamiento;

  factory RecetaDetalleRemoteModel.fromApiRaw(Map<String, dynamic> raw) {
    final informationRaw = raw['information'];
    final equipmentRaw = raw['equipment'];

    if (informationRaw is! Map<String, dynamic>) {
      throw const FormatException('Campo information invalido en respuesta raw');
    }

    if (equipmentRaw is! Map<String, dynamic>) {
      throw const FormatException('Campo equipment invalido en respuesta raw');
    }

    final info = RecetaInfoRemoteModel.fromJson(informationRaw);

    return RecetaDetalleRemoteModel(
      informacion: info,
      ingredientes: info.ingredientes,
      equipamiento: _parsearEquipamiento(equipmentRaw),
    );
  }

  static List<String> _parsearEquipamiento(Map<String, dynamic> json) {
    final raw = json['equipment'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }
}

class RecetaInfoRemoteModel {
  const RecetaInfoRemoteModel({
    required this.id,
    required this.titulo,
    required this.imagenUrl,
    required this.minutosPreparacion,
    required this.porciones,
    required this.likes,
    required this.ingredientes,
    required this.instrucciones,
  });

  final int id;
  final String titulo;
  final String imagenUrl;
  final int? minutosPreparacion;
  final int? porciones;
  final int likes;
  final List<String> ingredientes;
  final String? instrucciones;

  factory RecetaInfoRemoteModel.fromJson(Map<String, dynamic> json) {
    final rawIngredientes = json['extendedIngredients'];
    final ingredientes = rawIngredientes is List
        ? rawIngredientes
            .whereType<Map<String, dynamic>>()
            .map((item) => item['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList()
        : <String>[];

    return RecetaInfoRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: json['title']?.toString() ?? '',
      imagenUrl: json['image']?.toString() ?? '',
      minutosPreparacion: (json['readyInMinutes'] as num?)?.toInt(),
      porciones: (json['servings'] as num?)?.toInt(),
      likes: (json['aggregateLikes'] as num?)?.toInt() ?? 0,
      ingredientes: ingredientes,
      instrucciones: json['instructions']?.toString(),
    );
  }
}
