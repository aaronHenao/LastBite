import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Estado de un alimento segun los dias que le quedan.
///
/// Es el unico lugar donde se decide como se ve la urgencia. Antes cada
/// pantalla tenia su propia escala —cuatro en total, ninguna completa— y dos de
/// ellas usaban colores de marca para comunicar urgencia.
///
/// Cuando al producto le queda mas de una semana no hay pastilla: solo la
/// etiqueta en texto apagado. El color se gana.
class PastillaEstado extends StatelessWidget {
  const PastillaEstado({super.key, required this.dias, this.compacta = false});

  final int dias;

  /// En listas densas se omite el icono para no competir con el contenido.
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paleta = context.paleta;
    final color = paleta.urgenciaPorDias(dias);
    final etiqueta = AppTheme.diasLabel(dias);

    if (color == null) {
      return Text(
        etiqueta,
        style: textTheme.bodySmall?.copyWith(color: paleta.apagado),
      );
    }

    // Lo urgente va en pastilla solida; lo de esta semana, en pastilla suave,
    // para que informe sin competir con lo grave.
    final solida = dias <= 3;
    final colorTexto = solida ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: solida ? color : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dias <= 1 && !compacta) ...[
            // El icono acompaña al color: quien no distingue rojo de naranja
            // igual ve que algo reclama atencion.
            Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              size: 12,
              color: colorTexto,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            etiqueta,
            style: textTheme.labelSmall?.copyWith(
              color: colorTexto,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
