import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/producto.dart';
import 'widgets/producto_card.dart';

class DespensaScreen extends ConsumerWidget {
  const DespensaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final productos = [...ref.watch(despensaProvider)]
      ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));

    final urgentes = productos.where((p) => p.urgente).toList();
    final enBuenEstado = productos.where((p) => !p.urgente).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            //Header
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
                              'MI DESPENSA',
                              style: textTheme.titleSmall?.copyWith(
                                letterSpacing: 2.4,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'LastBite 🌿',
                              style: textTheme.bodyLarge?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.surface,
                          child: Icon(Icons.person, color: AppColors.textMain),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    //Stats bar
                    Row(
                      children: [
                        _StatCard(
                          icon: CupertinoIcons.archivebox,
                          value: '${productos.length}',
                          label: 'Productos',
                          color: AppColors.textMain,
                          bg: AppColors.surface,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          icon: CupertinoIcons.clock,
                          value: '${urgentes.length}',
                          label: 'Por vencer',
                          color: AppColors.danger,
                          bg: AppColors.danger.withValues(alpha: 0.15),
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          icon: CupertinoIcons.check_mark_circled,
                          value: '12',
                          label: 'Salvados',
                          color: AppColors.green,
                          bg: AppColors.green.withValues(alpha: 0.15),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            if (urgentes.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 16,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PRÓXIMOS A VENCER',
                        style: textTheme.titleSmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.danger,
                    ),
                  ),
                    ],
                  )
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: ProductoCard(producto: urgentes[index]),
                  ),
                  childCount: urgentes.length,
                ),
              ),
            ],

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.cube_box_fill, 
                      size: 16, 
                      color: AppColors.green
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'EN BUEN ESTADO',
                      style: textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: AppColors.textMuted,
                      ),
                    ),

                  ],

                )
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: ProductoCard(producto: enBuenEstado[index]),
                ),
                childCount: enBuenEstado.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 25, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
