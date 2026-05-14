import 'package:flutter/material.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/alertas/domain/alerta.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';
import 'package:lastbite/features/recetas/presentation/widgets/receta_card.dart';

class AlertaCard extends StatelessWidget {
  final Alerta alerta;
  final ValueChanged<Receta>? onVerReceta;

  const AlertaCard({
    super.key,
    required this.alerta,
    this.onVerReceta,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorPorTipo(alerta.tipo);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alerta.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alerta.nombreProducto,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alerta.titulo,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    alerta.etiqueta,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              alerta.mensaje,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            if (alerta.recetaSugerida != null) ...[
              const SizedBox(height: 12),
              Text(
                'Receta sugerida',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
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

  Color _colorPorTipo(AlertaTipo tipo) {
    switch (tipo) {
      case AlertaTipo.aviso5:
        return AppColors.yellow;
      case AlertaTipo.aviso3:
        return AppColors.accent;
      case AlertaTipo.aviso1:
        return AppColors.danger;
      case AlertaTipo.vencido:
        return AppColors.danger;
    }
  }
}
