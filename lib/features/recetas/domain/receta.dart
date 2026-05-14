class Receta {
  final int id;
  final String titulo;
  final String imagenUrl;
  final int ingredientesUsados; // cuántos hay en la despensa
  final int ingredientesFaltantes; // cuántos faltan para prepararla
  final int likes;

  // segundo endpoint (detalle)
  final int? minutosPreparacion;
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
    'porciones': porciones,
    'ingredientes': ingredientes,
    'instrucciones': instrucciones,
    'ingredientesUrgentesUsados': ingredientesUrgentesUsados,
    'creadoEn': DateTime.now().toIso8601String(),
  };
}

factory Receta.fromMap(Map<String, dynamic> map) {
  return Receta(
    id: map['id'] as int,
    titulo: map['titulo'] as String,
    imagenUrl: map['imagenUrl'] as String,
    ingredientesUsados: map['ingredientesUsados'] as int,
    ingredientesFaltantes: map['ingredientesFaltantes'] as int,
    likes: map['likes'] as int,
    minutosPreparacion: map['minutosPreparacion'] as int?,
    porciones: map['porciones'] as int?,
    ingredientes: (map['ingredientes'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    instrucciones: map['instrucciones'] as String?,
  );
}

// Lista de ingredientes urgentes usados — para invalidación del caché
List<String> ingredientesUrgentesFromMap(Map<String, dynamic> map) {
  return (map['ingredientesUrgentesUsados'] as List?)
      ?.map((e) => e.toString())
      .toList() ?? [];
}
}
