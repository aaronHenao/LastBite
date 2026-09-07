import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lastbite/core/widgets/estado_vacio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lastbite/core/responsive/responsive_container.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import 'package:lastbite/features/recetas/data/datasources/recetas_remote_data_source.dart';
import 'package:lastbite/features/recetas/data/models/receta_busqueda_remote_model.dart';
import 'package:lastbite/features/recetas/data/models/receta_detalle_remote_model.dart';
import 'package:lastbite/core/responsive/responsive.dart';
import '../../../core/constants/momento_comida.dart';
import '../../../core/constants/ritmo_cocina.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/orden_recetas.dart';
import '../domain/receta.dart';
import 'widgets/receta_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lastbite/features/compartida/presentation/compartida_provider.dart';
import '../data/receta_cache_repository.dart';
import 'package:lastbite/features/perfil/domain/perfil_nutricional.dart';
import 'package:lastbite/features/perfil/presentation/perfil_nutricional_provider.dart';

class RecetasScreen extends ConsumerStatefulWidget {
  const RecetasScreen({super.key});

  @override
  ConsumerState<RecetasScreen> createState() => _RecetasScreenState();
}

class _RecetasScreenState extends ConsumerState<RecetasScreen> {
  late final RecetasBusquedaRemoteDataSource _busquedaDataSource;
  late final RecetasDetalleRemoteDataSource _detalleDataSource;
  final _searchCtrl = TextEditingController();
  final Map<int, Receta> _detallesCache = {};
  Timer? _searchDebounce;

  List<Receta> _recetas = const [];
  bool _cargandoRecetas = true;
  String? _errorCarga;
  String? _avisoTraduccion;
  String _query = '';
  bool _cargaInicial = false;
  bool _busquedaPorProducto = false;
  bool _ordenarPorTiempo = false;
  bool _ritmoAutomatico = false;

