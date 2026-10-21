import 'package:lastbite/l10n/app_localizations.dart';

import '../data/despensa_compartida_repository.dart';
import '../domain/despensa_compartida.dart';

/// Nombres que pueden faltar en el dato: se completan al mostrarlos, en el
/// idioma activo, y no al guardarlos.
extension NombreDespensaVisible on DespensaCompartida {
  String nombreVisible(L10n t) =>
      nombre.trim().isEmpty ? t.compartidaNombreDefecto : nombre;
}

extension NombreMiembroVisible on MiembroDespensa {
  String nombreVisible(L10n t) =>
      nombre.trim().isEmpty ? t.compartidaMiembroSinNombre : nombre;
}

/// Lo que se le dice a la persona cuando algo de la despensa compartida
/// falla. Un error que no es de dominio (red, permisos) no se muestra crudo.
String mensajeErrorCompartida(L10n t, Object error) {
  if (error is! DespensaCompartidaException) return t.compartidaErrorDesconocido;

  return switch (error.motivo) {
    ErrorCompartida.largoCodigo => t.compartidaErrorLargoCodigo(
      DespensaCompartidaRepository.largoCodigo,
    ),
    ErrorCompartida.codigoInexistente => t.compartidaErrorCodigoInexistente,
    ErrorCompartida.noExiste => t.compartidaErrorNoExiste,
    ErrorCompartida.unicoMiembro => t.compartidaErrorUnicoMiembro,
    ErrorCompartida.elegirAdmin => t.compartidaErrorElegirAdmin,
    ErrorCompartida.adminInvalido => t.compartidaErrorAdminInvalido,
    ErrorCompartida.soloAdminMiembros => t.compartidaErrorSoloAdminMiembros,
    ErrorCompartida.adminNoSeElimina => t.compartidaErrorAdminNoSeElimina,
    ErrorCompartida.soloAdminEliminar => t.compartidaErrorSoloAdminEliminar,
    ErrorCompartida.yaPerteneces => t.compartidaErrorYaPerteneces,
    ErrorCompartida.sinCodigo => t.compartidaErrorSinCodigo,
    ErrorCompartida.sinSesion => t.compartidaErrorSinSesion,
  };
}
