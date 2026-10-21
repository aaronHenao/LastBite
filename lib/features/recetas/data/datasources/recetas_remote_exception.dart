/// Por que no hubo recetas. La pantalla lo pone en palabras, en el idioma
/// activo.
enum ErrorRecetas {
  faltaClave,
  respuestaVacia,
  tiempoAgotado,
  sinConexion,
  claveInvalida,
  sinCreditos,
  modeloInexistente,
  modeloRetirado,
  demasiadasConsultas,
  servicioCaido,
  sinRecetasValidas,
  formatoInesperado,
  respuestaIncompleta,
  detalleNoDisponible,
  sinIngredientes,
  desconocido,
}

class RecetasRemoteException implements Exception {
  const RecetasRemoteException({this.statusCode, required this.motivo});

  final int? statusCode;
  final ErrorRecetas motivo;

  @override
  String toString() {
    if (statusCode != null) {
      return 'RecetasRemoteException(statusCode: $statusCode, motivo: ${motivo.name})';
    }
    return 'RecetasRemoteException(motivo: ${motivo.name})';
  }
}
