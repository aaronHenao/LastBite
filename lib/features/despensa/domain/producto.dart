class Producto {
  final String id;
  final String nombre;
  final String emoji;
  final String categoria;
  final String cantidad;
  final DateTime fechaCaducidad;
  final bool esFresco;
  final String? codigoBarras;
  final String? imagenUrl;

  Producto({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.categoria,
    required this.cantidad,
    required this.fechaCaducidad,
    required this.esFresco,
    this.codigoBarras,
    this.imagenUrl,
  });

  int get diasRestantes => fechaCaducidad.difference(DateTime.now()).inDays;

  bool get urgente => diasRestantes <= 3;
  bool get critico => diasRestantes <= 1;
  bool get vencido => diasRestantes < 0;

  /// Dos productos son el mismo si coinciden los campos que se guardan. Sin
  /// esto, comparar dos listas de productos siempre daba distinto y cualquier
  /// re-emision del stream de Firestore se tomaba como un cambio real.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Producto &&
          other.id == id &&
          other.nombre == nombre &&
          other.emoji == emoji &&
          other.categoria == categoria &&
          other.cantidad == cantidad &&
          other.fechaCaducidad == fechaCaducidad &&
          other.esFresco == esFresco &&
          other.codigoBarras == codigoBarras &&
          other.imagenUrl == imagenUrl;

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    emoji,
    categoria,
    cantidad,
    fechaCaducidad,
    esFresco,
    codigoBarras,
    imagenUrl,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'emoji': emoji,
      'categoria': categoria,
      'cantidad': cantidad,
      'fechaCaducidad': fechaCaducidad.toIso8601String(),
      'esFresco': esFresco,
      'codigoBarras': codigoBarras,
      'imagenUrl': imagenUrl,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      emoji: map['emoji'] as String,
      categoria: map['categoria'] as String,
      cantidad: map['cantidad'] as String,
      fechaCaducidad: DateTime.parse(map['fechaCaducidad'] as String),
      esFresco: map['esFresco'] as bool,
      codigoBarras: map['codigoBarras'] as String?,
      imagenUrl: map['imagenUrl'] as String?,
    );
  }
}
