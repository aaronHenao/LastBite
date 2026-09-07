import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Error de carga de una pantalla.
///
/// Seis pantallas mostraban `'$e'` directo, asi que el usuario leia excepciones
/// de Firestore y codigos HTTP, y solo una ofrecia reintentar. Aca el mensaje
/// tecnico queda disponible pero plegado, y siempre hay salida.
class EstadoError extends StatelessWidget {
  const EstadoError({
    super.key,
    required this.mensaje,
    this.detalle,
    this.onReintentar,
  });

  /// Que paso, en lenguaje de persona.
  final String mensaje;

  /// El error tecnico. Se muestra plegado, para reportar un problema.
  final Object? detalle;

  final VoidCallback? onReintentar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paleta = context.paleta;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: paleta.apagado,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              if (onReintentar != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: onReintentar,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reintentar'),
                ),
              ],
              if (detalle != null) ...[
                const SizedBox(height: AppSpacing.md),
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      'Detalle técnico',
                      style: textTheme.bodySmall?.copyWith(
                        color: paleta.apagado,
                      ),
                    ),
                    children: [
                      Text(
                        '$detalle',
                        style: textTheme.bodySmall?.copyWith(
                          color: paleta.apagado,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
