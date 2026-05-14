import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/alertas/presentation/alertas_provider.dart';
import 'package:lastbite/features/alertas/presentation/widgets/alerta_card.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import 'package:lastbite/features/recetas/data/datasources/ai_translation_data_source.dart';
import 'package:lastbite/features/recetas/data/datasources/recetas_detalle_remote_data_source.dart';
import 'package:lastbite/features/recetas/data/models/receta_detalle_remote_model.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';
import 'package:lastbite/features/recetas/presentation/widgets/receta_card.dart';

class AlertasScreen extends ConsumerStatefulWidget {
  const AlertasScreen({super.key});

  @override
  ConsumerState<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends ConsumerState<AlertasScreen> {
  late final AiTranslationDataSource _translator;
  late final RecetasDetalleRemoteDataSource _detalleDataSource;
  final Map<int, Receta> _detallesCache = {};

  @override
  void initState() {
    super.initState();
    _translator = AiTranslationDataSource();
    _detalleDataSource = RecetasDetalleRemoteDataSource(
      translator: _translator,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Producto>>>(despensaProvider, (previous, next) {
      final prevList = previous?.value;
      final nextList = next.value;
      if (prevList != null && nextList != null && prevList != nextList) {
        ref.read(alertasProvider.notifier).refrescar();
      }
    });

    final textTheme = Theme.of(context).textTheme;
    final asyncAlertas = ref.watch(alertasProvider);

    return asyncAlertas.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Text(
            'Error cargando alertas: $e',
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ),
      data: (alertas) {
        final avisoTraduccion =
            ref.read(alertasProvider.notifier).avisoTraduccion;

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ALERTAS',
                                  style: textTheme.titleSmall?.copyWith(
                                    letterSpacing: 2.4,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Caducidad y recetas',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMain,
                                  ),
                                ),
                              ],
                            ),
                            if (alertas.isNotEmpty)
                              TextButton(
                                onPressed: () => _confirmarBorrado(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                ),
                                child: const Text(
                                  'Borrar todo',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Las alertas se mantienen hasta que decidas borrarlas.',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        if (avisoTraduccion != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.yellow.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.yellow.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.translate,
                                  size: 14,
                                  color: AppColors.textMain,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    avisoTraduccion,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (alertas.isEmpty) ...[
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.bell_slash,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No tienes alertas activas',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final alerta = alertas[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              final velocity = details.primaryVelocity ?? 0;
                              if (velocity < -250) {
                                ref
                                    .read(alertasProvider.notifier)
                                    .eliminar(alerta.id);
                              }
                            },
                            child: AlertaCard(
                              alerta: alerta,
                              onVerReceta: alerta.recetaSugerida == null
                                  ? null
                                  : (receta) => _abrirDetalle(receta),
                            ),
                          ),
                        );
                      },
                      childCount: alertas.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmarBorrado(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Borrar todas las alertas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta accion eliminara las alertas actuales. Las nuevas se generaran cuando corresponda.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref.read(alertasProvider.notifier).borrarTodas();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Alertas eliminadas'),
                              backgroundColor: AppColors.green,
                            ),
                          );
                        }
                      },
                      child: const Text('Borrar todo'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirDetalle(Receta receta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecetaDetalleSheet(
        receta: receta,
        detalleFuture: _cargarDetalleReceta(receta),
      ),
    );
  }

  Future<Receta> _cargarDetalleReceta(Receta receta) async {
    final cached = _detallesCache[receta.id];
    if (cached != null) return cached;

    final raw = await _detalleDataSource.obtenerDetalleRecetaRaw(
      recetaId: receta.id,
    );
    final detalle = RecetaDetalleRemoteModel.fromApiRaw(raw);
    final recetaConDetalle = _fusionarDetalle(receta, detalle);
    _detallesCache[receta.id] = recetaConDetalle;

    final aviso = _detalleDataSource.lastTranslationWarning;
    if (aviso != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(aviso, style: const TextStyle(fontSize: 12))),
      );
    }

    return recetaConDetalle;
  }

  Receta _fusionarDetalle(Receta base, RecetaDetalleRemoteModel detalle) {
    final info = detalle.informacion;

    return Receta(
      id: base.id,
      titulo: info.titulo.isNotEmpty ? info.titulo : base.titulo,
      imagenUrl: info.imagenUrl.isNotEmpty ? info.imagenUrl : base.imagenUrl,
      ingredientesUsados: base.ingredientesUsados,
      ingredientesFaltantes: base.ingredientesFaltantes,
      likes: info.likes > 0 ? info.likes : base.likes,
      minutosPreparacion: info.minutosPreparacion,
      porciones: info.porciones,
      ingredientes:
          detalle.ingredientes.isNotEmpty ? detalle.ingredientes : base.ingredientes,
      instrucciones: _limpiarHtml(info.instrucciones),
    );
  }

  String? _limpiarHtml(String? texto) {
    if (texto == null || texto.trim().isEmpty) return null;

    final sinTags = texto.replaceAll(RegExp(r'<[^>]*>'), ' ');
    return sinTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
