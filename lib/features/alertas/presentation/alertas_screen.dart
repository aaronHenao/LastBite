import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'alertas_provider.dart';
import '../domain/alerta.dart';

class AlertasScreen extends ConsumerWidget {
  const AlertasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAlertas = ref.watch(alertasProvider);
    final textTheme = Theme.of(context).textTheme;

    return asyncAlertas.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ),
      data: (alertas) {
        final sorted = [...alertas]
          ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NOTIFICACIONES',
                              style: textTheme.titleSmall?.copyWith(
                                letterSpacing: 2.4,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Alertas',
                              style: textTheme.bodyLarge?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                        if (alertas.isNotEmpty)
                          GestureDetector(
                            onTap: () => _confirmarBorrarTodo(context, ref),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    CupertinoIcons.delete,
                                    size: 14,
                                    color: AppColors.danger,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Borrar todo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                if (sorted.isEmpty) ...[
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
                            const SizedBox(height: 16),
                            Text(
                              'Sin alertas',
                              style: textTheme.bodyLarge?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cuando un producto esté por vencer,\naparecerá aquí.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: AppColors.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final alerta = sorted[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AlertaCard(
                              alerta: alerta,
                              onDismissed: () => ref
                                  .read(alertasProvider.notifier)
                                  .eliminar(alerta.id),
                            ),
                          );
                        },
                        childCount: sorted.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmarBorrarTodo(BuildContext context, WidgetRef ref) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                '¿Borrar todas las alertas?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(
                CupertinoIcons.delete,
                color: AppColors.danger,
              ),
              title: const Text(
                'Sí, borrar todas',
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(alertasProvider.notifier).eliminarTodas();
              },
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.xmark_circle,
                color: AppColors.textMuted,
              ),
              title: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AlertaCard extends StatelessWidget {
  final Alerta alerta;
  final VoidCallback onDismissed;

  const _AlertaCard({required this.alerta, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    final dias = alerta.diasRestantes;
    final color = AppTheme.diasColor(dias);
    final tieneReceta =
        alerta.recetaTitulo != null && alerta.umbral <= 3;

    return Dismissible(
      key: Key(alerta.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          CupertinoIcons.delete,
          color: AppColors.danger,
          size: 24,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  alerta.productoEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alerta.productoNombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _mensaje(dias),
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _DiasBadge(dias: dias, color: color),
              ],
            ),
            if (tieneReceta) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alerta.recetaTitulo!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _mensaje(int dias) {
    if (dias <= 0) return '¡Ya venció! — revísalo';
    if (dias == 1) return '¡Vence mañana! — úsalo hoy';
    if (dias <= 3) return 'Vence en $dias días — te sugerimos una receta';
    return 'Vence en $dias días';
  }
}

class _DiasBadge extends StatelessWidget {
  final int dias;
  final Color color;

  const _DiasBadge({required this.dias, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dias <= 0 ? '¡Vencido!' : '${dias}d',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          if (dias <= 1) ...[
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              size: 12,
              color: color,
            ),
          ],
        ],
      ),
    );
  }
}
