import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/producto.dart';
import 'widgets/producto_card.dart';
import 'widgets/ui_states.dart';
import '../../auth/presentation/auth_provider.dart';

// Provider de conectividad
final conectividadProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );
});

class DespensaScreen extends ConsumerWidget {
  final VoidCallback? onAgregar;
  const DespensaScreen({super.key, this.onAgregar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authStateProvider);
    final nombreUsuario = authState.when(
      data: (user) =>
          user?.nombre?.trim().isNotEmpty == true ? user!.nombre! : 'Mi cuenta',
      loading: () => 'Mi cuenta',
      error: (_, __) => 'Mi cuenta',
    );

    // Conectividad
    final conectado = ref.watch(conectividadProvider).maybeWhen(
      data: (value) => value,
      orElse: () => true,
    );

    final asyncProductos = ref.watch(despensaProvider);
    return asyncProductos.when(
      loading: () => const Scaffold(
        body: DespensaLoadingState(),
      ),
      error: (e, _) => Scaffold(
        body: ErrorDespensaState(
          mensaje: 'Error cargando despensa: $e',
          onReintentar: () => ref.invalidate(despensaProvider),
        ),
      ),
      data: (productos) {
        final sorted = [...productos]
          ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));
        final urgentes = sorted.where((p) => p.urgente).toList();
        final enBuenEstado = sorted.where((p) => !p.urgente).toList();
        final salvados = ref
            .watch(despensaProvider)
            .maybeWhen(
              data: (_) => ref.read(despensaProvider.notifier).salvados,
              orElse: () => 0,
            );

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Banner sin conexión
                if (!conectado) const OfflineBanner(),

                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  GestureDetector(
                                    onTap: () => _mostrarMenuPerfil(
                                      context,
                                      ref,
                                      nombreUsuario,
                                    ),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.surface,
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.textMain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),

                              // Stats bar
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
                                    value: '$salvados',
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

                      if (productos.isEmpty) ...[
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyDespensaState(onAgregar: onAgregar),
                        ),
                      ] else ...[
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
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                child: ProductoCard(
                                  producto: urgentes[index],
                                  onTap: () => _mostrarAcciones(
                                      context, ref, urgentes[index]),
                                ),
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
                                  color: AppColors.green,
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
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                              child: ProductoCard(
                                producto: enBuenEstado[index],
                                onTap: () => _mostrarAcciones(
                                    context, ref, enBuenEstado[index]),
                              ),
                            ),
                            childCount: enBuenEstado.length,
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarMenuPerfil(
    BuildContext context,
    WidgetRef ref,
    String nombreUsuario,
  ) {
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
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                    child: const Icon(Icons.person, color: AppColors.accent),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    nombreUsuario,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authServiceProvider).cerrarSesion();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _mostrarAcciones(
    BuildContext context,
    WidgetRef ref,
    Producto producto,
  ) {
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
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  Text(producto.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(
                CupertinoIcons.check_mark_circled,
                color: AppColors.green,
              ),
              title: const Text(
                'Marcar como consumido',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Suma a tus alimentos salvados',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(despensaProvider.notifier).consumir(producto.id);
                if (context.mounted) {
                  mostrarExitoSnackBar(context, '¡${producto.nombre} salvado!');
                }
              },
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.delete,
                color: AppColors.danger,
              ),
              title: const Text(
                'Eliminar',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              subtitle: const Text(
                'No suma a alimentos salvados',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(despensaProvider.notifier).eliminar(producto.id);
              },
            ),
            const SizedBox(height: 16),
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
