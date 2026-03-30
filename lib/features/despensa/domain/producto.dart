class Producto {
  final String id;
  final String nombre;
  final String emoji;
  final String categoria;
  final String cantidad;
  final DateTime fechaCaducidad;
  final bool esFresco;

  Producto({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.categoria,
    required this.cantidad,
    required this.fechaCaducidad,
    required this.esFresco,
  });

  int get diasRestantes => fechaCaducidad.difference(DateTime.now()).inDays;

  bool get urgente => diasRestantes <= 3;
  bool get critico => diasRestantes <= 1;
  bool get vencido => diasRestantes < 0;
}

//Datos quemados para probar pantalla
final productosEjemplo = [
  Producto(
    id: '1',
    nombre: 'Espinacas',
    emoji: '🥬',
    categoria: 'verdura',
    cantidad: '1 bolsa',
    fechaCaducidad: DateTime.now().add(const Duration(days: 1)),
    esFresco: true,
  ),
  Producto(
    id: '2',
    nombre: 'Tomates',
    emoji: '🍅',
    categoria: 'verdura',
    cantidad: '4 unidades',
    fechaCaducidad: DateTime.now().add(const Duration(days: 2)),
    esFresco: true,
  ),
  Producto(
    id: '3',
    nombre: 'Pollo',
    emoji: '🍗',
    categoria: 'pollo',
    cantidad: '500g',
    fechaCaducidad: DateTime.now().add(const Duration(days: 3)),
    esFresco: false,
  ),
  Producto(
    id: '4',
    nombre: 'Yogur',
    emoji: '🥛',
    categoria: 'yogur',
    cantidad: '1 unidad',
    fechaCaducidad: DateTime.now().add(const Duration(days: 5)),
    esFresco: false,
  ),
  Producto(
    id: '5',
    nombre: 'Manzanas',
    emoji: '🍎',
    categoria: 'fruta',
    cantidad: '3 unidades',
    fechaCaducidad: DateTime.now().add(const Duration(days: 7)),
    esFresco: true,
  ),
  Producto(
    id: '6',
    nombre: 'Pasta',
    emoji: '🍝',
    categoria: 'grano',
    cantidad: '500g',
    fechaCaducidad: DateTime.now().add(const Duration(days: 30)),
    esFresco: false,
  ),
];