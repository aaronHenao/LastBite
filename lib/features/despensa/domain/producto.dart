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
}
