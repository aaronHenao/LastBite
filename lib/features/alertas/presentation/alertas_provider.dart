import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import 'package:lastbite/features/recetas/data/services/recetas_service.dart';
import '../data/alertas_repository.dart';
import '../domain/alerta.dart';

class AlertasNotifier extends AsyncNotifier<List<Alerta>> {
  late AlertasRepository _repo;
  late RecetasService _recetasService;
  final Set<String> _generadas = {};
  bool _verificando = false;

  @override
  Future<List<Alerta>> build() async {
    final user = await ref.watch(firebaseUserProvider.future);
    if (user == null) return [];

    _repo = AlertasRepository(userId: user.uid);
    _recetasService = RecetasService();

    final alertas = await _repo.cargarAlertas();
    _generadas
      ..clear()
      ..addAll(alertas.map((a) => a.id));

    ref.listen(
      despensaProvider,
      (_, next) {
        next.whenData(
          (productos) => Future.microtask(() => _verificarProductos(productos)),
        );
      },
      fireImmediately: true,
    );

    return alertas;
  }

  Future<void> eliminar(String id) async {
    await _repo.eliminarAlerta(id);
    _generadas.remove(id);
    state = AsyncData((state.value ?? []).where((a) => a.id != id).toList());
  }

  Future<void> eliminarTodas() async {
    await _repo.eliminarTodas();
    _generadas.clear();
    state = const AsyncData([]);
  }

  Future<void> _verificarProductos(List<Producto> productos) async {
    if (_verificando) return;
    _verificando = true;

    try {
      const umbrales = [5, 3, 1];
      final pendientes = <({Alerta alerta, bool necesitaReceta})>[];

      for (final p in productos) {
        if (p.diasRestantes < 0) continue;
        for (final umbral in umbrales) {
          if (p.diasRestantes > umbral) continue;
          final alertaId = '${p.id}_$umbral';
          if (_generadas.contains(alertaId)) continue;

          pendientes.add((
            alerta: Alerta(
              id: alertaId,
              productoId: p.id,
              productoNombre: p.nombre,
              productoEmoji: p.emoji,
              umbral: umbral,
              fechaCaducidad: p.fechaCaducidad,
              fechaCreacion: DateTime.now(),
            ),
            necesitaReceta: umbral <= 3,
          ));
        }
      }

      if (pendientes.isEmpty) return;

      final recetaFutures = pendientes
          .map((e) => e.necesitaReceta
              ? _fetchReceta(e.alerta.productoNombre)
              : Future<Map<String, dynamic>?>.value(null))
          .toList();

      final recetas = await Future.wait(recetaFutures);

      final nuevas = <Alerta>[];
      for (var i = 0; i < pendientes.length; i++) {
        var alerta = pendientes[i].alerta;
        final receta = recetas[i];
        if (receta != null) {
          alerta = alerta.copyWith(
            recetaTitulo: receta['title']?.toString(),
            recetaSpoonId: (receta['id'] as num?)?.toInt(),
            recetaImagen: receta['image']?.toString(),
          );
        }
        nuevas.add(alerta);
      }

      await Future.wait(nuevas.map(_repo.guardarAlerta));
      for (final a in nuevas) {
        _generadas.add(a.id);
      }

      final todas = await _repo.cargarAlertas();
      state = AsyncData(todas);
    } catch (_) {
      // Silent — alert generation must never crash the app
    } finally {
      _verificando = false;
    }
  }

  Future<Map<String, dynamic>?> _fetchReceta(String nombreProducto) async {
    try {
      final resultados = await _recetasService
          .buscarRecetasPorDespensaRaw(
            productosDespensa: [nombreProducto],
            number: 1,
          )
          .timeout(const Duration(seconds: 10));
      return resultados.isNotEmpty ? resultados.first : null;
    } catch (_) {
      return null;
    }
  }
}

final alertasProvider =
    AsyncNotifierProvider<AlertasNotifier, List<Alerta>>(AlertasNotifier.new);
