import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/interruptor_tema.dart';
import '../../../core/widgets/aviso_deshacer.dart';
import '../../../core/widgets/avatar_usuario.dart';
import '../../../core/widgets/boton_ayuda.dart';
import '../../../core/widgets/estado_vacio.dart';
import '../../../core/widgets/estado_error.dart';
import '../../../core/responsive/responsive_container.dart';
import '../../../core/constants/precio_promedio.dart';
import '../domain/producto.dart';
import 'widgets/producto_card.dart';
import '../../compartida/presentation/compartida_provider.dart';
import '../../compartida/presentation/compartida_screen.dart';
import '../../compartida/presentation/textos_compartida.dart';
import '../../ajustes/presentation/ajustes_screen.dart';
import '../../ayuda/presentation/ayuda_screen.dart';
import '../../perfil/presentation/perfil_screen.dart';
import '../../perfil/domain/item_compra.dart';
import '../../perfil/presentation/perfil_provider.dart';
import '../../consulta_rapida/presentation/consulta_rapida_screen.dart';
import 'package:lastbite/core/responsive/responsive.dart';
import 'package:lastbite/l10n/app_localizations.dart';
import 'package:lastbite/l10n/textos_dominio.dart';
import 'package:lastbite/l10n/traducciones.dart';

import '../../auth/presentation/auth_provider.dart';

class DespensaScreen extends ConsumerWidget {
  final VoidCallback? onAgregar;
  const DespensaScreen({super.key, this.onAgregar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final t = context.t;
    final nombreUsuario = authState.when(
      data: (user) =>
          user?.nombre?.trim().isNotEmpty == true ? user!.nombre! : t.cuentaMia,
      loading: () => t.cuentaMia,
      error: (_, __) => t.cuentaMia,
    );

    final despensaCompartida = ref
        .watch(despensaCompartidaProvider)
        .valueOrNull;
    final tituloDespensa =
        despensaCompartida?.nombreVisible(t) ?? t.despensaTitulo;

    final asyncProductos = ref.watch(despensaProvider);
    final paleta = context.paleta;

    return asyncProductos.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: EstadoError(
          mensaje: t.despensaErrorCarga,
          detalle: e,
          onReintentar: () => ref.invalidate(despensaProvider),
        ),
      ),
      data: (productos) {
        final ordenados = [...productos]
          ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));
        final urgentes = ordenados.where((p) => p.urgente).toList();
        final enBuenEstado = ordenados.where((p) => !p.urgente).toList();

        final notifier = ref.read(despensaProvider.notifier);
        final salvados = notifier.salvados;
        final ahorro = notifier.ahorroMes;
        final conteoAhorro = notifier.conteoMes;

        final user = authState.valueOrNull;
        final anchoAmplio = Responsive.isTabletOrWeb(context);
        // El rail solo entra cuando sobra ancho de verdad: en tablet dejaria
        // el contenido en poco mas de 400px.
        final conRail = Responsive.isWeb(context);

        final encabezado = _Encabezado(
          titulo: tituloDespensa,
          fotoUrl: user?.fotoUrl,
          enColumna: conRail,
          productos: productos.length,
          salvados: salvados,
          porVencer: urgentes.length,
          ahorro: ahorro,
          conteoAhorro: conteoAhorro,
          onPerfil: () => _mostrarMenuPerfil(context, ref, nombreUsuario),
        );

        final secciones = <Widget>[
          if (productos.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EstadoVacio(
                icono: CupertinoIcons.cube_box,
                titulo: t.despensaVaciaTitulo,
                descripcion: t.despensaVaciaDescripcion,
                textoAccion: t.accionAgregarProducto,
                onAccion: onAgregar,
              ),
            )
          else ...[
            // Cada seccion se dibuja solo si tiene contenido: antes el
            // encabezado "EN BUEN ESTADO" quedaba solo, sin lista
            // debajo, cuando todo estaba por vencer.
            if (urgentes.isNotEmpty)
              ..._seccion(
                context: context,
                ref: ref,
                icono: CupertinoIcons.exclamationmark_triangle_fill,
                titulo: t.despensaProximosAVencer,
                color: paleta.critico,
                productos: urgentes,
                anchoAmplio: anchoAmplio,
              ),
            if (enBuenEstado.isNotEmpty)
              ..._seccion(
                context: context,
                ref: ref,
                icono: CupertinoIcons.cube_box_fill,
                titulo: t.despensaEnBuenEstado,
                color: paleta.apagado,
                productos: enBuenEstado,
                anchoAmplio: anchoAmplio,
              ),
            // Solo en movil hay barra flotante que tapar.
            SliverToBoxAdapter(
              child: SizedBox(height: anchoAmplio ? AppSpacing.xl : 100),
            ),
          ],
        ];

