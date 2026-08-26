import '../../../core/constants/momento_comida.dart';
import 'receta.dart';

/// Orden en que se muestran las recetas sugeridas.
///
/// Los criterios se aplican en cascada, cada uno manda sobre el siguiente:
///
/// 1. si encaja con el momento del dia (`dishTypes`),
/// 2. si es mas rapida (`minutosPreparacion`), solo cuando el usuario lo pide,
/// 3. cuanto aprovecha la despensa (`porcentajeMatch`).
///
/// Los tres son tolerantes a datos faltantes: Spoonacular a veces manda
/// `dishTypes` vacios y no siempre trae el tiempo de preparacion. Cuando el
/// dato no esta, ese criterio no opina y decide el siguiente.
int compararRecetas(
  Receta a,
  Receta b, {
  required bool ordenarPorTiempo,
  MomentoComida? momento,
}) {
  if (momento != null) {
    final encajaA = encajaConMomento(a.dishTypes, momento);
    final encajaB = encajaConMomento(b.dishTypes, momento);
    if (encajaA != encajaB) return encajaA ? -1 : 1;
  }

  if (ordenarPorTiempo) {
    final porTiempo = _compararPorTiempo(a, b);
    if (porTiempo != 0) return porTiempo;
  }

  return b.porcentajeMatch.compareTo(a.porcentajeMatch);
}

/// Menor tiempo primero. Las recetas sin tiempo conocido van al final.
int _compararPorTiempo(Receta a, Receta b) {
  final minutosA = a.minutosPreparacion;
  final minutosB = b.minutosPreparacion;

  if (minutosA == null && minutosB == null) return 0;
  if (minutosA == null) return 1;
  if (minutosB == null) return -1;

  return minutosA.compareTo(minutosB);
}
