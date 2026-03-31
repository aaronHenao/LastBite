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
}
