class Receta {
  final int id;
  final String titulo;
  /// URL http(s) o data URI (`data:image/jpeg;base64,...`) de la ilustracion
  /// generada por IA. Ver `ImagenesRecetasService`.
  final String imagenUrl;
  final int ingredientesUsados; // cuántos hay en la despensa
  final int ingredientesFaltantes; // cuántos faltan para prepararla
  final int likes;

  // detalle (las recetas de IA los traen desde la busqueda)
  final int? minutosPreparacion;
  final List<String>? dishTypes;
  final int? porciones;
  final List<String>? ingredientes;
  final String? instrucciones;

  Receta({
    required this.id,
    required this.titulo,
    required this.imagenUrl,
    required this.ingredientesUsados,
    required this.ingredientesFaltantes,
    required this.likes,
    this.minutosPreparacion,
    this.dishTypes,
    this.porciones,
    this.ingredientes,
    this.instrucciones,
  });

  // Qué tan bien hace match con la despensa del usuario
  int get porcentajeMatch {
    final total = ingredientesUsados + ingredientesFaltantes;
    if (total == 0) return 0;
    return ((ingredientesUsados / total) * 100).round();
  }

  Map<String, dynamic> toMap({List<String> ingredientesUrgentesUsados = const []}) {
  return {
    'id': id,
    'titulo': titulo,
    'imagenUrl': imagenUrl,
    'ingredientesUsados': ingredientesUsados,
    'ingredientesFaltantes': ingredientesFaltantes,
    'likes': likes,
    'minutosPreparacion': minutosPreparacion,
    'dishTypes': dishTypes,
    'porciones': porciones,
    'ingredientes': ingredientes,
    'instrucciones': instrucciones,
    'ingredientesUrgentesUsados': ingredientesUrgentesUsados,
    'creadoEn': DateTime.now().toIso8601String(),
  };
}

factory Receta.fromMap(Map<String, dynamic> map) {
  // Tolerante: la cache guarda recetas de versiones anteriores y un campo
  // null no debe tumbar toda la lista.
  int? entero(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');

  return Receta(
    id: entero(map['id']) ?? 0,
    titulo: map['titulo']?.toString() ?? '',
    imagenUrl: map['imagenUrl']?.toString() ?? '',
    ingredientesUsados: entero(map['ingredientesUsados']) ?? 0,
    ingredientesFaltantes: entero(map['ingredientesFaltantes']) ?? 0,
    likes: entero(map['likes']) ?? 0,
    minutosPreparacion: entero(map['minutosPreparacion']),
    dishTypes: (map['dishTypes'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    porciones: entero(map['porciones']),
    ingredientes: (map['ingredientes'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    instrucciones: map['instrucciones']?.toString(),
  );
}

// Lista de ingredientes urgentes usados — para invalidación del caché
List<String> ingredientesUrgentesFromMap(Map<String, dynamic> map) {
  return (map['ingredientesUrgentesUsados'] as List?)
      ?.map((e) => e.toString())
      .toList() ?? [];
}
}
