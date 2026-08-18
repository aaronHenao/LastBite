/// Precios estimados por unidad base y conversión de cantidades.
///
/// El ahorro se calcula sobre la cantidad real salvada, no sobre el número de
/// productos: consumir 2 kg de carne no vale lo mismo que consumir 200 g.
///
/// Los precios son estimaciones gruesas en COP, no precios reales de mercado.
/// Fuente: <completar> - Actualizado: <fecha>
library;

/// Unidad en la que se cotiza cada categoría.
enum BaseMedida {
  kilo('kg'),
  litro('L'),
  unidad('unidad');

  const BaseMedida(this.abreviatura);
  final String abreviatura;
}

class PrecioCategoria {
  const PrecioCategoria({
    required this.precio,
    required this.base,
    required this.referencia,
  });

  /// COP por una unidad base completa (un kilo, un litro, una unidad).
  final int precio;

  /// Unidad en la que se cotiza la categoría.
  final BaseMedida base;

  /// Cantidad que se asume cuando no se puede leer la cantidad del producto.
  /// Debe representar una compra típica de esa categoría.
  final double referencia;
}

const Map<String, PrecioCategoria> preciosPorCategoria = {
  'Verdura': PrecioCategoria(
    precio: 4000,
    base: BaseMedida.kilo,
    referencia: 0.50,
  ),
  'Fruta': PrecioCategoria(
    precio: 5000,
    base: BaseMedida.kilo,
    referencia: 0.50,
  ),
  'Hierba': PrecioCategoria(
    precio: 20000,
    base: BaseMedida.kilo,
    referencia: 0.05,
  ),
  'Carne': PrecioCategoria(
    precio: 28000,
    base: BaseMedida.kilo,
    referencia: 0.50,
  ),
  'Pollo': PrecioCategoria(
    precio: 14000,
    base: BaseMedida.kilo,
    referencia: 0.50,
  ),
  'Pescado': PrecioCategoria(
    precio: 25000,
    base: BaseMedida.kilo,
    referencia: 0.40,
  ),
  'Huevo': PrecioCategoria(
    precio: 700,
    base: BaseMedida.unidad,
    referencia: 1.0,
  ),
  'Leche': PrecioCategoria(
    precio: 4500,
    base: BaseMedida.litro,
    referencia: 1.0,
  ),
  'Yogur': PrecioCategoria(
    precio: 8000,
    base: BaseMedida.litro,
    referencia: 1.0,
  ),
  'Queso': PrecioCategoria(
    precio: 30000,
    base: BaseMedida.kilo,
    referencia: 0.25,
  ),
  'Mantequilla': PrecioCategoria(
    precio: 24000,
    base: BaseMedida.kilo,
    referencia: 0.25,
  ),
  'Pan': PrecioCategoria(precio: 8000, base: BaseMedida.kilo, referencia: 0.50),
  'Embutido': PrecioCategoria(
    precio: 20000,
    base: BaseMedida.kilo,
    referencia: 0.30,
  ),
  'Jugo': PrecioCategoria(
    precio: 5000,
    base: BaseMedida.litro,
    referencia: 1.0,
  ),
  'Grano': PrecioCategoria(
    precio: 5000,
    base: BaseMedida.kilo,
    referencia: 1.0,
  ),
  'Conserva': PrecioCategoria(
    precio: 12000,
    base: BaseMedida.kilo,
    referencia: 0.40,
  ),
  'Cereal': PrecioCategoria(
    precio: 15000,
    base: BaseMedida.kilo,
    referencia: 0.50,
  ),
  'Otro': PrecioCategoria(
    precio: 6000,
    base: BaseMedida.unidad,
    referencia: 1.0,
  ),
};

const PrecioCategoria _fallback = PrecioCategoria(
  precio: 6000,
  base: BaseMedida.unidad,
  referencia: 1.0,
);

/// Busca la categoría ignorando mayúsculas y espacios. Cae a 'Otro'.
PrecioCategoria precioDeCategoria(String categoria) {
  final buscada = categoria.trim().toLowerCase();
  for (final entry in preciosPorCategoria.entries) {
    if (entry.key.toLowerCase() == buscada) return entry.value;
  }
  return preciosPorCategoria['Otro'] ?? _fallback;
}

/// Factores hacia la unidad canónica de cada dimensión: masa a kg,
/// volumen a litros, conteo a unidades.
const Map<String, (BaseMedida, double)> _factores = {
  'mg': (BaseMedida.kilo, 0.000001),
  'g': (BaseMedida.kilo, 0.001),
  'gr': (BaseMedida.kilo, 0.001),
  'kg': (BaseMedida.kilo, 1.0),
  'oz': (BaseMedida.kilo, 0.0283495),
  'lb': (BaseMedida.kilo, 0.453592),
  'ml': (BaseMedida.litro, 0.001),
  'cl': (BaseMedida.litro, 0.01),
  'l': (BaseMedida.litro, 1.0),
  'lt': (BaseMedida.litro, 1.0),
  'unidad': (BaseMedida.unidad, 1.0),
  'unidades': (BaseMedida.unidad, 1.0),
  'u': (BaseMedida.unidad, 1.0),
  'und': (BaseMedida.unidad, 1.0),
};

/// Un número seguido de una unidad, ej. "500 g", "1,5 L", "2unidades".
final RegExp _patronCantidad = RegExp(
  r'([0-9]+(?:[.,][0-9]+)?)\s*([a-zA-ZáéíóúÁÉÍÓÚ]*)',
);

/// Cantidad leída de un texto libre, ya expresada en su unidad canónica.
/// Devuelve null si no hay número o si la unidad no se reconoce
/// (cucharada y taza no convierten a masa sin conocer la densidad).
({double valor, BaseMedida base})? leerCantidad(String cantidad) {
  final match = _patronCantidad.firstMatch(cantidad.trim());
  if (match == null) return null;

  final numero = double.tryParse(match.group(1)!.replaceAll(',', '.'));
  if (numero == null || numero <= 0) return null;

  final sufijo = (match.group(2) ?? '').toLowerCase();
  // Sin sufijo se asume conteo: "3" son tres unidades.
  if (sufijo.isEmpty) return (valor: numero, base: BaseMedida.unidad);

  final factor = _factores[sufijo];
  if (factor == null) return null;

  return (valor: numero * factor.$2, base: factor.$1);
}

/// Cantidad de un producto expresada en la unidad base de su categoría.
///
/// Cae a la cantidad de referencia de la categoría cuando el texto no se puede
/// leer, o cuando la dimensión no corresponde y no hay conversión razonable.
/// Masa y volumen sí se intercambian asumiendo densidad 1, que es aceptable
/// para leche, yogur y jugos.
double cantidadEnBase(String categoria, String cantidad) {
  final info = precioDeCategoria(categoria);
  final leida = leerCantidad(cantidad);
  if (leida == null) return info.referencia;

  if (leida.base == info.base) return leida.valor;

  final esMasaOVolumen =
      leida.base != BaseMedida.unidad && info.base != BaseMedida.unidad;
  if (esMasaOVolumen) return leida.valor;

  return info.referencia;
}

/// Ahorro en COP de un mapa `categoría -> cantidad en su unidad base`.
int ahorroEstimado(Map<String, double> cantidadesPorCategoria) {
  var total = 0.0;
  for (final entry in cantidadesPorCategoria.entries) {
    total += precioDeCategoria(entry.key).precio * entry.value;
  }
  return total.round();
}
