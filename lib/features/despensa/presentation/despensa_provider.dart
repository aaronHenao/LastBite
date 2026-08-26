import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/notifications/vencimiento_checker.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/core/constants/precio_promedio.dart';
import 'package:lastbite/features/compartida/presentation/compartida_provider.dart';
import '../data/despensa_repository.dart';
import '../domain/producto.dart';

class DespensaNotifier extends StreamNotifier<List<Producto>> {
  late DespensaRepository _repo;

  int _salvados = 0;
  int get salvados => _salvados;

  /// Cantidad salvada este mes por categoria, en su unidad base.
  Map<String, double> _conteoMes = {};
  Map<String, double> get conteoMes => _conteoMes;
  int get ahorroMes => ahorroEstimado(_conteoMes);

  @override
  Stream<List<Producto>> build() async* {
    final user = await ref.watch(firebaseUserProvider.future);
    if (user == null) {
      yield [];
      return;
    }

    final compartidaId = await ref.watch(despensaCompartidaIdProvider.future);
    _repo = DespensaRepository(
      userId: user.uid,
      despensaCompartidaId: compartidaId,
    );

    final resultados = await Future.wait([
      _repo.cargarSalvados(),
      _repo.cargarConteoMes(DateTime.now()),
    ]);

    _salvados = resultados[0] as int;
    _conteoMes = resultados[1] as Map<String, double>;

    yield* _repo.productosStream();
  }

  // Ninguna de estas operaciones toca la lista a mano: productosStream es la
  // unica fuente y Firestore la emite de inmediato con el cambio local.

  Future<void> agregar(Producto producto) async {
    await _repo.guardar(producto);
    Future.delayed(const Duration(seconds: 5), () {
      VencimientoChecker.instance.verificar();
    });
  }

  Future<void> consumir(String id) async {
    final producto = (state.value ?? []).firstWhere((p) => p.id == id);

    await _repo.eliminar(id);
    await _repo.incrementarSalvados();

    // Métrica de ahorro: no es crítica, así que no bloquea el consumo ni lo
    // hace fallar si Firestore no responde.
    final cantidad = cantidadEnBase(producto.categoria, producto.cantidad);
    unawaited(
      _repo
          .registrarSalvado(producto.categoria, cantidad, DateTime.now())
          .catchError((Object _) {}),
    );

    if (producto.urgente) {
      await _repo.invalidarRecetasPorIngrediente(producto.nombre);
    }

    _salvados++;
    _conteoMes.update(
      producto.categoria,
      (v) => v + cantidad,
      ifAbsent: () => cantidad,
    );
    VencimientoChecker.instance.verificar();
  }

  Future<void> eliminar(String id) async {
    await _repo.eliminar(id);
  }

  List<Producto> get urgentes {
    return [...(state.value ?? [])]
      ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));
  }
}

final despensaProvider =
    StreamNotifierProvider<DespensaNotifier, List<Producto>>(
      DespensaNotifier.new,
    );
