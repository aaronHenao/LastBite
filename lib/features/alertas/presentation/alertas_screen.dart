import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lastbite/core/responsive/responsive.dart';
import 'package:lastbite/features/alertas/domain/alerta.dart';
import 'package:lastbite/core/widgets/estado_vacio.dart';
import 'package:lastbite/core/widgets/estado_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/responsive/responsive_container.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/alertas/presentation/alertas_provider.dart';
import 'package:lastbite/features/alertas/presentation/widgets/alerta_card.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
//import 'package:lastbite/features/recetas/data/datasources/ai_translation_data_source.dart';
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
  //late final AiTranslationDataSource _translator;
  late final RecetasDetalleRemoteDataSource _detalleDataSource;
  final Map<int, Receta> _detallesCache = {};

  @override
  void initState() {
    super.initState();
    //_translator = AiTranslationDataSource();
    _detalleDataSource = RecetasDetalleRemoteDataSource(
      //translator: _translator,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Producto>>>(despensaProvider, (previous, next) {
      final prevList = previous?.value;
      final nextList = next.value;
      if (prevList == null || nextList == null) return;
      // listEquals compara elemento a elemento: el stream de la despensa
      // re-emite con frecuencia y solo un cambio real debe regenerar alertas.
      if (!listEquals(prevList, nextList)) {
        ref.read(alertasProvider.notifier).refrescar();
      }
    });

    final textTheme = Theme.of(context).textTheme;
    final asyncAlertas = ref.watch(alertasProvider);

    return asyncAlertas.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: EstadoError(
          mensaje: 'No pudimos cargar tus alertas.',
          detalle: e,
          onReintentar: () => ref.read(alertasProvider.notifier).refrescar(),
        ),
      ),
      data: (alertas) {
        final avisoTraduccion = ref
            .read(alertasProvider.notifier)
            .avisoTraduccion;

        return Scaffold(
          body: SafeArea(
            child: ResponsiveContainer(
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ALERTAS',
                                      style: textTheme.titleSmall?.copyWith(
                                        letterSpacing: 2.4,
                                        color: context.paleta.apagado,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Caducidad y recetas',
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: context.paleta.tinta,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (alertas.isNotEmpty)
                                TextButton(
                                  onPressed: () => _confirmarBorrado(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: context.paleta.vencido,
                                  ),
                                  child: const Text(
                                    'Borrar todo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Las alertas se mantienen hasta que decidas borrarlas.',
                            style: textTheme.bodySmall?.copyWith(
                              color: context.paleta.apagado,
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
                                color: context.paleta.urgente.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: context.paleta.urgente.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.translate,
                                    size: 14,
                                    color: context.paleta.tinta,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      avisoTraduccion,
                                      style: textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        color: context.paleta.tinta,
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
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      // El vacio aca es buena noticia y hay que decirlo: antes
                      // solo informaba que no habia nada.
                      child: EstadoVacio(
                        icono: CupertinoIcons.checkmark_seal,
                        titulo: 'Todo bajo control',
                        descripcion:
                            'Ningún producto de tu despensa está por vencerse. '
                            'Te avisamos apenas alguno lo esté.',
                      ),
                    ),
                  ] else ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final alerta = alertas[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: Dismissible(
                              key: ValueKey(alerta.id),
                              direction: DismissDirection.endToStart,
                              background: _FondoDescartar(),
                              onDismissed: (_) =>
                                  _descartar(context, ref, alerta),
                              child: AlertaCard(
                                alerta: alerta,
                                onDescartar: () =>
                                    _descartar(context, ref, alerta),
                                onVerReceta: alerta.recetaSugerida == null
                                    ? null
                                    : (receta) => _abrirDetalle(receta),
                              ),
                            ),
                          );
                        }, childCount: alertas.length),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: Responsive.isTabletOrWeb(context)
                            ? AppSpacing.xl
                            : 110,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Descarta una alerta dejando siempre la puerta abierta: es una accion
  /// destructiva y antes no habia forma de deshacerla.
  void _descartar(BuildContext context, WidgetRef ref, Alerta alerta) {
    final notifier = ref.read(alertasProvider.notifier);
    notifier.eliminar(alerta.id);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Alerta de ${alerta.nombreProducto} descartada'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => notifier.restaurar(alerta),
          ),
        ),
      );
  }

  void _confirmarBorrado(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.paleta.marcaSuave,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.paleta.contorno),
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
                    color: context.paleta.contorno,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Borrar todas las alertas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.paleta.tinta,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta accion eliminara las alertas actuales. Las nuevas se generaran cuando corresponda.',
                style: TextStyle(fontSize: 12, color: context.paleta.apagado),
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
                            SnackBar(
                              content: Text('Alertas eliminadas'),
                              backgroundColor: context.paleta.marca,
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: context.paleta.vencido,
                      ),
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
    // La alerta guarda la receta de IA completa: no hace falta pedir nada.
    if ((receta.instrucciones ?? '').trim().isNotEmpty) return receta;

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
      ingredientes: detalle.ingredientes.isNotEmpty
          ? detalle.ingredientes
          : base.ingredientes,
      instrucciones: _limpiarHtml(info.instrucciones),
    );
  }

  String? _limpiarHtml(String? texto) {
    if (texto == null || texto.trim().isEmpty) return null;

    // Conserva los saltos de linea: las instrucciones de IA van un paso por
    // linea.
    final sinTags = texto.replaceAll(RegExp(r'<[^>]*>'), ' ');
    return sinTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\s*\n\s*'), '\n')
        .trim();
  }
}

/// Fondo que aparece al arrastrar una alerta: sin esto el gesto era invisible
/// y nadie lo descubria.
class _FondoDescartar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: paleta.vencido.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Descartar', style: AppTextStyles.rotulo(context)),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.delete_outline_rounded, color: paleta.vencido),
        ],
      ),
    );
  }
}
