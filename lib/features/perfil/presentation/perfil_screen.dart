import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/responsive/responsive_container.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import '../domain/item_compra.dart';
import 'perfil_provider.dart';
import 'package:lastbite/core/responsive/responsive.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authStateProvider);
    final asyncLista = ref.watch(listaComprasProvider);
    final salvados = ref
        .watch(despensaProvider)
        .maybeWhen(
          data: (_) => ref.read(despensaProvider.notifier).salvados,
          orElse: () => 0,
        );

    final user = authState.valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 700,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            child: Text(
                              '← Volver',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textMuted.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          final isWeb = Responsive.isTabletOrWeb(context);
                          final fotoUrl = user?.fotoUrl;

                          if (!isWeb && fotoUrl != null) {
                            return CircleAvatar(
                              radius: 44,
                              backgroundColor: AppColors.surface,
                              backgroundImage: CachedNetworkImageProvider(
                                fotoUrl,
                              ),
                            );
                          }
                          return CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.surface,
                            child: const Icon(
                              Icons.person,
                              size: 44,
                              color: AppColors.textMuted,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.nombre ?? 'Usuario',
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      //estadística de salvados
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.check_mark_circled,
                              color: AppColors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$salvados alimentos salvados',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.green,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.cart,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'LISTA DE COMPRAS',
                            style: textTheme.titleSmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Spacer(),
                          asyncLista.maybeWhen(
                            data: (items) {
                              final comprados = items.where((i) => i.comprado);
                              if (comprados.isEmpty) return const SizedBox();
                              return TextButton(
                                onPressed: () =>
                                    _confirmarLimpiar(context, ref),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.accent,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Limpiar comprados',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            },
                            orElse: () => const SizedBox(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              //lista de compras
              asyncLista.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Error: $e',
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.cart,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tu lista de compras está vacía',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Los productos que consumas o elimines\naparecerán aquí',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final pendientes = items.where((i) => !i.comprado).toList();
                  final comprados = items.where((i) => i.comprado).toList();

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      if (pendientes.isNotEmpty) ...[
                        ...pendientes.map(
                          (item) => _ItemCompraCard(
                            item: item,
                            onToggle: () => ref
                                .read(listaComprasProvider.notifier)
                                .toggleComprado(item.id),
                            onEliminar: () => ref
                                .read(listaComprasProvider.notifier)
                                .eliminar(item.id),
                          ),
                        ),
                      ],
                      if (comprados.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Text(
                            'COMPRADOS',
                            style: textTheme.titleSmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        ...comprados.map(
                          (item) => _ItemCompraCard(
                            item: item,
                            onToggle: () => ref
                                .read(listaComprasProvider.notifier)
                                .toggleComprado(item.id),
                            onEliminar: () => ref
                                .read(listaComprasProvider.notifier)
                                .eliminar(item.id),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarLimpiar(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Limpiar comprados',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          '¿Eliminar todos los productos marcados como comprados?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(listaComprasProvider.notifier).limpiarComprados();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}

class _ItemCompraCard extends StatelessWidget {
  final ItemCompra item;
  final VoidCallback onToggle;
  final VoidCallback onEliminar;

  const _ItemCompraCard({
    required this.item,
    required this.onToggle,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GestureDetector(
        onLongPress: onEliminar,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.comprado
                  ? AppColors.green.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.comprado ? AppColors.green : Colors.transparent,
                    border: Border.all(
                      color: item.comprado
                          ? AppColors.green
                          : AppColors.textMuted,
                      width: 2,
                    ),
                  ),
                  child: item.comprado
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(item.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.nombre,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: item.comprado
                        ? AppColors.textMuted
                        : AppColors.textMain,
                    decoration: item.comprado
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

ImageProvider _buildImageProvider(String url) {
  // En web CachedNetworkImage no funciona bien
  // usamos NetworkImage directamente
  return NetworkImage(url);
}
