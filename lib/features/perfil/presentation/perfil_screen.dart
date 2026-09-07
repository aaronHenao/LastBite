import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastbite/core/widgets/boton_volver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/responsive/responsive_container.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import '../domain/item_compra.dart';
import 'perfil_provider.dart';
import 'package:lastbite/core/responsive/responsive.dart';
import 'perfil_nutricional_screen.dart';

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
                      const BotonVolver(),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          final isWeb = Responsive.isTabletOrWeb(context);
                          final fotoUrl = user?.fotoUrl;

                          if (!isWeb && fotoUrl != null) {
                            return CircleAvatar(
                              radius: 44,
                              backgroundColor: context.paleta.marcaSuave,
                              backgroundImage: CachedNetworkImageProvider(
                                fotoUrl,
                              ),
                            );
                          }
                          if (fotoUrl != null) {
                            // En web CachedNetworkImage no se comporta bien,
                            // pero NetworkImage si: no hay razon para perder
                            // la foto del usuario en pantallas anchas.
                            return CircleAvatar(
                              radius: 44,
                              backgroundColor: context.paleta.marcaSuave,
                              backgroundImage: _buildImageProvider(fotoUrl),
                            );
                          }
                          return CircleAvatar(
                            radius: 44,
                            backgroundColor: context.paleta.marcaSuave,
                            child: Icon(
                              Icons.person,
                              size: 44,
                              color: context.paleta.apagado,
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
                          color: context.paleta.tinta,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: textTheme.bodySmall?.copyWith(
                          color: context.paleta.apagado,
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
                          color: context.paleta.marca.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: context.paleta.marca.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.check_mark_circled,
                              color: context.paleta.marca,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$salvados alimentos salvados',
                              style: textTheme.bodyMedium?.copyWith(
                                color: context.paleta.marca,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PerfilNutricionalScreen(),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.paleta.superficie,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: context.paleta.contorno),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu_outlined,
                                color: context.paleta.marca,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Perfil nutricional',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Adapta las recetas a tus preferencias',
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: context.paleta.apagado,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.cart,
                            size: 16,
                            color: context.paleta.marca,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'LISTA DE COMPRAS',
                            style: textTheme.titleSmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: context.paleta.apagado,
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
                                  foregroundColor: context.paleta.marca,
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
                loading: () => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(color: context.paleta.marca),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Error: $e',
                      style: TextStyle(color: context.paleta.vencido),
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
                            Icon(
                              CupertinoIcons.cart,
                              size: 48,
                              color: context.paleta.apagado,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tu lista de compras está vacía',
                              style: textTheme.bodyMedium?.copyWith(
                                color: context.paleta.apagado,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Los productos que consumas o elimines\naparecerán aquí',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: context.paleta.apagado.withValues(
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
                              color: context.paleta.apagado,
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
        backgroundColor: context.paleta.marcaSuave,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Limpiar comprados',
          style: TextStyle(
            color: context.paleta.tinta,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          '¿Eliminar todos los productos marcados como comprados?',
          style: TextStyle(color: context.paleta.apagado),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.paleta.apagado),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(listaComprasProvider.notifier).limpiarComprados();
            },
            style: FilledButton.styleFrom(backgroundColor: context.paleta.marca),
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
            color: context.paleta.superficie,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.comprado
                  ? context.paleta.marca.withValues(alpha: 0.3)
                  : context.paleta.contorno,
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
                    color: item.comprado ? context.paleta.marca : Colors.transparent,
                    border: Border.all(
                      color: item.comprado
                          ? context.paleta.marca
                          : context.paleta.apagado,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: item.comprado
                            ? context.paleta.apagado
                            : context.paleta.tinta,
                        decoration: item.comprado
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: context.paleta.apagado,
                      ),
                    ),
                    if (item.fechaConsumido != null ||
                        item.fechaVencido != null) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (item.fechaConsumido != null)
                            _FechaPill(
                              text:
                                  'Consumido: ${_formatearFecha(item.fechaConsumido!)}',
                              color: context.paleta.marca,
                            ),
                          if (item.fechaVencido != null)
                            _FechaPill(
                              text:
                                  'Venció: ${_formatearFecha(item.fechaVencido!)}',
                              color: context.paleta.vencido,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FechaPill extends StatelessWidget {
  final String text;
  final Color color;

  const _FechaPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

String _formatearFecha(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  return '$day/$month/$year';
}

ImageProvider _buildImageProvider(String url) {
  // En web CachedNetworkImage no funciona bien
  // usamos NetworkImage directamente
  return NetworkImage(url);
}