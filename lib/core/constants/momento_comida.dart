/// Momento de comida segun la hora, y su relacion con los `dishTypes`
/// que devuelve Spoonacular.
///
/// Spoonacular etiqueta `lunch` y `dinner` siempre juntos, asi que no hay
/// forma de distinguir almuerzo de cena con ese dato. Por eso solo se
/// separan dos momentos: la manana (desayuno) y el resto del dia (plato
/// principal).
library;

enum MomentoComida {
  /// Antes del mediodia: desayunos y brunch.
  desayuno,

  /// Resto del dia: platos fuertes.
  principal,
}

/// Hora a partir de la cual deja de considerarse desayuno.
const int horaFinDesayuno = 11;

MomentoComida momentoComidaDe(DateTime fecha) {
  return fecha.hour < horaFinDesayuno
      ? MomentoComida.desayuno
      : MomentoComida.principal;
}

/// `dishTypes` (tal cual los manda Spoonacular) que encajan con cada momento.
const Map<MomentoComida, Set<String>> tiposPorMomento = {
  MomentoComida.desayuno: {'breakfast', 'morning meal', 'brunch'},
  MomentoComida.principal: {'main course', 'main dish', 'lunch', 'dinner'},
};

/// `true` si la receta encaja con el momento del dia.
///
/// Una receta sin `dishTypes` (Spoonacular a veces los manda vacios) queda
/// como neutral: ni se prioriza ni se castiga.
bool encajaConMomento(List<String>? dishTypes, MomentoComida momento) {
  if (dishTypes == null || dishTypes.isEmpty) return false;

  final esperados = tiposPorMomento[momento] ?? const <String>{};
  return dishTypes.any((tipo) => esperados.contains(tipo.toLowerCase().trim()));
}

/// Texto que explica al usuario por que la lista quedo ordenada asi.
String explicacionMomento(MomentoComida momento) {
  return momento == MomentoComida.desayuno
      ? 'Es temprano: primero las de desayuno'
      : 'Primero los platos fuertes';
}
