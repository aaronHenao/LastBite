import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Atajo para leer los textos traducidos: `context.t.navDespensa`.
///
/// L10n.of devuelve nullable, y escribir `!` en cada uso ensucia las
/// pantallas. Si falta el delegado es un error de configuracion, no algo
/// que una pantalla deba manejar.
extension Traducciones on BuildContext {
  L10n get t => L10n.of(this)!;
}

/// Textos del idioma en uso para lo que se arma lejos de una pantalla, como
/// las notificaciones o las recetas que generan las alertas. La app lo
/// actualiza cada vez que se resuelve el idioma; hasta entonces, el base.
L10n textosActuales = lookupL10n(const Locale('es'));
