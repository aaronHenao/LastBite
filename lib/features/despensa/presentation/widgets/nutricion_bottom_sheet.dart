import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/info_nutricional.dart';
import '../../domain/producto.dart';
import '../despensa_provider.dart';

class NutricionBottomSheet extends ConsumerWidget {
  final Producto producto;

  const NutricionBottomSheet({super.key, required this.producto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final codigo = producto.codigoBarras?.trim();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'VALORES NUTRICIONALES',
              style: textTheme.titleSmall?.copyWith(
                letterSpacing: 1.6,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              producto.nombre,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 12),
            if (codigo == null || codigo.isEmpty)
              _SinCodigoBarras(textTheme: textTheme)
            else
              _NutricionContenido(codigo: codigo),
          ],
        ),
      ),
    );
  }
}

class _SinCodigoBarras extends StatelessWidget {
  final TextTheme textTheme;

  const _SinCodigoBarras({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Este producto no tiene codigo de barras asociado. Escanea el codigo para ver su informacion nutricional.',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}

class _NutricionContenido extends ConsumerWidget {
  final String codigo;

  const _NutricionContenido({required this.codigo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final asyncInfo = ref.watch(infoNutricionalProvider(codigo));

    return asyncInfo.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Buscando en Open Food Facts...',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      error: (error, stack) => _ErrorCargaNutricion(
        mensaje: error.toString(),
        onRetry: () {
          ref.invalidate(infoNutricionalProvider(codigo));
        },
      ),
      data: (info) {
        if (info == null) {
          return _ErrorCargaNutricion(
            mensaje: 'Producto no encontrado en Open Food Facts.',
            onRetry: () {
              ref.invalidate(infoNutricionalProvider(codigo));
            },
          );
        }
        return _InfoNutricionalDetalle(info: info);
      },
    );
  }
}

class _ErrorCargaNutricion extends StatelessWidget {
  final String mensaje;
  final VoidCallback onRetry;

  const _ErrorCargaNutricion({required this.mensaje, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mensaje,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _InfoNutricionalDetalle extends StatelessWidget {
  final InfoNutricional info;

  const _InfoNutricionalDetalle({required this.info});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((info.nombreProducto ?? '').isNotEmpty) ...[
          Text(
            info.nombreProducto!,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
        ],
        if ((info.marcas ?? '').isNotEmpty)
          Text(
            info.marcas!,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        if ((info.porcion ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Porcion: ${info.porcion}',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
        const SizedBox(height: 12),
        _NutrienteFila(
          label: 'Energia',
          value: _format(info.energiaKcal100g, suffix: 'kcal/100g'),
        ),
        _NutrienteFila(
          label: 'Grasas',
          value: _format(info.grasas100g, suffix: 'g/100g'),
        ),
        _NutrienteFila(
          label: 'Grasas saturadas',
          value: _format(info.grasasSaturadas100g, suffix: 'g/100g'),
        ),
        _NutrienteFila(
          label: 'Carbohidratos',
          value: _format(info.carbohidratos100g, suffix: 'g/100g'),
        ),
        _NutrienteFila(
          label: 'Azucares',
          value: _format(info.azucares100g, suffix: 'g/100g'),
        ),
        _NutrienteFila(
          label: 'Proteinas',
          value: _format(info.proteinas100g, suffix: 'g/100g'),
        ),
        _NutrienteFila(
          label: 'Sal',
          value: _format(info.sal100g, suffix: 'g/100g'),
        ),
      ],
    );
  }

  static String _format(double? value, {required String suffix}) {
    if (value == null) return '—';
    final formatted = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$formatted $suffix';
  }
}

class _NutrienteFila extends StatelessWidget {
  final String label;
  final String value;

  const _NutrienteFila({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMain),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