  /// Se resuelve en cada carga porque la raiz cambia al entrar o salir de una
  /// despensa compartida. Espera el id en vez de leerlo del estado actual:
  /// si el provider todavia no resolvio, se escribiria el cache personal
  /// estando en una despensa compartida.
  Future<RecetaCacheRepository?> _resolverCache() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return RecetaCacheRepository(
      userId: user.uid,
      despensaCompartidaId: await ref.read(
        despensaCompartidaIdProvider.future,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _busquedaDataSource = RecetasBusquedaRemoteDataSource();
    _detalleDataSource = RecetasDetalleRemoteDataSource();

    // Entre semana la lista arranca ordenada por tiempo; el usuario puede
    // cambiarlo con el boton "Menor tiempo" y ahi deja de ser automatico.
    _ordenarPorTiempo = priorizarRecetasRapidas(DateTime.now());
    _ritmoAutomatico = true;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Widget _buildRecetasSliver(BuildContext context) {
    if (Responsive.isTabletOrWeb(context)) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final receta = _recetasFiltradas[index];
            return RecetaCard(
              key: ValueKey(receta.id),
              receta: receta,
              onTap: () => _abrirDetalle(receta),
            );
          }, childCount: _recetasFiltradas.length),
          // Alto fijo en vez de proporcion: la tarjeta mide lo mismo en
          // cualquier ancho de celda, y un childAspectRatio calculado a ojo
          // desbordaba en todo el rango de tablet.
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 420,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 268,
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final receta = _recetasFiltradas[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: RecetaCard(
            key: ValueKey(receta.id),
            receta: receta,
            onTap: () => _abrirDetalle(receta),
          ),
        );
      }, childCount: _recetasFiltradas.length),
    );
  }

  List<Receta> get _recetasFiltradas {
    final lista = [..._recetas]..sort(_compararRecetas);

    if (_query.isEmpty || _busquedaPorProducto) return lista;
    return lista
        .where((r) => r.titulo.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  int _compararRecetas(Receta a, Receta b) {
    return compararRecetas(
      a,
      b,
      ordenarPorTiempo: _ordenarPorTiempo,
      momento: momentoComidaDe(DateTime.now()),
    );
  }

  /// Texto bajo el titulo que explica por que la lista quedo en ese orden.
  ///
  /// El momento del dia manda sobre el orden siempre, incluso despues de que
  /// el usuario toca "Menor tiempo", asi que su explicacion tambien se
  /// muestra siempre. La del ritmo solo mientras el orden lo siga poniendo el
  /// dia de la semana.
  ///
  /// Lee la hora una sola vez: las dos explicaciones tienen que hablar del
  /// mismo instante.
  String _explicacionOrden() {
    final ahora = DateTime.now();
    final momento = explicacionMomento(momentoComidaDe(ahora));

    if (!_ritmoAutomatico) return momento;
    return '$momento. ${explicacionRitmo(ahora)}';
  }

  /// Icono que acompana a [_explicacionOrden].
  ///
  /// Calendario mientras el dia de la semana sigue decidiendo el orden; reloj
  /// cuando ya solo queda la hora, porque ahi el texto no habla de dias.
  IconData get _iconoOrden => _ritmoAutomatico
      ? Icons.event_available_outlined
      : Icons.schedule_outlined;

  String _urgentesLabel(List<Producto> productos) {
    if (productos.isEmpty) {
      return 'No hay productos en tu despensa';
    }

    final urgentes = [...productos]
      ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));

    final topUrgentes = urgentes.where((p) => p.urgente).take(5).toList();
    if (topUrgentes.isEmpty) {
      return 'No hay productos urgentes en tu despensa';
    }

    return topUrgentes
        .map((p) => '${p.nombre} (${p.diasRestantes}d)')
        .join(' · ');
  }

  Future<void> _cargarRecetasDesdeApi({bool forzar = false}) async {
    _searchDebounce?.cancel();
    setState(() {
      _cargandoRecetas = true;
      _errorCarga = null;
      _busquedaPorProducto = false;
    });

    try {
      final perfil = ref.read(perfilNutricionalProvider).valueOrNull;
      final productosDespensa = ref.read(despensaProvider).value ?? [];
      if (productosDespensa.isEmpty) {
        if (!mounted) return;
        setState(() {
          _recetas = const [];
          _cargandoRecetas = false;
          _errorCarga = null;
          _avisoTraduccion = null;
        });
        return;
      }

      //ingredientes actuales urg
      final urgentes = productosDespensa
          .where((p) => p.urgente)
          .map((p) => p.nombre.toLowerCase().trim())
          .toList();

      //intentar caché
      final cacheRepo = await _resolverCache();
      if (!forzar && cacheRepo != null) {
        final valido = await cacheRepo.cacheEsValido(
          ingredientesUrgentesActuales: urgentes,
          perfilKey: perfil?.cacheKey ?? '',
        );
        if (valido) {
          final recetasCache = await cacheRepo.cargarRecetas();
          if (recetasCache.isNotEmpty && mounted) {
            setState(() {
              _recetas = recetasCache
                ..sort(
                  (a, b) => b.porcentajeMatch.compareTo(a.porcentajeMatch),
                );
              _cargandoRecetas = false;
              _avisoTraduccion = null;
            });
            return;
          }
        }
      }

      //caché inválido o vacío - Llama a spoonacular
      final productosOrdenados = [...productosDespensa]
        ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));
      final nombres = productosOrdenados.map((p) => p.nombre).toList();

      final raw = await _busquedaDataSource.buscarRecetasPorDespensaRaw(
        productosDespensa: nombres,
        number: 3,
        ignorePantry: false,
        perfil: perfil,
      );

      final recetas =
          RecetaBusquedaRemoteModel.fromApiRawList(
              raw,
            ).map((m) => m.toDomain()).toList()
            ..sort((a, b) => b.porcentajeMatch.compareTo(a.porcentajeMatch));

      // guarda en caché
      if (cacheRepo != null && recetas.isNotEmpty) {
        await cacheRepo.guardarRecetas(
          recetas: recetas,
          ingredientesUrgentes: urgentes,
          perfilKey: perfil?.cacheKey ?? '',
        );
      }

      if (!mounted) return;
      setState(() {
        _recetas = recetas;
        _cargandoRecetas = false;
        _avisoTraduccion = _busquedaDataSource.lastTranslationWarning;
      });
    } catch (e) {
      // Si Spoonacular falla (sin cuota, sin red) mostramos lo ultimo que
      // haya quedado guardado, aunque sea de una version anterior del cache.
      // Puede venir sin dishTypes o sin tiempo: esos criterios simplemente
      // no opinan sobre esas recetas. Es mejor que dejar la pantalla vacia.
      var respaldo = const <Receta>[];
      try {
        final cacheRepo = await _resolverCache();
        if (cacheRepo != null) respaldo = await cacheRepo.cargarRecetas();
      } catch (_) {
        // Sin respaldo utilizable: se muestra el error original.
      }

      if (!mounted) return;
      setState(() {
        _recetas = respaldo;
        _errorCarga = respaldo.isEmpty ? e.toString() : null;
        _cargandoRecetas = false;
        _avisoTraduccion = _busquedaDataSource.lastTranslationWarning;
      });
    }
  }

  Future<void> _buscarRecetasPorProducto(String query) async {
    setState(() {
      _cargandoRecetas = true;
      _errorCarga = null;
      _busquedaPorProducto = true;
    });

    try {
      final perfil = ref.read(perfilNutricionalProvider).valueOrNull;
      final raw = await _busquedaDataSource.buscarRecetasPorDespensaRaw(
        productosDespensa: [query],
        number: 3,
        ignorePantry: false,
        perfil: perfil,
      );

      final recetas =
          RecetaBusquedaRemoteModel.fromApiRawList(
              raw,
            ).map((m) => m.toDomain()).toList()
            ..sort((a, b) => b.porcentajeMatch.compareTo(a.porcentajeMatch));

      if (!mounted) return;
      setState(() {
        _recetas = recetas;
        _cargandoRecetas = false;
        _avisoTraduccion = _busquedaDataSource.lastTranslationWarning;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCarga = e.toString();
        _cargandoRecetas = false;
        _avisoTraduccion = _busquedaDataSource.lastTranslationWarning;
      });
    }
  }

  void _onQueryChanged(String value) {
    final trimmed = value.trim();
    setState(() {
      _query = value;
      _busquedaPorProducto = trimmed.isNotEmpty;
    });

    _searchDebounce?.cancel();

    if (trimmed.isEmpty) {
      _cargarRecetasDesdeApi();
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _buscarRecetasPorProducto(trimmed),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Producto>>>(despensaProvider, (previous, next) {
      final nextList = next.value;
      if (nextList == null) return;

      // Primera carga: el stream de la despensa acaba de resolver.
      if (!_cargaInicial) {
        _cargaInicial = true;
        _cargarRecetasDesdeApi();
        return;
      }

      // Despues, solo un cambio real de contenido. Spoonacular se paga por
      // llamada y el stream re-emite con cada snapshot de Firestore.
      final prevList = previous?.value;
      if (prevList != null && !listEquals(prevList, nextList)) {
        _cargarRecetasDesdeApi();
      }
    });
    ref.listen<AsyncValue<PerfilNutricional?>>(perfilNutricionalProvider, (
      previous,
      next,
    ) {
      if (previous?.value != next.value && next.hasValue) {
        _cargarRecetasDesdeApi(forzar: true);
      }
    });
    final textTheme = Theme.of(context).textTheme;
    final productosDespensa = ref.read(despensaProvider).value ?? [];
    return SafeArea(
      child: ResponsiveContainer(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MOTOR DE RECETAS',
                      style: textTheme.titleSmall?.copyWith(
                        letterSpacing: 2.4,
                        color: context.paleta.apagado,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Residuo Cero',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.paleta.tinta,
                      ),
                    ),
                    const SizedBox(height: 16),

                    //Buscador
                    TextField(
                      controller: _searchCtrl,
                      onChanged: _onQueryChanged,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.paleta.apagado,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre...',
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.paleta.apagado.withValues(alpha: 0.9),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: context.paleta.apagado,
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: context.paleta.apagado,
                                ),
                                onPressed: () {
                                  _searchDebounce?.cancel();
                                  _searchCtrl.clear();
                                  setState(() {
                                    _query = '';
                                    _busquedaPorProducto = false;
                                  });
                                  _cargarRecetasDesdeApi();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: context.paleta.marcaSuave,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: context.paleta.contorno),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: context.paleta.contorno),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: context.paleta.marca,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Prioridad ingredientes urgentes
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: context.paleta.vencido.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            HugeIcons.strokeRoundedFire,
                            size: 24,
                            color: context.paleta.vencido,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Priorizando ingredientes urgentes',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                    color: context.paleta.vencido,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _urgentesLabel(productosDespensa),
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: context.paleta.apagado,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'RECETAS SUGERIDAS',
                            style: textTheme.titleSmall?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: context.paleta.apagado,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _OrdenPorTiempoBoton(
                          activo: _ordenarPorTiempo,
                          onTap: () => setState(() {
                            _ordenarPorTiempo = !_ordenarPorTiempo;
                            // Al elegir a mano deja de mandar el dia.
                            _ritmoAutomatico = false;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          _iconoOrden,
                          size: 13,
                          color: context.paleta.apagado,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _explicacionOrden(),
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: context.paleta.apagado,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_avisoTraduccion != null) ...[
                      const SizedBox(height: 8),
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
                            color: context.paleta.urgente.withValues(alpha: 0.4),
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
                                _avisoTraduccion!,
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
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            //Lista de recetas
            _cargandoRecetas
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: context.paleta.marca,
                        ),
                      ),
                    ),
                  )
                : _errorCarga != null
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.paleta.marcaSuave,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.paleta.contorno),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No se pudieron cargar recetas',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.paleta.tinta,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorCarga!,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.paleta.apagado,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () =>
                                  _cargarRecetasDesdeApi(forzar: true),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : _recetasFiltradas.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      // El vacio dice que hacer, y la salida depende de por que
                      // esta vacio: sin productos hay que agregar; con busqueda
                      // sin resultados, hay que limpiarla.
                      child: _query.isNotEmpty
                          ? EstadoVacio(
                              icono: Icons.search_off_rounded,
                              titulo: 'Sin resultados',
                              descripcion:
                                  'Ninguna receta coincide con "$_query".',
                              textoAccion: 'Limpiar búsqueda',
                              onAccion: () {
                                _searchDebounce?.cancel();
                                _searchCtrl.clear();
                                setState(() {
                                  _query = '';
                                  _busquedaPorProducto = false;
                                });
                                _cargarRecetasDesdeApi();
                              },
                            )
                          : EstadoVacio(
                              icono: Icons.restaurant_menu_rounded,
                              titulo: 'Todavía no hay sugerencias',
                              descripcion:
                                  'Agregá productos a tu despensa y te '
                                  'proponemos recetas que los aprovechen.',
                              textoAccion: 'Buscar de nuevo',
                              onAccion: () =>
                                  _cargarRecetasDesdeApi(forzar: true),
                            ),
                    ),
                  )
                : _buildRecetasSliver(context),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  /// Marca la receta como cocinada. Consumir es lo que suma a "alimentos
  /// salvados", asi que el usuario elige que productos se terminaron de verdad:
  /// una receta usa parte de un producto, no siempre el producto entero.
  Future<void> _cocinar(Receta receta) async {
    final messenger = ScaffoldMessenger.of(context);
    final colorExito = context.paleta.marca;
    final ingredientes = (receta.ingredientes ?? [])
        .map((i) => i.toLowerCase())
        .toList();

    final usados =
        (ref.read(despensaProvider).value ?? []).where((producto) {
          final nombre = producto.nombre.toLowerCase().trim();
          return nombre.isNotEmpty &&
              ingredientes.any((ing) => ing.contains(nombre));
        }).toList()
          ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));

    if (usados.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Ninguno de tus productos coincide con esta receta.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    final elegidos = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _DialogoCocinar(productos: usados),
    );
    if (elegidos == null || elegidos.isEmpty) return;

    final notifier = ref.read(despensaProvider.notifier);
    for (final id in elegidos) {
      await notifier.consumir(id);
    }

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: colorExito,
        content: Text(
          elegidos.length == 1
              ? '1 producto salvado. ¡Buen provecho!'
              : '${elegidos.length} productos salvados. ¡Buen provecho!',
        ),
      ),
    );
  }

  Set<String> _nombresDespensa() => (ref.read(despensaProvider).value ?? [])
      .map((p) => p.nombre.toLowerCase().trim())
      .where((nombre) => nombre.isNotEmpty)
      .toSet();

  void _abrirDetalle(Receta receta) {
    final isWeb = Responsive.isTabletOrWeb(context);

    if (isWeb) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 80,
            vertical: 40,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: 600,
              child: RecetaDetalleSheet(
                receta: receta,
                detalleFuture: _cargarDetalleReceta(receta),
                productosEnDespensa: _nombresDespensa(),
                onCocinar: _cocinar,
                isDialog: true,
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => RecetaDetalleSheet(
          receta: receta,
          detalleFuture: _cargarDetalleReceta(receta),
          productosEnDespensa: _nombresDespensa(),
          onCocinar: _cocinar,
        ),
      );
    }
  }

  Future<Receta> _cargarDetalleReceta(Receta receta) async {
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

    final sinTags = texto.replaceAll(RegExp(r'<[^>]*>'), ' ');
    return sinTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _OrdenPorTiempoBoton extends StatelessWidget {
  final bool activo;
  final VoidCallback onTap;

  const _OrdenPorTiempoBoton({required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = activo ? context.paleta.marca : context.paleta.apagado;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: activo
              ? context.paleta.marca.withValues(alpha: 0.12)
              : context.paleta.marcaSuave,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              'Menor tiempo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogoCocinar extends StatefulWidget {
  const _DialogoCocinar({required this.productos});

  final List<Producto> productos;

  @override
  State<_DialogoCocinar> createState() => _DialogoCocinarState();
}

class _DialogoCocinarState extends State<_DialogoCocinar> {
  late final Set<String> _elegidos = widget.productos
      .map((p) => p.id)
      .toSet();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.paleta.marcaSuave,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '¿Qué usaste por completo?',
        style: TextStyle(
          color: context.paleta.tinta,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lo que marques sale de tu despensa y suma a tus alimentos '
              'salvados. Destildá lo que todavía te quede.',
              style: TextStyle(color: context.paleta.apagado, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final producto in widget.productos)
                      CheckboxListTile(
                        value: _elegidos.contains(producto.id),
                        onChanged: (marcado) => setState(() {
                          if (marcado == true) {
                            _elegidos.add(producto.id);
                          } else {
                            _elegidos.remove(producto.id);
                          }
                        }),
                        activeColor: context.paleta.marca,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          '${producto.emoji}  ${producto.nombre}',
                          style: TextStyle(
                            color: context.paleta.tinta,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          AppTheme.diasLabel(producto.diasRestantes),
                          style: TextStyle(
                            color: context.paleta.apagado,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          onPressed: _elegidos.isEmpty
              ? null
              : () => Navigator.pop(context, _elegidos),
          style: FilledButton.styleFrom(backgroundColor: context.paleta.marca),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
