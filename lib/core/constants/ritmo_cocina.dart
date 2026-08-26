/// Ritmo de cocina segun el dia de la semana.
///
/// Entre semana se cocina con prisa, asi que la lista de recetas arranca
/// ordenada por tiempo de preparacion. El fin de semana hay margen para
/// platos mas elaborados y se respeta el orden por match con la despensa.
///
/// Es solo el valor inicial: el usuario siempre puede cambiarlo a mano con
/// el boton "Menor tiempo".
library;

/// Dias que cuentan como fin de semana (`DateTime.saturday`, `DateTime.sunday`).
const Set<int> diasDeFinDeSemana = {DateTime.saturday, DateTime.sunday};

/// `true` de lunes a viernes, `false` sabado y domingo.
bool priorizarRecetasRapidas(DateTime fecha) {
  return !diasDeFinDeSemana.contains(fecha.weekday);
}

/// Texto que explica al usuario por que la lista viene ordenada asi.
String explicacionRitmo(DateTime fecha) {
  return priorizarRecetasRapidas(fecha)
      ? 'Es dia de semana: primero las mas rapidas'
      : 'Es fin de semana: hay tiempo para algo mas elaborado';
}
