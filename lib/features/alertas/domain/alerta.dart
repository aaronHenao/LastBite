class Alerta {
  final String id;
  final String productoId;
  final String productoNombre;
  final String productoEmoji;
  final int umbral;
  final DateTime fechaCaducidad;
  final DateTime fechaCreacion;
  final String? recetaTitulo;
  final int? recetaSpoonId;
  final String? recetaImagen;

  const Alerta({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.productoEmoji,
    required this.umbral,
    required this.fechaCaducidad,
    required this.fechaCreacion,
    this.recetaTitulo,
    this.recetaSpoonId,
    this.recetaImagen,
  });

  int get diasRestantes =>
      fechaCaducidad.difference(DateTime.now()).inDays;

  Alerta copyWith({
    String? recetaTitulo,
    int? recetaSpoonId,
    String? recetaImagen,
  }) =>
      Alerta(
        id: id,
        productoId: productoId,
        productoNombre: productoNombre,
        productoEmoji: productoEmoji,
        umbral: umbral,
        fechaCaducidad: fechaCaducidad,
        fechaCreacion: fechaCreacion,
        recetaTitulo: recetaTitulo ?? this.recetaTitulo,
        recetaSpoonId: recetaSpoonId ?? this.recetaSpoonId,
        recetaImagen: recetaImagen ?? this.recetaImagen,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'productoId': productoId,
        'productoNombre': productoNombre,
        'productoEmoji': productoEmoji,
        'umbral': umbral,
        'fechaCaducidad': fechaCaducidad.toIso8601String(),
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'recetaTitulo': recetaTitulo,
        'recetaSpoonId': recetaSpoonId,
        'recetaImagen': recetaImagen,
      };

  factory Alerta.fromMap(Map<String, dynamic> map) => Alerta(
        id: map['id'] as String? ?? '',
        productoId: map['productoId'] as String? ?? '',
        productoNombre: map['productoNombre'] as String? ?? '',
        productoEmoji: map['productoEmoji'] as String? ?? '',
        umbral: (map['umbral'] as num?)?.toInt() ?? 5,
        fechaCaducidad: map['fechaCaducidad'] != null
            ? DateTime.parse(map['fechaCaducidad'] as String)
            : DateTime.now().add(const Duration(days: 5)),
        fechaCreacion: map['fechaCreacion'] != null
            ? DateTime.parse(map['fechaCreacion'] as String)
            : DateTime.now(),
        recetaTitulo: map['recetaTitulo'] as String?,
        recetaSpoonId: (map['recetaSpoonId'] as num?)?.toInt(),
        recetaImagen: map['recetaImagen'] as String?,
      );
}
