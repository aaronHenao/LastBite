import 'precio_promedio.dart';

/// Unidades de medida disponibles para los productos
enum UnidadMedida {
  unidad,
  kilogramo,
  gramo,
  litro,
  mililitro,
  cucharada,
  taza,
}

/// Magnitud física que mide una unidad. Determina qué unidades tienen
/// sentido para cada categoría de alimento.
enum DimensionMedida { masa, volumen, conteo }

/// Extensión para obtener la representación en string de la unidad
extension UnidadMedidaExt on UnidadMedida {
  String get label => switch (this) {
    UnidadMedida.unidad => 'Unidad',
    UnidadMedida.kilogramo => 'Kilogramo (kg)',
    UnidadMedida.gramo => 'Gramo (g)',
    UnidadMedida.litro => 'Litro (L)',
    UnidadMedida.mililitro => 'Mililitro (ml)',
    UnidadMedida.cucharada => 'Cucharada',
    UnidadMedida.taza => 'Taza',
  };

  String get abreviatura => switch (this) {
    UnidadMedida.unidad => 'unidad',
    UnidadMedida.kilogramo => 'kg',
    UnidadMedida.gramo => 'g',
    UnidadMedida.litro => 'L',
    UnidadMedida.mililitro => 'ml',
    UnidadMedida.cucharada => 'cda',
    UnidadMedida.taza => 'taza',
  };

  DimensionMedida get dimension => switch (this) {
    UnidadMedida.unidad => DimensionMedida.conteo,
    UnidadMedida.kilogramo || UnidadMedida.gramo => DimensionMedida.masa,
    UnidadMedida.litro ||
    UnidadMedida.mililitro ||
    UnidadMedida.cucharada ||
    UnidadMedida.taza => DimensionMedida.volumen,
  };
}

/// Unidades que tienen sentido para una categoría, en orden de uso esperado.
///
/// Se derivan de cómo se cotiza la categoría en [preciosPorCategoria]: lo que
/// se vende por kilo admite peso o piezas, lo que se vende por litro admite
/// volumen o envases. Evita registros como "Leche: 3 cucharadas" o
/// "Carne: 2 tazas", que además degradan el cálculo de ahorro porque obligan a
/// caer en la cantidad de referencia.
List<UnidadMedida> unidadesPara(String categoria) {
  // 'Otro' es el cajón de sastre: no se puede asumir nada sobre su contenido.
  if (categoria.trim().toLowerCase() == 'otro') return UnidadMedida.values;

  return switch (precioDeCategoria(categoria).base) {
    BaseMedida.kilo => const [
      UnidadMedida.gramo,
      UnidadMedida.kilogramo,
      UnidadMedida.unidad,
    ],
    BaseMedida.litro => const [
      UnidadMedida.mililitro,
      UnidadMedida.litro,
      UnidadMedida.unidad,
      UnidadMedida.taza,
      UnidadMedida.cucharada,
    ],
    BaseMedida.unidad => const [
      UnidadMedida.unidad,
      UnidadMedida.gramo,
      UnidadMedida.kilogramo,
    ],
  };
}

/// Si la unidad es aceptable para esa categoría.
bool unidadValida(String categoria, UnidadMedida unidad) =>
    unidadesPara(categoria).contains(unidad);
