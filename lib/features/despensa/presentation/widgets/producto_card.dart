import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pastilla_estado.dart';
import '../../domain/producto.dart';

/// Tarjeta de producto de la despensa.
///
/// El color se gana, no se reparte: un producto en buen estado no lleva
/// insignia, ni barra, ni borde de color — solo su fecha en texto apagado. Asi
/// lo urgente salta sin necesidad de gritar. Antes todas las tarjetas eran
/// iguales y el unico refuerzo del urgente era una sombra verde, que
/// contradecia su propio badge rojo.
class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback? onTap;

  const ProductoCard({super.key, required this.producto, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paleta = context.paleta;

    final dias = producto.diasRestantes;
    final estado = paleta.urgenciaPorDias(dias);

    // Solo lo que ya vencio o vence mañana levanta la tarjeta entera.
    final reclamaAtencion = dias <= 1;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: AppMotion.mueve,
          curve: AppMotion.curvaMueve,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: paleta.superficie,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: reclamaAtencion && estado != null
                  ? estado
                  : paleta.contorno,
              width: reclamaAtencion ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              if (reclamaAtencion && estado != null) ...[
                // Barra lateral: refuerza la urgencia con forma, no solo con
                // color, para quien no distingue rojo de naranja.
                Container(
                  width: 3,
                  height: 34,
                  decoration: BoxDecoration(
                    color: estado,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Text(producto.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${producto.cantidad} · ${producto.categoria}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PastillaEstado(dias: dias),
            ],
          ),
        ),
      ),
    );
  }
}

