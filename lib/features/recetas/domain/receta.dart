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
}

//datos hardcodeados para pruebas
final recetasEjemplo = [
  Receta(
    id: 1,
    titulo: 'Crema de Espinacas',
    imagenUrl: '',
    ingredientesUsados: 3,
    ingredientesFaltantes: 0,
    likes: 142,
    minutosPreparacion: 20,
    ingredientes: ['Espinacas', 'Cebolla', 'Ajo', 'Crema'],
    instrucciones: 'Saltea la cebolla y el ajo. Agrega las espinacas...',
  ),
  Receta(
    id: 2,
    titulo: 'Pollo al Tomate',
    imagenUrl: '',
    ingredientesUsados: 3,
    ingredientesFaltantes: 1,
    likes: 89,
    minutosPreparacion: 35,
    ingredientes: ['Pollo', 'Tomates', 'Cebolla', 'Pimentón'],
    instrucciones: 'Sella el pollo. Agrega los tomates y cebolla...',
  ),
  Receta(
    id: 3,
    titulo: 'Ensalada Fresca',
    imagenUrl: '',
    ingredientesUsados: 2,
    ingredientesFaltantes: 1,
    likes: 56,
    minutosPreparacion: 10,
    ingredientes: ['Espinacas', 'Tomates', 'Manzana'],
    instrucciones: 'Mezcla todos los ingredientes...',
  ),
  Receta(
    id: 4,
    titulo: 'Pasta con Pollo',
    imagenUrl: '',
    ingredientesUsados: 2,
    ingredientesFaltantes: 2,
    likes: 201,
    minutosPreparacion: 30,
    ingredientes: ['Pasta', 'Pollo', 'Tomates', 'Queso'],
    instrucciones: 'Cocina la pasta. Prepara la salsa de pollo...',
  ),
];