        return Scaffold(
          body: SafeArea(
            child: conRail
                // Las cifras quedan fijas a la izquierda mientras recorres la
                // despensa, y los productos se llevan el ancho restante.
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: 260, child: encabezado),
                      Expanded(child: CustomScrollView(slivers: secciones)),
                    ],
                  )
                : ResponsiveContainer(
                    maxWidth: 900,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: encabezado),
                        ...secciones,
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// Encabezado y lista de una seccion. En pantallas anchas la lista pasa a
  /// dos columnas, pero sigue siendo un sliver perezoso: la version anterior
  /// instanciaba todas las tarjetas de una vez justo donde mas se ven.
  List<Widget> _seccion({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icono,
    required String titulo,
    required Color color,
    required List<Producto> productos,
    required bool anchoAmplio,
  }) {
    final textTheme = Theme.of(context).textTheme;

    Widget tarjeta(int index) => ProductoCard(
      producto: productos[index],
      onTap: () => _mostrarAcciones(context, ref, productos[index]),
    );

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            anchoAmplio ? AppSpacing.xl : AppSpacing.lg,
            AppSpacing.lg,
            anchoAmplio ? AppSpacing.xl : AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icono, size: 16, color: color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  titulo,
                  style: textTheme.labelSmall?.copyWith(color: color),
                ),
              ),
              // El contador era casi imperceptible (11px en gris): ahora es
              // una pastilla con el color de la seccion.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: context.paleta.superficie,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${productos.length}',
                  style: textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: anchoAmplio ? AppSpacing.xl : AppSpacing.lg,
        ),
        sliver: anchoAmplio
            ? SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => tarjeta(index),
                  childCount: productos.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 520,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.sm,
                  mainAxisExtent: 76,
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: tarjeta(index),
                  ),
                  childCount: productos.length,
                ),
              ),
      ),
    ];
  }

  void _mostrarMenuPerfil(
    BuildContext context,
    WidgetRef ref,
    String nombreUsuario,
  ) {
    // Desplazable: con la ayuda suma un item y en telefonos bajos ya no
    // entraba en el alto que deja una hoja inferior.
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        // Material y no un Container decorado: sobre el fondo de un
        // DecoratedBox la tinta de los ListTile no se veia al tocar.
        child: Material(
          color: context.paleta.marcaSuave,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: context.paleta.contorno),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.paleta.contorno,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PerfilScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: context.paleta.marcaClara.withValues(
                            alpha: 0.15,
                          ),
                          child: Icon(
                            Icons.person,
                            color: context.paleta.marcaClara,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreUsuario,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: context.paleta.tinta,
                                ),
                              ),
                              Text(
                                context.t.cuentaPerfilAyuda,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.paleta.apagado,
                                ),
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
                Divider(color: context.paleta.contorno),
                Consumer(
                  builder: (context, ref, _) {
                    final compartida = ref
                        .watch(despensaCompartidaProvider)
                        .valueOrNull;

                    return ListTile(
                      leading: Icon(
                        Icons.groups_rounded,
                        color: context.paleta.marca,
                      ),
                      title: Text(
                        context.t.cuentaCompartida,
                        style: TextStyle(
                          color: context.paleta.tinta,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        compartida == null
                            ? context.t.cuentaCompartidaAyuda
                            : compartida.nombreVisible(context.t),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.paleta.apagado,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: context.paleta.apagado,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DespensaCompartidaScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
                Divider(color: context.paleta.contorno),
                ListTile(
                  leading: Icon(
                    CupertinoIcons.search,
                    color: context.paleta.marcaClara,
                  ),
                  title: Text(
                    context.t.cuentaConsultaRapida,
                    style: TextStyle(
                      color: context.paleta.tinta,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    context.t.cuentaConsultaRapidaAyuda,
                    style: TextStyle(color: context.paleta.apagado, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConsultaRapidaScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.accessibility_new_rounded,
                    color: context.paleta.marca,
                  ),
                  title: Text(
                    context.t.cuentaAccesibilidad,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    context.t.cuentaAccesibilidadAyuda,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AjustesScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.help_outline_rounded,
                    color: context.paleta.marca,
                  ),
                  title: Text(
                    context.t.cuentaAyuda,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    context.t.ayudaDescripcion,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AyudaScreen()),
                    );
                  },
                ),
                Divider(color: context.paleta.contorno),
                ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: context.paleta.vencido,
                  ),
                  title: Text(
                    context.t.cuentaCerrarSesion,
                    style: TextStyle(
                      color: context.paleta.vencido,
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
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        // Material y no un Container decorado: sobre el fondo de un
        // DecoratedBox la tinta de los ListTile no se veia al tocar.
        child: Material(
          color: context.paleta.marcaSuave,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: context.paleta.contorno),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.paleta.contorno,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.paleta.tinta,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: context.paleta.contorno),
              ListTile(
                leading: Icon(
                  CupertinoIcons.check_mark_circled,
                  color: context.paleta.marca,
                ),
                title: Text(
                  context.t.despensaConsumir,
                  style: TextStyle(
                    color: context.paleta.tinta,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  context.t.despensaConsumirAyuda,
                  style: TextStyle(color: context.paleta.apagado, fontSize: 12),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final t = context.t;
                  final despensa = ref.read(despensaProvider.notifier);
                  await despensa.consumir(producto.id);
                  if (!context.mounted) return;
                  final item = await _preguntarListaCompras(
                    context,
                    ref,
                    producto,
                    fechaConsumido: DateTime.now(),
                  );
                  if (!context.mounted) return;
                  _avisarConDeshacer(
                    context,
                    ref,
                    mensaje: item == null
                        ? t.despensaSalvado(producto.nombre)
                        : t.despensaSalvadoYEnLista(producto.nombre),
                    itemLista: item,
                    deshacer: () => despensa.deshacerConsumo(producto),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  CupertinoIcons.delete,
                  color: context.paleta.vencido,
                ),
                title: Text(
                  context.t.despensaEliminar,
                  style: TextStyle(
                    color: context.paleta.vencido,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  context.t.despensaEliminarAyuda,
                  style: TextStyle(color: context.paleta.apagado, fontSize: 12),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final t = context.t;
                  final despensa = ref.read(despensaProvider.notifier);
                  await despensa.eliminar(producto.id);
                  if (!context.mounted) return;
                  final item = await _preguntarListaCompras(
                    context,
                    ref,
                    producto,
                    fechaVencido: producto.vencido
                        ? producto.fechaCaducidad
                        : null,
                  );
                  if (!context.mounted) return;
                  _avisarConDeshacer(
                    context,
                    ref,
                    mensaje: item == null
                        ? t.despensaEliminado(producto.nombre)
                        : t.despensaEliminadoYEnLista(producto.nombre),
                    itemLista: item,
                    deshacer: () => despensa.agregar(producto),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
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
  final bool expandido;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
    this.expandido = true,
  });

  @override
  Widget build(BuildContext context) {
    final tarjeta = Container(
      width: double.infinity,
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
              fontSize: 11,
              color: context.paleta.apagado,
            ),
          ),
        ],
      ),
    );

    return expandido ? Expanded(child: tarjeta) : tarjeta;
  }
}

/// Pesos colombianos con los separadores del idioma: "$47.000" en español,
/// "$47,000" en ingles.
String _formatearCop(L10n t, int valor) => NumberFormat.currency(
  locale: t.localeName,
  symbol: r'$',
  decimalDigits: 0,
).format(valor);

/// Muestra "1,2 kg", "500 g", "3 unidades" segun la magnitud, con el
/// separador decimal del idioma.
String _formatearCantidad(L10n t, String categoria, double cantidad) {
  final base = precioDeCategoria(categoria).base;

  if (base == BaseMedida.unidad) {
    final entero = cantidad.round();
    return t.cantidadUnidades('$entero', entero);
  }

  if (cantidad < 1) {
    final chico = (cantidad * 1000).round();
    return base == BaseMedida.kilo ? '$chico g' : '$chico ml';
  }

  final texto = NumberFormat('0.#', t.localeName).format(cantidad);
  return '$texto ${base.abreviatura}';
}

class _AhorroCard extends StatelessWidget {
  final int ahorro;
  final Map<String, double> conteo;

  const _AhorroCard({required this.ahorro, required this.conteo});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = context.t;
    final top = conteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.paleta.marca.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.money_dollar_circle,
                size: 16,
                color: context.paleta.marca,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  t.despensaAhorroMes(DateTime.now()).toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: context.paleta.apagado,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatearCop(t, ahorro),
            style: textTheme.titleLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.paleta.marca,
            ),
          ),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                t.despensaAhorroVacio,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: context.paleta.apagado,
                ),
              ),
            )
          else ...[
            const SizedBox(height: 8),
            Text(
              top
                  .take(3)
                  .map(
                    (e) =>
                        '${t.categoria(e.key)} '
                        '${_formatearCantidad(t, e.key, e.value)}',
                  )
                  .join('  ·  '),
              style: textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: context.paleta.apagado,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.despensaAhorroNota,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: context.paleta.apagado,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Cierra una accion sobre un producto: dice que paso y deja deshacerla.
/// Si ademas se sumo a la lista de compras, deshacer tambien lo saca de ahi:
/// la persona revierte lo que hizo, no la mitad.
void _avisarConDeshacer(
  BuildContext context,
  WidgetRef ref, {
  required String mensaje,
  required ItemCompra? itemLista,
  required Future<void> Function() deshacer,
}) {
  final lista = ref.read(listaComprasProvider.notifier);
  mostrarAvisoDeshacer(
    context,
    mensaje: mensaje,
    onDeshacer: () async {
      await deshacer();
      if (itemLista != null) await lista.eliminar(itemLista.id);
    },
  );
}

/// Ofrece sumar el producto a la lista de compras. Devuelve lo que se agrego,
/// o null si la persona dijo que no.
Future<ItemCompra?> _preguntarListaCompras(
  BuildContext context,
  WidgetRef ref,
  Producto producto, {
  DateTime? fechaConsumido,
  DateTime? fechaVencido,
}) async {
  final lista = ref.read(listaComprasProvider.notifier);
  final anadir = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: context.paleta.marcaSuave,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Text(producto.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.t.despensaListaPregunta,
              style: TextStyle(
                color: context.paleta.tinta,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        context.t.despensaListaDescripcion(producto.nombre),
        style: TextStyle(color: context.paleta.apagado, fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(
            context.t.despensaListaNo,
            style: TextStyle(color: context.paleta.apagado),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(
            backgroundColor: context.paleta.marcaClara,
          ),
          child: Text(context.t.despensaListaSi),
        ),
      ],
    ),
  );
  if (anadir != true) return null;

  // El resultado se cuenta en el aviso con "Deshacer": un segundo aviso
  // propio quedaria en cola y taparia esa opcion.
  final item = ItemCompra(
    id: '${producto.id}_${DateTime.now().millisecondsSinceEpoch}',
    nombre: producto.nombre,
    emoji: producto.emoji,
    comprado: false,
    agregadoEn: DateTime.now(),
    fechaConsumido: fechaConsumido,
    fechaVencido: fechaVencido,
  );
  await lista.agregar(item);
  return item;
}

class _BotonPerfil extends StatelessWidget {
  const _BotonPerfil({required this.fotoUrl, required this.onTap});

  final String? fotoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.t.cuentaMenu,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AvatarUsuario(fotoUrl: fotoUrl),
        ),
      ),
    );
  }
}

