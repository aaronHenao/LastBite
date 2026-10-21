import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastbite/core/responsive/responsive_container.dart';
import 'package:lastbite/core/utils/texto.dart';
import 'package:lastbite/core/widgets/estado_vacio.dart';
import 'package:lastbite/core/widgets/pastilla_estado.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/consulta_rapida/presentation/historial_busqueda_provider.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import 'package:lastbite/core/widgets/estado_error.dart';
import 'package:lastbite/l10n/textos_dominio.dart';
import 'package:lastbite/l10n/traducciones.dart';

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

  void _limpiar() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _buscar(String termino) {
    final valor = termino.trim();
    _searchController.text = valor;
    setState(() => _query = valor);
    if (valor.isNotEmpty) {
      ref.read(historialBusquedaProvider.notifier).agregar(valor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncProductos = ref.watch(despensaProvider);
    final historial = ref.watch(historialBusquedaProvider);

    return asyncProductos.when(
      loading: () => Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.paleta.marca),
        ),
      ),
      error: (error, _) => Scaffold(
        body: EstadoError(
          mensaje: context.t.consultaErrorCarga,
          detalle: error,
          onReintentar: () => ref.invalidate(despensaProvider),
        ),
      ),
      data: (productos) {
        final productosFiltrados =
            productos
                .where((p) => coincideBusqueda(p.nombre, _query))
                .toList()
              ..sort((a, b) => a.nombre.compareTo(b.nombre));

        return Scaffold(
          backgroundColor: context.paleta.papel,
          appBar: AppBar(
            backgroundColor: context.paleta.papel,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: BackButton(color: context.paleta.tinta),
            title: Text(
              context.t.consultaTitulo,
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
                      textInputAction: TextInputAction.search,
                      onSubmitted: _buscar,
                      decoration: InputDecoration(
                        hintText: context.t.consultaBuscar,
                        hintStyle: TextStyle(color: context.paleta.apagado),
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          color: context.paleta.apagado,
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: context.t.accionLimpiarBusqueda,
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: context.paleta.apagado,
                                ),
                                onPressed: _limpiar,
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
                    if (_query.trim().isEmpty && historial.isNotEmpty) ...[
                      _HistorialBusquedas(
                        terminos: historial,
                        onSeleccionar: _buscar,
                        onLimpiar: () =>
                            ref.read(historialBusquedaProvider.notifier).limpiar(),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (productos.isEmpty)
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              context.t.consultaVacia,
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
                      // Dice que buscaste, que probar y como salir: antes era
                      // un "No se encontraron productos" sin siguiente paso.
                      Expanded(
                        child: SingleChildScrollView(
                          child: EstadoVacio(
                            icono: Icons.search_off_rounded,
                            titulo: context.t.consultaSinResultados(
                              _query.trim(),
                            ),
                            descripcion:
                                context.t.consultaSinResultadosDescripcion,
                            textoAccion: context.t.accionLimpiarBusqueda,
                            onAccion: _limpiar,
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
                                              '${context.t.cantidad(producto.cantidad)} · '
                                              '${_formatearFecha(producto.fechaCaducidad)}',
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
    if (producto.vencido) return context.t.consultaEstadoVencido;
    if (producto.urgente) return context.t.consultaEstadoPorVencer;
    return context.t.consultaEstadoVigente;
  }

  /// Con el formato de fecha del idioma activo: 20/10/2026 o 10/20/2026.
  String _formatearFecha(DateTime fecha) =>
      MaterialLocalizations.of(context).formatCompactDate(fecha);

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
            _DetalleFila(
              label: context.t.consultaCantidad,
              valor: context.t.cantidad(producto.cantidad),
            ),
            _DetalleFila(
              label: context.t.consultaFechaCaducidad,
              valor: _formatearFecha(producto.fechaCaducidad),
            ),
            _DetalleFila(label: context.t.consultaEstado, valor: estado),
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
                  estado,
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

/// Chips con las ultimas busquedas: volver a encontrar algo ya buscado no
/// deberia depender de recordar el termino exacto otra vez.
class _HistorialBusquedas extends StatelessWidget {
  const _HistorialBusquedas({
    required this.terminos,
    required this.onSeleccionar,
    required this.onLimpiar,
  });

  final List<String> terminos;
  final ValueChanged<String> onSeleccionar;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.t.consultaHistorialTitulo,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: paleta.apagado,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: onLimpiar,
              child: Text(context.t.consultaHistorialLimpiar),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final termino in terminos)
              ActionChip(
                label: Text(termino),
                backgroundColor: paleta.superficie,
                side: BorderSide(color: paleta.contorno),
                labelStyle: TextStyle(color: paleta.tinta),
                onPressed: () => onSeleccionar(termino),
              ),
          ],
        ),
      ],
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
