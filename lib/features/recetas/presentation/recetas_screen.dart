import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import 'package:lastbite/features/recetas/data/datasources/recetas_remote_data_source.dart';
import 'package:lastbite/features/recetas/data/models/receta_busqueda_remote_model.dart';
import 'package:lastbite/features/recetas/data/models/receta_detalle_remote_model.dart';
//import 'package:lastbite/features/recetas/data/services/translation_service.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/receta.dart';
import 'widgets/receta_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/receta_cache_repository.dart';

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

  RecetaCacheRepository? _cacheRepo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cargaInicial) {
      _cargaInicial = true;
      ref.listenManual(despensaProvider, (_, next) {
        if (next.value != null && !_cargaInicial) return;
        if (next.value != null) _cargarRecetasDesdeApi();
      }, fireImmediately: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _busquedaDataSource = RecetasBusquedaRemoteDataSource();
    _detalleDataSource = RecetasDetalleRemoteDataSource();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _cacheRepo = RecetaCacheRepository(userId: user.uid);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  List<Receta> get _recetasFiltradas {
    //ordenamiento por porcentaje de match descendente
    final lista = [..._recetas]
      ..sort((a, b) => b.porcentajeMatch.compareTo(a.porcentajeMatch));

    if (_query.isEmpty || _busquedaPorProducto) return lista;
    return lista
        .where((r) => r.titulo.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

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
      if (!forzar && _cacheRepo != null) {
        final valido = await _cacheRepo!.cacheEsValido(urgentes);
        if (valido) {
          final recetasCache = await _cacheRepo!.cargarRecetas();
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
      );

      final recetas =
          RecetaBusquedaRemoteModel.fromApiRawList(
              raw,
            ).map((m) => m.toDomain()).toList()
            ..sort((a, b) => b.porcentajeMatch.compareTo(a.porcentajeMatch));

      // guarda en caché
      if (_cacheRepo != null && recetas.isNotEmpty) {
        await _cacheRepo!.guardarRecetas(
          recetas: recetas,
          ingredientesUrgentes: urgentes,
        );
      }

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

  Future<void> _buscarRecetasPorProducto(String query) async {
    setState(() {
      _cargandoRecetas = true;
      _errorCarga = null;
      _busquedaPorProducto = true;
    });

    try {
      final raw = await _busquedaDataSource.buscarRecetasPorDespensaRaw(
        productosDespensa: [query],
        number: 3,
        ignorePantry: false,
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
      final prevList = previous?.value;
      final nextList = next.value;
      if (prevList != null && nextList != null && prevList != nextList) {
        _cargarRecetasDesdeApi();
      }
    });
    final textTheme = Theme.of(context).textTheme;
    final productosDespensa = ref.read(despensaProvider).value ?? [];
    return SafeArea(
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
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Residuo Cero',
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 16),

                  //Buscador
                  TextField(
                    controller: _searchCtrl,
                    onChanged: _onQueryChanged,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre...',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted.withValues(alpha: 0.9),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.accent,
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
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedFire,
                          size: 24,
                          color: AppColors.danger,
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
                                  color: AppColors.danger,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _urgentesLabel(productosDespensa),
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'RECETAS SUGERIDAS',
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: AppColors.textMuted,
                    ),
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
                        color: AppColors.yellow.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.yellow.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.translate,
                            size: 14,
                            color: AppColors.textMain,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _avisoTraduccion!,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: AppColors.textMain,
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
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No se pudieron cargar recetas',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorCarga!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
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
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        const Text('🍽️', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty
                              ? 'No hay recetas sugeridas\npara tu despensa actual'
                              : 'No encontramos recetas\ncon "$_query"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final receta = _recetasFiltradas[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: RecetaCard(
                        receta: receta,
                        onTap: () => _abrirDetalle(receta),
                      ),
                    );
                  }, childCount: _recetasFiltradas.length),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _abrirDetalle(Receta receta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecetaDetalleSheet(
        receta: receta,
        detalleFuture: _cargarDetalleReceta(receta),
      ),
    );
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
