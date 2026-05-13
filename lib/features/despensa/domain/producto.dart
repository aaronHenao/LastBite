class Producto {
  final String id;
  final String nombre;
  final String emoji;
  final String categoria;
  final String cantidad;
  final DateTime fechaCaducidad;
  final bool esFresco;
  final String? codigoBarras;

  Producto({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.categoria,
    required this.cantidad,
    required this.fechaCaducidad,
    required this.esFresco,
    this.codigoBarras,
  });

  int get diasRestantes => fechaCaducidad.difference(DateTime.now()).inDays;

  bool get urgente => diasRestantes <= 3;
  bool get critico => diasRestantes <= 1;
  bool get vencido => diasRestantes < 0;

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
    );
  }
}
