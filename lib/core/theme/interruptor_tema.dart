import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lastbite/core/preferencias/preferencias_provider.dart';
import 'package:lastbite/l10n/traducciones.dart';

/// Alterna entre claro, oscuro y el ajuste del sistema.
class InterruptorTema extends ConsumerWidget {
  const InterruptorTema({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo =
        ref.watch(preferenciasProvider).valueOrNull?.tema ?? ThemeMode.system;

    final t = context.t;
    final (icono, etiqueta, siguiente) = switch (modo) {
      ThemeMode.system => (
        Icons.brightness_auto_rounded,
        t.temaAutomaticoAccion,
        ThemeMode.light,
      ),
      ThemeMode.light => (
        Icons.light_mode_rounded,
        t.temaClaroAccion,
        ThemeMode.dark,
      ),
      ThemeMode.dark => (
        Icons.dark_mode_rounded,
        t.temaOscuroAccion,
        ThemeMode.system,
      ),
    };

    return IconButton(
      onPressed: () =>
          ref.read(preferenciasProvider.notifier).cambiarTema(siguiente),
      icon: Icon(icono),
      tooltip: etiqueta,
    );
  }
}
