import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lastbite/core/utils/texto.dart';
import 'package:lastbite/core/widgets/aviso_deshacer.dart';
import 'package:lastbite/core/widgets/boton_ayuda.dart';
import 'package:lastbite/core/widgets/estado_vacio.dart';
import 'package:lastbite/core/widgets/pastilla_estado.dart';
import 'package:lastbite/features/ayuda/presentation/ayuda_screen.dart';
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
import 'package:lastbite/l10n/traducciones.dart';
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

  List<Receta> _recetas = const [];
  bool _cargandoRecetas = true;
  /// Lo que fallo. El mensaje se arma al dibujar, en el idioma activo.
  Object? _errorCarga;

  /// Idioma en el que se pidieron las recetas que se ven.
  String? _idioma;
  String? _avisoTraduccion;
  String _query = '';
  bool _cargaInicial = false;
  bool _busquedaPorProducto = false;
  bool _ordenarPorTiempo = false;
  bool _ritmoAutomatico = false;

  /// Sube con cada carga o busqueda. La IA tarda segundos y las respuestas
  /// pueden llegar en otro orden: solo se pinta la de la ultima solicitud.
  int _solicitud = 0;

  /// Ya se ve al menos una receta pero la IA sigue enviando las demas.
  bool _generandoMas = false;

  /// La despensa cambio desde que se generaron las recetas que se ven.
  bool _despensaCambio = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recetas en el idioma elegido: al cambiarlo, la IA genera otras. La
    // cache se separa por idioma, asi que volver a uno anterior no paga de
    // nuevo.
    final idioma = context.t.localeName;
    final anterior = _idioma;
    _idioma = idioma;
    if (anterior != null && anterior != idioma && _cargaInicial) {
      _cargarRecetasDesdeApi();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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
    return lista.where((r) => coincideBusqueda(r.titulo, _query)).toList();
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
    final t = context.t;
    final momento = explicacionMomento(t, momentoComidaDe(ahora));

    if (!_ritmoAutomatico) return momento;
    return '$momento. ${explicacionRitmo(t, ahora)}';
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
      return context.t.recetasSinProductos;
    }

    final urgentes = [...productos]
      ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));

    final topUrgentes = urgentes.where((p) => p.urgente).take(5).toList();
    if (topUrgentes.isEmpty) {
      return context.t.recetasSinUrgentes;
    }

    return topUrgentes
        .map((p) => '${p.nombre} (${etiquetaDias(context, p.diasRestantes)})')
        .join(' · ');
  }

  /// Pide recetas a la IA y las va mostrando a medida que llegan (streaming):
  /// la primera aparece en 3-9 s en vez de esperar las tres. Devuelve la
  /// lista final. Si la IA falla despues de mandar alguna receta, se quedan
  /// las que llegaron.
  Future<List<Receta>> _recetasConIa({
    required int solicitud,
    required List<String> despensa,
    required PerfilNutricional? perfil,
    String? principal,
  }) async {
    var recetas = const <Receta>[];
    try {
      await for (final raw in _busquedaDataSource
          .buscarRecetasPorDespensaStream(
            productosDespensa: despensa,
            number: 3,
            perfil: perfil,
            ingredientePrincipal: principal,
            idioma: context.t.localeName,
          )) {
        recetas = RecetaBusquedaRemoteModel.fromApiRawList(
          raw,
        ).map((m) => m.toDomain()).toList();
        // Otra carga o busqueda la reemplazo: el servicio igual la guarda.
        if (!mounted || solicitud != _solicitud) break;
        setState(() {
          _recetas = recetas;
          _cargandoRecetas = false;
          _generandoMas = true;
        });
      }
    } catch (_) {
      if (recetas.isEmpty) rethrow;
    } finally {
      if (mounted && solicitud == _solicitud) {
        setState(() => _generandoMas = false);
      }
    }
    return recetas;
  }

  Future<void> _cargarRecetasDesdeApi({bool forzar = false}) async {
    final solicitud = ++_solicitud;
    setState(() {
      _cargandoRecetas = true;
      _generandoMas = false;
      _errorCarga = null;
      _busquedaPorProducto = false;
      _despensaCambio = false;
    });

    try {
      final perfil = ref.read(perfilNutricionalProvider).valueOrNull;
      final productosDespensa = ref.read(despensaProvider).value ?? [];
      if (productosDespensa.isEmpty) {
        if (!mounted || solicitud != _solicitud) return;
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
          perfilKey: _claveCache(perfil),
        );
        if (valido) {
          final recetasCache = await cacheRepo.cargarRecetas();
          if (!mounted || solicitud != _solicitud) return;
          if (recetasCache.isNotEmpty) {
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

      //caché inválido o vacío: la IA genera recetas nuevas
      final productosOrdenados = [...productosDespensa]
        ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));
      final nombres = productosOrdenados.map((p) => p.nombre).toList();

      final recetas = await _recetasConIa(
        solicitud: solicitud,
        despensa: nombres,
        perfil: perfil,
      );

      // guarda en caché
      if (cacheRepo != null && recetas.isNotEmpty) {
        await cacheRepo.guardarRecetas(
          recetas: recetas,
          ingredientesUrgentes: urgentes,
          perfilKey: _claveCache(perfil),
        );
      }

      if (!mounted || solicitud != _solicitud) return;
      setState(() {
        _recetas = recetas;
        _cargandoRecetas = false;
        _avisoTraduccion = _busquedaDataSource.lastTranslationWarning;
      });
    } catch (e) {
      // Si la IA falla (sin creditos, sin red) mostramos lo ultimo que haya
      // quedado guardado, aunque sea de una version anterior del cache. Solo
      // sirven las recetas completas: las de Spoonacular no tienen detalle.
      var respaldo = const <Receta>[];
      try {
        final cacheRepo = await _resolverCache();
        if (cacheRepo != null) {
          respaldo = (await cacheRepo.cargarRecetas())
              .where((r) => (r.instrucciones ?? '').trim().isNotEmpty)
              .toList();
        }
      } catch (_) {
        // Sin respaldo utilizable: se muestra el error original.
      }

      if (!mounted || solicitud != _solicitud) return;
      setState(() {
        _recetas = respaldo;
        _errorCarga = respaldo.isEmpty ? e : null;
        _cargandoRecetas = false;
        _avisoTraduccion = _busquedaDataSource.lastTranslationWarning;
      });
    }
  }

  Future<void> _buscarRecetasPorProducto(String query) async {
    final solicitud = ++_solicitud;
    setState(() {
      _cargandoRecetas = true;
      _generandoMas = false;
      _errorCarga = null;
      _busquedaPorProducto = true;
      _despensaCambio = false;
    });

    try {
      final perfil = ref.read(perfilNutricionalProvider).valueOrNull;
      // La despensa va como contexto: asi las recetas de lo buscado
      // aprovechan lo que ya hay y el match se calcula de verdad.
      final despensa = [...ref.read(despensaProvider).value ?? <Producto>[]]
        ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));
      final recetas = await _recetasConIa(
        solicitud: solicitud,
        despensa: despensa.map((p) => p.nombre).toList(),
        perfil: perfil,
        principal: query,
      );

      if (!mounted || solicitud != _solicitud) return;
      setState(() {
        _recetas = recetas;
        _cargandoRecetas = false;
        _avisoTraduccion = _busquedaDataSource.lastTranslationWarning;
      });
    } catch (e) {
      if (!mounted || solicitud != _solicitud) return;
      setState(() {
        _errorCarga = e;
        _cargandoRecetas = false;
        _avisoTraduccion = _busquedaDataSource.lastTranslationWarning;
      });
    }
  }

  /// Mientras se escribe solo se filtran por titulo las recetas que ya hay.
  /// Antes cada pausa al escribir lanzaba una consulta a la IA: escribir
  /// "pollo" disparaba dos o tres de ~10 s que competian entre si (~30 s).
  void _onQueryChanged(String value) {
    setState(() => _query = value);

    if (value.trim().isEmpty && _busquedaPorProducto) {
      _cargarRecetasDesdeApi();
    }
  }

  /// La IA se consulta al confirmar la busqueda (boton del teclado o Enter).
  void _onBuscar(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _buscarRecetasPorProducto(trimmed);
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

      // Despues, solo un cambio real de contenido. La IA se paga por llamada
      // y el stream re-emite con cada snapshot de Firestore.
      final prevList = previous?.value;
      if (prevList == null || listEquals(prevList, nextList)) return;

      // Lo que se esta mirando no cambia solo: la evaluacion encontro que la
      // receta que alguien queria conservar desaparecia al tocar la
      // despensa. Se avisa y la persona decide; solo se recarga sola si no
      // habia nada que perder.
      if (_recetas.isEmpty) {
        _cargarRecetasDesdeApi();
      } else {
        setState(() => _despensaCambio = true);
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t.recetasRotulo,
                                style: textTheme.titleSmall?.copyWith(
                                  letterSpacing: 2.4,
                                  color: context.paleta.apagado,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.t.recetasTitulo,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: context.paleta.tinta,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const BotonAyuda(seccion: SeccionAyuda.recetas),
                      ],
                    ),
                    const SizedBox(height: 16),

                    //Buscador
                    TextField(
                      controller: _searchCtrl,
                      onChanged: _onQueryChanged,
                      onSubmitted: _onBuscar,
                      textInputAction: TextInputAction.search,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.paleta.apagado,
                      ),
                      decoration: InputDecoration(
                        hintText: context.t.recetasBuscar,
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
                                  context.t.recetasPriorizando,
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
                            context.t.recetasSugeridas,
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
                    if (_despensaCambio && !_cargandoRecetas) ...[
                      const SizedBox(height: 8),
                      _AvisoDespensaCambio(
                        onActualizar: () => _cargarRecetasDesdeApi(forzar: true),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            //Lista de recetas
            _cargandoRecetas
                // La IA tarda varios segundos: un spinner solo no dice si la
                // app sigue trabajando ni cuanto falta.
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                      child: Semantics(
                        liveRegion: true,
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: context.paleta.marca,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              context.t.recetasBuscando,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: context.paleta.apagado,
                              ),
                            ),
                          ],
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
                              context.t.recetasErrorCarga,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.paleta.tinta,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _mensajeError(_errorCarga!),
                              style: TextStyle(
                                fontSize: 12,
                                color: context.paleta.apagado,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () =>
                                  _cargarRecetasDesdeApi(forzar: true),
                              child: Text(context.t.accionReintentar),
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
                              titulo: context.t.recetasSinResultados,
                              descripcion: context.t
                                  .recetasSinResultadosDescripcion(_query),
                              textoAccion: context.t.accionLimpiarBusqueda,
                              onAccion: () {
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
                              titulo: context.t.recetasSinSugerenciasTitulo,
                              descripcion:
                                  context.t.recetasSinSugerenciasDescripcion,
                              textoAccion: context.t.recetasBuscarDeNuevo,
                              onAccion: () =>
                                  _cargarRecetasDesdeApi(forzar: true),
                            ),
                    ),
                  )
                : _buildRecetasSliver(context),

            if (_generandoMas && !_cargandoRecetas && _errorCarga == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Semantics(
                    liveRegion: true,
                    child: Row(
                      children: [
                        SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.paleta.marca,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            context.t.recetasGenerando,
                            style: textTheme.bodySmall?.copyWith(
                              color: context.paleta.apagado,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

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
    final t = context.t;
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
        SnackBar(
          content: Text(context.t.recetasSinCoincidencias),
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
    final consumidos = usados.where((p) => elegidos.contains(p.id)).toList();
    for (final producto in consumidos) {
      await notifier.consumir(producto.id);
    }

    if (!mounted) return;
    mostrarAvisoDeshacer(
      context,
      mensaje: t.recetasSalvados(consumidos.length),
      onDeshacer: () async {
        for (final producto in consumidos) {
          await notifier.deshacerConsumo(producto);
        }
      },
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
    // Las recetas de IA llegan completas desde la busqueda o la cache.
    if ((receta.instrucciones ?? '').trim().isNotEmpty) return receta;

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

    // Conserva los saltos de linea: las instrucciones de IA van un paso por
    // linea.
    final sinTags = texto.replaceAll(RegExp(r'<[^>]*>'), ' ');
    return sinTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\s*\n\s*'), '\n')
        .trim();
  }

  /// La cache se separa por idioma: cambiarlo trae recetas nuevas en ese
  /// idioma en vez de las guardadas en otro.
  String _claveCache(PerfilNutricional? perfil) =>
      '${perfil?.cacheKey ?? ''}|${context.t.localeName}';

  String _mensajeError(Object error) {
    final t = context.t;
    if (error is! RecetasRemoteException) return t.recetasErrorDesconocido;
    return switch (error.motivo) {
      ErrorRecetas.faltaClave => t.recetasErrorFaltaClave,
      ErrorRecetas.respuestaVacia => t.recetasErrorRespuestaVacia,
      ErrorRecetas.tiempoAgotado => t.recetasErrorTiempo,
      ErrorRecetas.sinConexion => t.recetasErrorSinConexion,
      ErrorRecetas.claveInvalida => t.recetasErrorClave,
      ErrorRecetas.sinCreditos => t.recetasErrorCreditos,
      ErrorRecetas.modeloInexistente => t.recetasErrorModeloInexistente,
      ErrorRecetas.modeloRetirado => t.recetasErrorModeloRetirado,
      ErrorRecetas.demasiadasConsultas => t.recetasErrorDemasiadas,
      ErrorRecetas.servicioCaido => t.recetasErrorServicio,
      ErrorRecetas.sinRecetasValidas => t.recetasErrorSinRecetas,
      ErrorRecetas.formatoInesperado => t.recetasErrorFormato,
      ErrorRecetas.respuestaIncompleta => t.recetasErrorIncompleta,
      ErrorRecetas.detalleNoDisponible => t.recetasErrorDetalle,
      ErrorRecetas.sinIngredientes => t.recetasErrorSinIngredientes,
      ErrorRecetas.desconocido => t.recetasErrorDesconocido,
    };
  }
}

/// Las recetas que se ven son de una despensa que ya cambio. No se cambian
/// solas: la persona decide cuando actualizarlas.
class _AvisoDespensaCambio extends StatelessWidget {
  const _AvisoDespensaCambio({required this.onActualizar});

  final VoidCallback onActualizar;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: paleta.marcaSuave,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: paleta.marca.withValues(alpha: 0.4)),
      ),
      child: Semantics(
        liveRegion: true,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: paleta.marca),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      context.t.recetasDespensaCambio,
                      style: textTheme.bodySmall?.copyWith(color: paleta.tinta),
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onActualizar,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.t.recetasActualizar),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdenPorTiempoBoton extends StatelessWidget {
  final bool activo;
  final VoidCallback onTap;

  const _OrdenPorTiempoBoton({required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = activo ? context.paleta.marca : context.paleta.apagado;

    return Semantics(
      button: true,
      selected: activo,
      label: context.t.recetasOrdenarMenorTiempo,
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: AnimatedContainer(
        duration: AppMotion.duracion(context, AppMotion.pulsa),
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
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
              context.t.recetasMenorTiempo,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
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
        context.t.recetasCocinarTitulo,
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
              context.t.recetasCocinarDescripcion,
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
                          etiquetaDias(context, producto.diasRestantes),
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
            context.t.accionCancelar,
            style: TextStyle(color: context.paleta.apagado),
          ),
        ),
        FilledButton(
          onPressed: _elegidos.isEmpty
              ? null
              : () => Navigator.pop(context, _elegidos),
          style: FilledButton.styleFrom(backgroundColor: context.paleta.marca),
          child: Text(context.t.recetasConfirmar),
        ),
      ],
    );
  }
}
