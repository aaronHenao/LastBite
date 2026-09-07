import 'package:flutter/material.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/widgets/pastilla_estado.dart';
import 'package:lastbite/features/alertas/domain/alerta.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';
import 'package:lastbite/features/recetas/presentation/widgets/receta_card.dart';

/// Tarjeta de alerta de caducidad.
///
/// La severidad se ve antes de leerla: barra lateral, borde y pastilla salen
/// de la misma escala que el resto de la app. Antes los cuatro niveles usaban
/// la misma tarjeta, "vence mañana" y "ya venció" compartian color, y los dos
/// niveles bajos eran invisibles sobre blanco.
class AlertaCard extends StatelessWidget {
  final Alerta alerta;
  final ValueChanged<Receta>? onVerReceta;

  const AlertaCard({super.key, required this.alerta, this.onVerReceta});

  /// Dias que le quedan al producto. El color se calcula sobre esto y no
  /// sobre el tipo de alerta, para que coincida con la despensa.
  int get _dias => alerta.fechaCaducidad.difference(DateTime.now()).inDays;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paleta = context.paleta;

    final estado = paleta.urgenciaPorDias(_dias);
    final reclamaAtencion = _dias <= 1;

    return Container(
      decoration: BoxDecoration(
        color: paleta.superficie,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: reclamaAtencion && estado != null ? estado : paleta.contorno,
          width: reclamaAtencion ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (reclamaAtencion && estado != null) ...[
                  Container(
                    width: 3,
                    height: 38,
                    decoration: BoxDecoration(
                      color: estado,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Text(alerta.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alerta.nombreProducto,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alerta.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelMedium?.copyWith(
                          color: estado ?? paleta.apagado,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                PastillaEstado(dias: _dias),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(alerta.mensaje, style: textTheme.bodySmall),
            if (alerta.recetaSugerida != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text('RECETA SUGERIDA', style: AppTextStyles.rotulo(context)),
              const SizedBox(height: AppSpacing.sm),
              RecetaCard(
                receta: alerta.recetaSugerida!,
                onTap: () => onVerReceta?.call(alerta.recetaSugerida!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
