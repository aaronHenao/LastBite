import 'package:flutter/material.dart';
import 'package:lastbite/l10n/traducciones.dart';

import 'package:lastbite/features/ayuda/presentation/ayuda_screen.dart';
import '../theme/app_theme.dart';

/// Boton "?" que abre la ayuda en la seccion de la pantalla donde esta.
///
/// Va en el encabezado de cada pantalla principal: la ayuda tiene que estar a
/// la vista, no escondida en un menu.
class BotonAyuda extends StatelessWidget {
  const BotonAyuda({super.key, this.seccion});

  final SeccionAyuda? seccion;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.t.ayudaAbrir,
      icon: Icon(Icons.help_outline_rounded, color: context.paleta.apagado),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => AyudaScreen(seccion: seccion)),
      ),
    );
  }
}
