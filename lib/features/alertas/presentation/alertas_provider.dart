import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/recetas/data/datasources/ai_translation_data_source.dart';
import 'package:lastbite/features/recetas/data/datasources/recetas_busqueda_remote_data_source.dart';
import 'package:lastbite/features/recetas/data/models/receta_busqueda_remote_model.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';
import '../data/alertas_repository.dart';
import '../domain/alerta.dart';

class AlertasNotifier extends AsyncNotifier<List<Alerta>> {
  late AlertasRepository _repo;
  late AiTranslationDataSource _translator;
  late RecetasBusquedaRemoteDataSource _busquedaDataSource;

  String? _avisoTraduccion;
  String? get avisoTraduccion => _avisoTraduccion;

  @override
  Future<List<Alerta>> build() async {
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

    _repo = AlertasRepository(userId: user.uid);
    await _repo.borrarTodasAlertas(DateTime.now());
    state = const AsyncData([]);
  }

  Future<void> eliminar(String id) async {
    final user = await ref.read(firebaseUserProvider.future);
    if (user == null) return;

    _repo = AlertasRepository(userId: user.uid);
    await _repo.marcarAlertaBorrada(id, DateTime.now());
    state = AsyncData((state.value ?? []).where((a) => a.id != id).toList());
  }

  Future<List<Alerta>> _cargarAlertas() async {
    final user = await ref.watch(firebaseUserProvider.future);
    if (user == null) return [];

    _repo = AlertasRepository(userId: user.uid);
    _translator = AiTranslationDataSource();
    _busquedaDataSource = RecetasBusquedaRemoteDataSource(
      translator: _translator,
    );
    _avisoTraduccion = null;

    final resultados = await Future.wait([
      _repo.cargarProductos(),
      _repo.cargarAlertas(),
      _repo.cargarUltimoBorrado(),
    ]);

    final productos = resultados[0] as List<Producto>;
    final alertasExistentes = resultados[1] as List<Alerta>;
    final lastClearAt = resultados[2] as DateTime?;

    final nuevas = await _generarAlertas(
      productos: productos,
      alertasExistentes: alertasExistentes,
      lastClearAt: lastClearAt,
    );

    if (nuevas.isNotEmpty) {
      await _repo.guardarAlertas(nuevas);
      alertasExistentes.addAll(nuevas);
    }

    final visibles = alertasExistentes
      .where((alerta) => !alerta.estaOculta)
      .toList();
    visibles.sort((a, b) => b.creadaEn.compareTo(a.creadaEn));
    return visibles;
  }

