import 'package:flutter/material.dart';
import 'package:lastbite/l10n/traducciones.dart';
import 'package:lastbite/l10n/app_localizations.dart';
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

  /// Descartar la alerta. Existe como boton ademas del gesto de arrastre:
  /// quien usa lector de pantalla, un switch o un puntero de cabeza no puede
  /// arrastrar, y antes ese era el unico camino.
  final VoidCallback? onDescartar;

  const AlertaCard({
    super.key,
    required this.alerta,
    this.onVerReceta,
    this.onDescartar,
  });

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
                        _titulo(context.t, alerta.tipo),
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
                if (onDescartar != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  // La etiqueta va explicita y no solo en el tooltip: es la
                  // unica alternativa al gesto de arrastre y tiene que
                  // anunciarse siempre.
                  Semantics(
                    button: true,
                    container: true,
                    label: context.t.alertaDescartar(alerta.nombreProducto),
                    child: IconButton(
                      onPressed: onDescartar,
                      icon: const Icon(Icons.close_rounded, size: 20),
                      tooltip: context.t.alertaDescartarTooltip,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(_mensaje(context.t, alerta), style: textTheme.bodySmall),
            if (alerta.recetaSugerida != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                context.t.alertaRecetaSugerida,
                style: AppTextStyles.rotulo(context),
              ),
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

String _titulo(L10n t, AlertaTipo tipo) => switch (tipo) {
  AlertaTipo.aviso5 => t.alertaTituloAviso5,
  AlertaTipo.aviso3 => t.alertaTituloAviso3,
  AlertaTipo.aviso1 => t.alertaTituloAviso1,
  AlertaTipo.vencido => t.alertaTituloVencido,
};

String _mensaje(L10n t, Alerta alerta) => switch (alerta.tipo) {
  AlertaTipo.aviso5 => t.alertaMensajeAviso5(alerta.nombreProducto),
  AlertaTipo.aviso3 => t.alertaMensajeAviso3(alerta.nombreProducto),
  AlertaTipo.aviso1 => t.alertaMensajeAviso1(alerta.nombreProducto),
  AlertaTipo.vencido => t.alertaMensajeVencido(alerta.nombreProducto),
};
