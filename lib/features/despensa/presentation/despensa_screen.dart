import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/interruptor_tema.dart';
import '../../../core/widgets/estado_vacio.dart';
import '../../../core/widgets/estado_error.dart';
import '../../../core/responsive/responsive_container.dart';
import '../../../core/constants/precio_promedio.dart';
import '../domain/producto.dart';
import 'widgets/producto_card.dart';
import '../../compartida/presentation/compartida_provider.dart';
import '../../compartida/presentation/compartida_screen.dart';
import '../../perfil/presentation/perfil_screen.dart';
import '../../perfil/domain/item_compra.dart';
import '../../perfil/presentation/perfil_provider.dart';
import '../../consulta_rapida/presentation/consulta_rapida_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lastbite/core/responsive/responsive.dart';

import '../../auth/presentation/auth_provider.dart';

class DespensaScreen extends ConsumerWidget {
  final VoidCallback? onAgregar;
  const DespensaScreen({super.key, this.onAgregar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final nombreUsuario = authState.when(
      data: (user) =>
          user?.nombre?.trim().isNotEmpty == true ? user!.nombre! : 'Mi cuenta',
      loading: () => 'Mi cuenta',
      error: (_, __) => 'Mi cuenta',
    );

    final despensaCompartida = ref
        .watch(despensaCompartidaProvider)
        .valueOrNull;
    final tituloDespensa = despensaCompartida?.nombre ?? 'Mi Despensa';

    final asyncProductos = ref.watch(despensaProvider);
    final paleta = context.paleta;

    return asyncProductos.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: EstadoError(
          mensaje: 'No pudimos cargar tu despensa.',
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
                titulo: 'Tu despensa está vacía',
                descripcion:
                    'Agregá lo que tengas en casa y te avisamos antes '
                    'de que se venza.',
                textoAccion: 'Agregar producto',
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
                titulo: 'PRÓXIMOS A VENCER',
                color: paleta.critico,
                productos: urgentes,
                anchoAmplio: anchoAmplio,
              ),
            if (enBuenEstado.isNotEmpty)
              ..._seccion(
                context: context,
                ref: ref,
                icono: CupertinoIcons.cube_box_fill,
                titulo: 'EN BUEN ESTADO',
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
              Text('${productos.length}', style: AppTextStyles.rotulo(context)),
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
                            'Ver perfil y lista de compras',
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
                    'Despensa compartida',
                    style: TextStyle(
                      color: context.paleta.tinta,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    compartida == null
                        ? 'Crea una o únete con un código'
                        : compartida.nombre,
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
                'Consulta Rápida',
                style: TextStyle(
                  color: context.paleta.tinta,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Buscar productos de tu despensa',
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
            Divider(color: context.paleta.contorno),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: context.paleta.vencido,
              ),
              title: Text(
                'Cerrar sesión',
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
          color: context.paleta.marcaSuave,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.paleta.contorno),
        ),
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
                'Marcar como consumido',
                style: TextStyle(
                  color: context.paleta.tinta,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Suma a tus alimentos salvados',
                style: TextStyle(color: context.paleta.apagado, fontSize: 12),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(despensaProvider.notifier).consumir(producto.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡${producto.nombre} salvado! ✅'),
                      backgroundColor: context.paleta.marca,
                    ),
                  );
                  _preguntarListaCompras(
                    context,
                    ref,
                    producto,
                    fechaConsumido: DateTime.now(),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.delete,
                color: context.paleta.vencido,
              ),
              title: Text(
                'Eliminar',
                style: TextStyle(
                  color: context.paleta.vencido,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                'No suma a alimentos salvados',
                style: TextStyle(color: context.paleta.apagado, fontSize: 12),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(despensaProvider.notifier).eliminar(producto.id);
                if (context.mounted) {
                  _preguntarListaCompras(
                    context,
                    ref,
                    producto,
                    fechaVencido: producto.vencido
                        ? producto.fechaCaducidad
                        : null,
                  );
                }
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
              fontSize: 10,
              color: context.paleta.apagado,
            ),
          ),
        ],
      ),
    );

    return expandido ? Expanded(child: tarjeta) : tarjeta;
  }
}

