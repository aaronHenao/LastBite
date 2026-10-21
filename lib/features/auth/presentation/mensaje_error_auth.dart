import 'package:lastbite/l10n/app_localizations.dart';

import '../data/auth_service.dart';

/// Lo que se le dice a la persona cuando no pudo entrar o registrarse, en el
/// idioma activo. null cuando no hay nada que decir: cerro la ventana de
/// Google a proposito.
String? mensajeErrorAuth(L10n t, Object error) {
  if (error is! ErrorAuth) return t.authErrorDesconocido('$error');

  return switch (error.codigo) {
    ErrorAuth.cancelado ||
    'popup-closed-by-user' ||
    'cancelled-popup-request' => null,
    'INVALID_LOGIN_CREDENTIALS' ||
    'invalid-credential' => t.authCredencialesIncorrectas,
    'email-already-in-use' => t.authCorreoRegistrado,
    'invalid-email' => t.authCorreoInvalido,
    'weak-password' => t.authContrasenaCorta,
    'user-not-found' => t.authSinCuenta,
    'wrong-password' => t.authContrasenaIncorrecta,
    'too-many-requests' => t.authDemasiadosIntentos,
    'network-request-failed' => t.authSinConexion,
    'popup-blocked' => t.authVentanaBloqueada,
    // El codigo queda a la vista: con el se puede pedir ayuda.
    final codigo => t.authErrorDesconocido(codigo),
  };
}
