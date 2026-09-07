import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lastbite/core/theme/tema_provider.dart';

/// Alterna entre claro, oscuro y el ajuste del sistema.
class InterruptorTema extends ConsumerWidget {
  const InterruptorTema({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo = ref.watch(temaProvider).valueOrNull ?? ThemeMode.system;

    final (icono, etiqueta, siguiente) = switch (modo) {
      ThemeMode.system => (
        Icons.brightness_auto_rounded,
        'Tema: automático',
        ThemeMode.light,
      ),
      ThemeMode.light => (
        Icons.light_mode_rounded,
        'Tema: claro',
        ThemeMode.dark,
      ),
      ThemeMode.dark => (
        Icons.dark_mode_rounded,
        'Tema: oscuro',
        ThemeMode.system,
      ),
    };

    return IconButton(
      onPressed: () => ref.read(temaProvider.notifier).cambiar(siguiente),
      icon: Icon(icono),
      tooltip: '$etiqueta. Tocá para cambiar.',
    );
  }
}