const _mesesEs = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Formatea un entero como pesos colombianos: 47000 -> "$47.000".
String _formatearCop(int valor) {
  final digitos = valor.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digitos[i]);
  }
  return '\$$buffer';
}

/// Muestra "1,2 kg", "500 g", "3 unidades" segun la magnitud.
String _formatearCantidad(String categoria, double cantidad) {
  final base = precioDeCategoria(categoria).base;

  if (base == BaseMedida.unidad) {
    final entero = cantidad.round();
    return entero == 1 ? '1 unidad' : '$entero unidades';
  }

  if (cantidad < 1) {
    final chico = (cantidad * 1000).round();
    return base == BaseMedida.kilo ? '$chico g' : '$chico ml';
  }

  final texto = cantidad
      .toStringAsFixed(cantidad.truncateToDouble() == cantidad ? 0 : 1)
      .replaceAll('.', ',');
  return '$texto ${base.abreviatura}';
}

class _AhorroCard extends StatelessWidget {
  final int ahorro;
  final Map<String, double> conteo;

  const _AhorroCard({required this.ahorro, required this.conteo});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mes = _mesesEs[DateTime.now().month - 1];
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
                  'Ahorro estimado de $mes'.toUpperCase(),
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
            _formatearCop(ahorro),
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
                'Consume un producto antes de que venza para empezar a sumar',
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
                  .map((e) => '${e.key} ${_formatearCantidad(e.key, e.value)}')
                  .join('  ·  '),
              style: textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: context.paleta.apagado,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Estimado según precios promedio por categoría',
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

void _preguntarListaCompras(
  BuildContext context,
  WidgetRef ref,
  Producto producto, {
  DateTime? fechaConsumido,
  DateTime? fechaVencido,
}) {
  showDialog(
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
              '¿Añadir a lista de compras?',
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
        'Agregar ${producto.nombre} a tu lista para la próxima compra.',
        style: TextStyle(color: context.paleta.apagado, fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            'No, gracias',
            style: TextStyle(color: context.paleta.apagado),
          ),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            final item = ItemCompra(
              id: '${producto.id}_${DateTime.now().millisecondsSinceEpoch}',
              nombre: producto.nombre,
              emoji: producto.emoji,
              comprado: false,
              agregadoEn: DateTime.now(),
              fechaConsumido: fechaConsumido,
              fechaVencido: fechaVencido,
            );
            await ref.read(listaComprasProvider.notifier).agregar(item);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${producto.nombre} añadido a tu lista 🛒'),
                  backgroundColor: context.paleta.marcaClara,
                ),
              );
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: context.paleta.marcaClara,
          ),
          child: const Text('Añadir'),
        ),
      ],
    ),
  );
}

class _BotonPerfil extends StatelessWidget {
  const _BotonPerfil({required this.fotoUrl, required this.onTap});

  final String? fotoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;
    final mostrarFoto = fotoUrl != null && !Responsive.isTabletOrWeb(context);

    return Semantics(
      button: true,
      label: 'Abrir menú de cuenta',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: paleta.marcaSuave,
            backgroundImage: mostrarFoto
                ? CachedNetworkImageProvider(fotoUrl!)
                : null,
            child: mostrarFoto
                ? null
                : Icon(Icons.person, size: 20, color: paleta.marca),
          ),
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
          if (!Responsive.isTabletOrWeb(context)) const InterruptorTema(),
          _BotonPerfil(fotoUrl: fotoUrl, onTap: onPerfil),
        ],
      ],
    );

    final cifras = [
      _StatCard(
        icon: CupertinoIcons.archivebox,
        value: '$productos',
        label: 'Productos',
        color: paleta.tinta,
        bg: paleta.superficieSuave,
        expandido: !enColumna,
      ),
      _StatCard(
        icon: CupertinoIcons.check_mark_circled,
        value: '$salvados',
        label: 'Salvados',
        color: paleta.marca,
        bg: paleta.marcaSuave,
        expandido: !enColumna,
      ),
      _StatCard(
        icon: CupertinoIcons.clock,
        value: '$porVencer',
        label: 'Por vencer',
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
