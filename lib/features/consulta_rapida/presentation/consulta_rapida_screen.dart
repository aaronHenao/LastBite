import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastbite/core/responsive/responsive_container.dart';
import 'package:lastbite/core/widgets/pastilla_estado.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';

class ConsultaRapidaScreen extends ConsumerStatefulWidget {
  const ConsultaRapidaScreen({super.key});

  @override
  ConsumerState<ConsultaRapidaScreen> createState() =>
      _ConsultaRapidaScreenState();
}

class _ConsultaRapidaScreenState extends ConsumerState<ConsultaRapidaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncProductos = ref.watch(despensaProvider);

    return asyncProductos.when(
      loading: () => Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.paleta.marca),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text(
            'Error cargando productos: $error',
            style: TextStyle(color: context.paleta.vencido),
          ),
        ),
      ),
      data: (productos) {
        final productosFiltrados = productos.where((producto) {
          final nombre = producto.nombre.toLowerCase();
          return nombre.contains(_query.trim().toLowerCase());
        }).toList()..sort((a, b) => a.nombre.compareTo(b.nombre));

        return Scaffold(
          backgroundColor: context.paleta.papel,
          appBar: AppBar(
            backgroundColor: context.paleta.papel,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: BackButton(color: context.paleta.tinta),
            title: Text(
              'Consulta Rápida',
              style: TextStyle(
                color: context.paleta.tinta,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          body: SafeArea(
            // Era la segunda pantalla sin acotar: en web las filas se
            // estiraban a todo el viewport, con el emoji pegado al borde
            // izquierdo y el chevron a mil pixeles de distancia.
            child: ResponsiveContainer(
              maxWidth: 700,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar producto',
                        hintStyle: TextStyle(color: context.paleta.apagado),
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          color: context.paleta.apagado,
                        ),
                        filled: true,
                        fillColor: context.paleta.superficie,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: context.paleta.marca,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (productos.isEmpty)
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Tu despensa está vacía.\nAgrega productos para consultarlos aquí.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: context.paleta.apagado,
                                    fontSize: 15,
                                  ),
                            ),
                          ),
                        ),
                      )
                    else if (productosFiltrados.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            'No se encontraron productos',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: context.paleta.apagado,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: productosFiltrados.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final producto = productosFiltrados[index];

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    _mostrarDetalleProducto(context, producto),
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: context.paleta.superficie,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: context.paleta.contorno,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: context.paleta.marcaSuave,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            producto.emoji,
                                            style: const TextStyle(
                                              fontSize: 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              producto.nombre,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    color: context.paleta.tinta,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${producto.cantidad} · ${_formatearFecha(producto.fechaCaducidad)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        context.paleta.apagado,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            PastillaEstado(
                                              dias: producto.diasRestantes,
                                              compacta: true,
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
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _estadoProducto(Producto producto) {
    if (producto.vencido) return 'vencido';
    if (producto.urgente) return 'próximo a vencer';
    return 'vigente';
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    return '$dia/$mes/$anio';
  }

  Color _estadoColor(Producto producto) {
    if (producto.vencido) return context.paleta.vencido;
    if (producto.urgente) return context.paleta.marca;
    return context.paleta.marca;
  }

  void _mostrarDetalleProducto(BuildContext context, Producto producto) {
    final estado = _estadoProducto(producto);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: context.paleta.superficie,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.paleta.contorno),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: context.paleta.contorno,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.paleta.marcaSuave,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      producto.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    producto.nombre,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.paleta.tinta,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DetalleFila(label: 'Cantidad', valor: producto.cantidad),
            _DetalleFila(
              label: 'Fecha de caducidad',
              valor: _formatearFecha(producto.fechaCaducidad),
            ),
            _DetalleFila(label: 'Estado', valor: estado),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _estadoColor(producto).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Producto $estado',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _estadoColor(producto),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetalleFila extends StatelessWidget {
  final String label;
  final String valor;

  const _DetalleFila({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.paleta.apagado,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.paleta.tinta,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