  Future<List<Alerta>> _generarAlertas({
    required List<Producto> productos,
    required List<Alerta> alertasExistentes,
    required DateTime? lastClearAt,
  }) async {
    final existentesIds = alertasExistentes.map((a) => a.id).toSet();
    final productosNoVencidos = productos.where((p) => !p.vencido).toList()
      ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));
    final ingredientesDespensa = productosNoVencidos
        .map((p) => p.nombre)
        .where((name) => name.trim().isNotEmpty)
        .toList();

    final nuevas = <Alerta>[];

    for (final producto in productos) {
      if (producto.diasRestantes < 0) {
        final alerta = await _crearAlerta(
          producto: producto,
          tipo: AlertaTipo.vencido,
          existentesIds: existentesIds,
          lastClearAt: lastClearAt,
          umbralDias: 0,
          ingredientesDespensa: ingredientesDespensa,
        );
        if (alerta != null) nuevas.add(alerta);
        continue;
      }

      if (producto.diasRestantes <= 5) {
        final alerta = await _crearAlerta(
          producto: producto,
          tipo: AlertaTipo.aviso5,
          existentesIds: existentesIds,
          lastClearAt: lastClearAt,
          umbralDias: 5,
          ingredientesDespensa: ingredientesDespensa,
        );
        if (alerta != null) nuevas.add(alerta);
      }

      if (producto.diasRestantes <= 3) {
        final alerta = await _crearAlerta(
          producto: producto,
          tipo: AlertaTipo.aviso3,
          existentesIds: existentesIds,
          lastClearAt: lastClearAt,
          umbralDias: 3,
          ingredientesDespensa: ingredientesDespensa,
        );
        if (alerta != null) nuevas.add(alerta);
      }

      if (producto.diasRestantes <= 1) {
        final alerta = await _crearAlerta(
          producto: producto,
          tipo: AlertaTipo.aviso1,
          existentesIds: existentesIds,
          lastClearAt: lastClearAt,
          umbralDias: 1,
          ingredientesDespensa: ingredientesDespensa,
        );
        if (alerta != null) nuevas.add(alerta);
      }
    }

    return nuevas;
  }

  Future<Alerta?> _crearAlerta({
    required Producto producto,
    required AlertaTipo tipo,
    required Set<String> existentesIds,
    required DateTime? lastClearAt,
    required int umbralDias,
    required List<String> ingredientesDespensa,
  }) async {
    final alertaId = Alerta.buildId(productoId: producto.id, tipo: tipo);
    if (existentesIds.contains(alertaId)) return null;

    final fechaDisparo = producto.fechaCaducidad
        .subtract(Duration(days: umbralDias));

    if (lastClearAt != null && !fechaDisparo.isAfter(lastClearAt)) {
      return null;
    }

    Receta? receta;
    if (tipo == AlertaTipo.aviso3 || tipo == AlertaTipo.aviso1) {
      receta = await _buscarRecetaSugerida(
        producto: producto,
        ingredientesDespensa: ingredientesDespensa,
        maximizarMatch: tipo == AlertaTipo.aviso1,
      );
    }

    return Alerta(
      id: alertaId,
      productoId: producto.id,
      nombreProducto: producto.nombre,
      emoji: producto.emoji,
      fechaCaducidad: producto.fechaCaducidad,
      tipo: tipo,
      creadaEn: DateTime.now(),
      recetaSugerida: receta,
    );
  }

  Future<Receta?> _buscarRecetaSugerida({
    required Producto producto,
    required List<String> ingredientesDespensa,
    required bool maximizarMatch,
  }) async {
    try {
      final ingredientes = _combinarIngredientes(
        producto.nombre,
        ingredientesDespensa,
      );

      final recetas = await _buscarRecetas(ingredientes);
      final seleccion = _seleccionarReceta(
        recetas,
        producto.nombre,
        maximizarMatch: maximizarMatch,
      );

      if (seleccion != null) return seleccion;

      if (ingredientes.length > 1) {
        final recetasSoloProducto = await _buscarRecetas([producto.nombre]);
        return _seleccionarReceta(
          recetasSoloProducto,
          producto.nombre,
          maximizarMatch: maximizarMatch,
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<List<Receta>> _buscarRecetas(List<String> ingredientes) async {
    final raw = await _busquedaDataSource.buscarRecetasPorDespensaRaw(
      productosDespensa: ingredientes,
      number: 3,
      ignorePantry: false,
    );

    final recetas = RecetaBusquedaRemoteModel.fromApiRawList(
      raw,
    ).map((model) => model.toDomain()).toList();

    _capturarAvisoTraduccion();
    return recetas;
  }

  Receta? _seleccionarReceta(
    List<Receta> recetas,
    String productoNombre, {
    required bool maximizarMatch,
  }) {
    if (recetas.isEmpty) return null;

    final productoKey = _normalizar(productoNombre);
    final recetasConProducto = recetas
        .where(
          (receta) => _recetaIncluyeProducto(receta, productoKey),
        )
        .toList();

    final candidatas = recetasConProducto.isNotEmpty
        ? recetasConProducto
        : recetas;

    if (maximizarMatch) {
      candidatas.sort(
        (a, b) => b.porcentajeMatch.compareTo(a.porcentajeMatch),
      );
    }

    return candidatas.first;
  }

  bool _recetaIncluyeProducto(Receta receta, String productoKey) {
    if (productoKey.isEmpty) return false;
    final ingredientes = receta.ingredientes ?? const <String>[];

    return ingredientes.any((ing) {
      final normalizado = _normalizar(ing);
      return normalizado.contains(productoKey);
    });
  }

  List<String> _combinarIngredientes(
    String productoNombre,
    List<String> ingredientesDespensa,
  ) {
    final ingredientes = <String>{};

    final principal = productoNombre.trim();
    if (principal.isNotEmpty) ingredientes.add(principal);

    for (final ingrediente in ingredientesDespensa) {
      final limpio = ingrediente.trim();
      if (limpio.isNotEmpty) ingredientes.add(limpio);
    }

    return ingredientes.toList();
  }

  String _normalizar(String texto) => texto.toLowerCase().trim();

  void _capturarAvisoTraduccion() {
    final aviso = _busquedaDataSource.lastTranslationWarning;
    if (aviso != null && _avisoTraduccion == null) {
      _avisoTraduccion = aviso;
    }
  }
}

final alertasProvider = AsyncNotifierProvider<AlertasNotifier, List<Alerta>>(
  AlertasNotifier.new,
);
