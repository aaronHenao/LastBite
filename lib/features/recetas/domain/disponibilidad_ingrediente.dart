import 'package:lastbite/core/utils/texto.dart';

/// Si un ingrediente de una receta ya esta en casa.
enum Disponibilidad {
  /// Esta en la despensa.
  tienes,

  /// No esta en la despensa, pero se asume que hay en cualquier cocina.
  basico,

  falta,
}

/// Lo que se asume que hay en cualquier cocina: cuenta como disponible para
/// el match aunque no este cargado en la despensa. En los tres idiomas de la
/// app, porque la IA escribe las recetas en el que este elegido.
const ingredientesBasicos = {
  'sal', 'pimienta', 'aceite', 'agua', // es
  'salt', 'pepper', 'oil', 'olive oil', 'water', // en
  'pimenta', 'oleo', 'azeite', // pt (sal y agua ya estan)
};

/// Disponibilidad de [ingrediente] frente a los nombres de la [despensa].
///
/// Es la unica regla: con ella se calcula el porcentaje de match al generar
/// la receta y con ella se marca cada ingrediente en el detalle. Antes el
/// detalle usaba otra (sin quitar tildes y sin basicos), y una receta "100 %"
/// mostraba la mitad de sus ingredientes como "Falta".
///
/// [ingrediente] puede traer la cantidad entre parentesis al final, como en
/// "Pechuga de pollo (300 g)": no es parte del nombre.
Disponibilidad disponibilidadIngrediente(
  String ingrediente,
  Iterable<String> despensa,
) {
  final nombre = normalizarTexto(
    ingrediente.replaceFirst(RegExp(r'\s*\([^)]*\)\s*$'), ''),
  );

  final tiene = despensa
      .map(normalizarTexto)
      .where((p) => p.length >= 3)
      .any(
        (p) => nombre.contains(p) || (nombre.length >= 3 && p.contains(nombre)),
      );
  if (tiene) return Disponibilidad.tienes;

  if (ingredientesBasicos.any((b) => nombre == b || nombre.startsWith('$b '))) {
    return Disponibilidad.basico;
  }
  return Disponibilidad.falta;
}
