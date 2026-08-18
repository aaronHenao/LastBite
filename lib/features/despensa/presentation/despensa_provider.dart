import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/notifications/vencimiento_checker.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/core/constants/precio_promedio.dart';
import '../data/despensa_repository.dart';
import '../domain/producto.dart';

class DespensaNotifier extends AsyncNotifier<List<Producto>> {
  late DespensaRepository _repo;

  int _salvados = 0;
  int get salvados => _salvados;

  /// Cantidad salvada este mes por categoria, en su unidad base.
  Map<String, double> _conteoMes = {};
  Map<String, double> get conteoMes => _conteoMes;
  int get ahorroMes => ahorroEstimado(_conteoMes);

  @override
  Future<List<Producto>> build() async {
    final user = await ref.watch(firebaseUserProvider.future);
    if (user == null) return [];

    _repo = DespensaRepository(userId: user.uid);

    final resultados = await Future.wait([
      _repo.cargarProductos(),
      _repo.cargarSalvados(),
      _repo.cargarConteoMes(DateTime.now()),
    ]);

    _salvados = resultados[1] as int;
    _conteoMes = resultados[2] as Map<String, double>;
    return resultados[0] as List<Producto>;
  }

  Future<void> agregar(Producto producto) async {
    await _repo.guardar(producto);
    state = AsyncData([...state.value ?? [], producto]);
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
    state = AsyncData((state.value ?? []).where((p) => p.id != id).toList());

    VencimientoChecker.instance.verificar();
  }

  Future<void> eliminar(String id) async {
    await _repo.eliminar(id);
    state = AsyncData((state.value ?? []).where((p) => p.id != id).toList());
  }

  List<Producto> get urgentes {
    return [...(state.value ?? [])]
      ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));
  }
}

final despensaProvider =
    AsyncNotifierProvider<DespensaNotifier, List<Producto>>(
      DespensaNotifier.new,
    );