/// Cabecera de la despensa: identidad y cifras.
///
/// En web se dibuja como un rail fijo a la izquierda, para que las cifras
/// queden a la vista mientras recorres los productos. En pantallas mas
/// angostas vuelve a ser una franja horizontal arriba.
class _Encabezado extends StatelessWidget {
  const _Encabezado({
    required this.titulo,
    required this.fotoUrl,
    required this.enColumna,
    required this.productos,
    required this.salvados,
    required this.porVencer,
    required this.ahorro,
    required this.conteoAhorro,
    required this.onPerfil,
  });

  final String titulo;
  final String? fotoUrl;
  final bool enColumna;
  final int productos;
  final int salvados;
  final int porVencer;
  final int ahorro;
  final Map<String, double> conteoAhorro;
  final VoidCallback onPerfil;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paleta = context.paleta;

    // En el rail la marca y la cuenta ya viven en la barra de navegacion:
    // repetirlas aca solo gastaria espacio.
    final identidad = Row(
      children: [
        if (!enColumna) ...[
          Image.asset(
            'lib/assets/images/logo_icono.png',
            height: 30,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Text(
            titulo,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: textTheme.displaySmall,
          ),
        ),
        if (!enColumna) ...[
          const SizedBox(width: AppSpacing.sm),
          if (!Responsive.isTabletOrWeb(context)) ...[
            const InterruptorTema(),
            const BotonAyuda(seccion: SeccionAyuda.despensa),
          ],
          _BotonPerfil(fotoUrl: fotoUrl, onTap: onPerfil),
        ],
      ],
    );

    final cifras = [
      _StatCard(
        icon: CupertinoIcons.archivebox,
        value: '$productos',
        label: context.t.despensaProductos,
        color: paleta.tinta,
        bg: paleta.superficieSuave,
        expandido: !enColumna,
      ),
      _StatCard(
        icon: CupertinoIcons.check_mark_circled,
        value: '$salvados',
        label: context.t.despensaSalvados,
        color: paleta.marca,
        bg: paleta.marcaSuave,
        expandido: !enColumna,
      ),
      _StatCard(
        icon: CupertinoIcons.clock,
        value: '$porVencer',
        label: context.t.despensaPorVencer,
        color: paleta.critico,
        bg: paleta.critico.withValues(alpha: 0.12),
        expandido: !enColumna,
      ),
    ];

    if (!enColumna) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            identidad,
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                cifras[0],
                const SizedBox(width: AppSpacing.sm),
                cifras[1],
                const SizedBox(width: AppSpacing.sm),
                cifras[2],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const _AccesosRapidos(enColumna: false),
            const SizedBox(height: AppSpacing.md),
            _AhorroCard(ahorro: ahorro, conteo: conteoAhorro),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: paleta.contorno)),
      ),
      // La identidad y las cifras arriba, el ahorro anclado abajo: asi el
      // rail ocupa su alto en vez de amontonarse contra el borde superior.
      // Scrollea por su cuenta si la pantalla es muy baja.
      child: LayoutBuilder(
        builder: (context, restricciones) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: restricciones.maxHeight - AppSpacing.lg * 2,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  identidad,
                  const SizedBox(height: AppSpacing.xl),
                  cifras[0],
                  const SizedBox(height: AppSpacing.sm),
                  cifras[1],
                  const SizedBox(height: AppSpacing.sm),
                  cifras[2],
                  const SizedBox(height: AppSpacing.lg),
                  const _AccesosRapidos(enColumna: true),
                  const Spacer(),
                  const SizedBox(height: AppSpacing.lg),
                  _AhorroCard(ahorro: ahorro, conteo: conteoAhorro),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Accesos directos a las vistas que vivian escondidas en el menu de la
/// cuenta. La evaluacion marco con severidad Mayor que la lista de compras,
/// la despensa compartida y la consulta rapida no se encontraban, y que
/// costaba volver a localizar lo que se habia buscado antes.
class _AccesosRapidos extends StatelessWidget {
  const _AccesosRapidos({required this.enColumna});

  /// En el rail van uno debajo del otro; en movil, en fila como las cifras.
  final bool enColumna;

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    void abrir(Widget pantalla) => Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => pantalla),
    );

    final accesos = [
      _Acceso(
        icono: CupertinoIcons.cart,
        etiqueta: t.accesoListaCompras,
        onTap: () => abrir(const PerfilScreen()),
      ),
      _Acceso(
        icono: Icons.groups_rounded,
        etiqueta: t.accesoCompartida,
        onTap: () => abrir(const DespensaCompartidaScreen()),
      ),
      _Acceso(
        icono: CupertinoIcons.search,
        etiqueta: t.accesoBuscar,
        onTap: () => abrir(const ConsultaRapidaScreen()),
      ),
    ];

    if (enColumna) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final acceso in accesos) ...[
            acceso,
            if (acceso != accesos.last) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      );
    }

    // Mismo alto para los tres aunque una etiqueta ocupe dos lineas.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final acceso in accesos) ...[
            Expanded(child: acceso),
            if (acceso != accesos.last) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _Acceso extends StatelessWidget {
  const _Acceso({
    required this.icono,
    required this.etiqueta,
    required this.onTap,
  });

  final IconData icono;
  final String etiqueta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;

    return Material(
      color: paleta.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: paleta.contorno),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 18, color: paleta.marca),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  etiqueta,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: paleta.marca),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
