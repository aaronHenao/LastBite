import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/perfil/domain/perfil_nutricional.dart';
import 'package:lastbite/features/perfil/presentation/perfil_nutricional_provider.dart';
import 'package:lastbite/features/recetas/data/datasources/recetas_busqueda_remote_data_source.dart';
import 'package:lastbite/features/recetas/data/models/receta_busqueda_remote_model.dart';
import 'package:lastbite/features/recetas/data/receta_cache_repository.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';
import 'package:lastbite/features/compartida/presentation/compartida_provider.dart';
import '../data/alertas_repository.dart';
import '../domain/alerta.dart';

class AlertasNotifier extends AsyncNotifier<List<Alerta>> {
  late AlertasRepository _repo;
  late RecetasBusquedaRemoteDataSource _busquedaDataSource;

  /// Sube con cada carga. Las recetas se completan en segundo plano, y si
  /// mientras tanto hubo otra carga, ese resultado ya no aplica al state.
  int _generacion = 0;

  // Ya no hay traduccion; se mantiene porque AlertasScreen lo lee.
  String? get avisoTraduccion => null;

  @override
  Future<List<Alerta>> build() async {
    // Reconstruye al entrar o salir de una despensa compartida.
    ref.watch(despensaCompartidaIdProvider);
    return _cargarAlertas();
  }

  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = AsyncData(await _cargarAlertas());
  }

  Future<void> borrarTodas() async {
    final user = await ref.read(firebaseUserProvider.future);
    if (user == null) {
      state = const AsyncData([]);
      return;
    }

    _repo = AlertasRepository(
      userId: user.uid,
      despensaCompartidaId: await ref.read(despensaCompartidaIdProvider.future),
    );
    await _repo.borrarTodasAlertas(DateTime.now());
    state = const AsyncData([]);
  }

  Future<void> eliminar(String id) async {
    final user = await ref.read(firebaseUserProvider.future);
    if (user == null) return;

    _repo = AlertasRepository(
      userId: user.uid,
      despensaCompartidaId: await ref.read(despensaCompartidaIdProvider.future),
    );
    await _repo.marcarAlertaBorrada(id, DateTime.now());
    state = AsyncData((state.value ?? []).where((a) => a.id != id).toList());
  }

  Future<List<Alerta>> _cargarAlertas() async {
    final user = await ref.read(firebaseUserProvider.future);
    if (user == null) return [];

    final compartidaId = await ref.read(despensaCompartidaIdProvider.future);
    final repo = AlertasRepository(
      userId: user.uid,
      despensaCompartidaId: compartidaId,
    );
    _repo = repo;
    _busquedaDataSource = RecetasBusquedaRemoteDataSource();

    final resultados = await Future.wait([
      repo.cargarProductos(),
      repo.cargarAlertas(),
      repo.cargarUltimoBorrado(),
    ]);

    final productos = resultados[0] as List<Producto>;
    final alertasExistentes = List<Alerta>.from(resultados[1] as List<Alerta>);
    final lastClearAt = resultados[2] as DateTime?;

    final nuevas = _generarAlertas(
      productos: productos,
      alertasExistentes: alertasExistentes,
      lastClearAt: lastClearAt,
    );

    if (nuevas.isNotEmpty) {
      await repo.guardarAlertas(nuevas);
      alertasExistentes.addAll(nuevas);
    }

    final visibles = alertasExistentes
        .where((alerta) => !alerta.estaOculta)
        .toList();
    // Primero lo mas urgente; a igual urgencia, lo mas reciente. Antes se
    // ordenaba solo por creadaEn, asi que un producto ya vencido quedaba
    // debajo de un primer aviso de hoy.
    visibles.sort((a, b) {
      final porUrgencia = b.prioridad.compareTo(a.prioridad);
      if (porUrgencia != 0) return porUrgencia;
      return b.creadaEn.compareTo(a.creadaEn);
    });

    // Generar una receta con IA tarda segundos: las alertas se muestran ya y
    // la receta aparece en su tarjeta cuando llega.
    final generacion = ++_generacion;
    final pendientes = visibles.where(_necesitaReceta).toList();
    if (pendientes.isNotEmpty) {
      unawaited(
        _completarRecetas(
          pendientes: pendientes,
          productos: productos,
          repo: repo,
          cache: RecetaCacheRepository(
            userId: user.uid,
            despensaCompartidaId: compartidaId,
          ),
          generacion: generacion,
        ),
      );
    }

    return visibles;
  }

  List<Alerta> _generarAlertas({
    required List<Producto> productos,
    required List<Alerta> alertasExistentes,
    required DateTime? lastClearAt,
  }) {
    final existentesIds = alertasExistentes.map((a) => a.id).toSet();
    final nuevas = <Alerta>[];

    void agregar(Producto producto, AlertaTipo tipo, int umbralDias) {
      final alerta = _crearAlerta(
        producto: producto,
        tipo: tipo,
        existentesIds: existentesIds,
        lastClearAt: lastClearAt,
        umbralDias: umbralDias,
      );
      if (alerta != null) nuevas.add(alerta);
    }

    for (final producto in productos) {
      if (producto.diasRestantes < 0) {
        agregar(producto, AlertaTipo.vencido, 0);
        continue;
      }
      if (producto.diasRestantes <= 5) agregar(producto, AlertaTipo.aviso5, 5);
      if (producto.diasRestantes <= 3) agregar(producto, AlertaTipo.aviso3, 3);
      if (producto.diasRestantes <= 1) agregar(producto, AlertaTipo.aviso1, 1);
    }

    return nuevas;
  }

  Alerta? _crearAlerta({
    required Producto producto,
    required AlertaTipo tipo,
    required Set<String> existentesIds,
    required DateTime? lastClearAt,
    required int umbralDias,
  }) {
    final alertaId = Alerta.buildId(productoId: producto.id, tipo: tipo);
    if (existentesIds.contains(alertaId)) return null;

    final fechaDisparo = producto.fechaCaducidad.subtract(
      Duration(days: umbralDias),
    );

    if (lastClearAt != null && !fechaDisparo.isAfter(lastClearAt)) {
      return null;
    }

    return Alerta(
      id: alertaId,
      productoId: producto.id,
      nombreProducto: producto.nombre,
      emoji: producto.emoji,
      fechaCaducidad: producto.fechaCaducidad,
      tipo: tipo,
      creadaEn: DateTime.now(),
    );
  }

  /// Solo los avisos de 3 y 1 dia llevan receta. Una receta sin instrucciones
  /// viene de Spoonacular: su detalle ya no se puede pedir, asi que se
  /// reemplaza por una generada.
  bool _necesitaReceta(Alerta alerta) {
    if (alerta.estaOculta) return false;
    if (alerta.tipo != AlertaTipo.aviso3 && alerta.tipo != AlertaTipo.aviso1) {
      return false;
    }
    final instrucciones = alerta.recetaSugerida?.instrucciones ?? '';
    return instrucciones.trim().isEmpty;
  }

  Future<void> _completarRecetas({
    required List<Alerta> pendientes,
    required List<Producto> productos,
    required AlertasRepository repo,
    required RecetaCacheRepository cache,
    required int generacion,
  }) async {
    final productosMap = {for (final p in productos) p.id: p};
    final despensa =
        (productos.where((p) => !p.vencido).toList()
              ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes)))
            .map((p) => p.nombre)
            .where((nombre) => nombre.trim().isNotEmpty)
            .toList();

    PerfilNutricional? perfil;
    try {
      perfil = await ref.read(perfilNutricionalProvider.future);
    } catch (_) {
      // Sin perfil se generan recetas sin filtros.
    }

    // Las recetas que ya genero la pestaña Recetas son gratis: se prueban
    // antes de gastar un credito de IA.
    var enCache = const <Receta>[];
    try {
      enCache = (await cache.cargarRecetas())
          .where((r) => (r.instrucciones ?? '').trim().isNotEmpty)
          .toList();
    } catch (_) {}

    // aviso3 y aviso1 del mismo producto comparten receta: una sola llamada.
    final porProducto = <String, Future<Receta?>>{};
    for (final alerta in pendientes) {
      final producto = productosMap[alerta.productoId];
      if (producto == null) continue;
      porProducto.putIfAbsent(
        producto.id,
        () => _recetaPara(
          producto: producto,
          despensa: despensa,
          enCache: enCache,
          perfil: perfil,
        ),
      );
    }
    if (porProducto.isEmpty) return;

    final ids = porProducto.keys.toList();
    final recetas = await Future.wait(porProducto.values);
    final recetaDe = {
      for (var i = 0; i < ids.length; i++)
        if (recetas[i] != null) ids[i]: recetas[i]!,
    };

    final actualizaciones = [
      for (final alerta in pendientes)
        if (recetaDe[alerta.productoId] case final receta?)
          _conReceta(alerta, receta),
    ];
    if (actualizaciones.isEmpty) return;

    try {
      await repo.guardarAlertas(actualizaciones);
    } catch (_) {
      // Se muestra igual; la proxima carga lo intenta de nuevo.
    }

    if (generacion != _generacion) return;
    final actuales = state.valueOrNull;
    if (actuales == null) return;

    final porId = {for (final a in actualizaciones) a.id: a};
    state = AsyncData([for (final a in actuales) porId[a.id] ?? a]);
  }

  Future<Receta?> _recetaPara({
    required Producto producto,
    required List<String> despensa,
    required List<Receta> enCache,
    required PerfilNutricional? perfil,
  }) async {
    final productoKey = _normalizar(producto.nombre);

    final candidatas =
        enCache.where((r) => _recetaIncluyeProducto(r, productoKey)).toList()
          ..sort((a, b) => b.porcentajeMatch.compareTo(a.porcentajeMatch));
    if (candidatas.isNotEmpty) return candidatas.first;

    try {
      final raw = await _busquedaDataSource.buscarRecetasPorDespensaRaw(
        productosDespensa: despensa,
        number: 1,
        perfil: perfil,
        ingredientePrincipal: producto.nombre,
      );
      final recetas = RecetaBusquedaRemoteModel.fromApiRawList(
        raw,
      ).map((model) => model.toDomain()).toList();
      return recetas.isEmpty ? null : recetas.first;
    } catch (_) {
      // Sin receta la alerta sigue siendo util.
      return null;
    }
  }

  Alerta _conReceta(Alerta alerta, Receta receta) => Alerta(
    id: alerta.id,
    productoId: alerta.productoId,
    nombreProducto: alerta.nombreProducto,
    emoji: alerta.emoji,
    fechaCaducidad: alerta.fechaCaducidad,
    tipo: alerta.tipo,
    creadaEn: alerta.creadaEn,
    dismissedAt: alerta.dismissedAt,
    recetaSugerida: receta,
  );

  bool _recetaIncluyeProducto(Receta receta, String productoKey) {
    if (productoKey.isEmpty) return false;
    final ingredientes = receta.ingredientes ?? const <String>[];
    return ingredientes.any((ing) => _normalizar(ing).contains(productoKey));
  }

  String _normalizar(String texto) => texto.toLowerCase().trim();
}

final alertasProvider = AsyncNotifierProvider<AlertasNotifier, List<Alerta>>(
  AlertasNotifier.new,
);
