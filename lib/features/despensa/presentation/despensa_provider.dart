import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/alertas/presentation/alertas_provider.dart';
import '../data/despensa_repository.dart';
import '../domain/producto.dart';

class DespensaNotifier extends AsyncNotifier<List<Producto>> {

  late DespensaRepository _repo;
  int _salvados = 0;
  int get salvados => _salvados;

  @override
  Future<List<Producto>> build() async {
    final auth = ref.watch(firebaseUserProvider);
    final user = auth.value;
    if (user == null) {
      _salvados = 0;
      return [];
    }

    _repo = DespensaRepository(userId: user.uid);
    
    final resultados = await Future.wait([
      _repo.cargarProductos(),
      _repo.cargarSalvados(),
    ]);

    _salvados = resultados[1] as int;
    return resultados[0] as List<Producto>;

  }

  Future<void> agregar(Producto producto) async {
    await _repo.guardar(producto);
    state = AsyncData([...state.value ?? [], producto]);
    try {
      await ref.read(alertasProvider.notifier).refrescar();
    } catch (_) {
      ref.invalidate(alertasProvider);
    }
  }

  Future<void> consumir(String id) async {
    await _repo.eliminar(id);
    await _repo.incrementarSalvados();
    _salvados++;
    state = AsyncData(
      (state.value ?? []).where((p) => p.id != id).toList(),
    );
    try {
      await ref.read(alertasProvider.notifier).refrescar();
    } catch (_) {
      ref.invalidate(alertasProvider);
    }
  }

  Future<void> eliminar(String id) async {
    await _repo.eliminar(id);
    state = AsyncData(
      (state.value ?? []).where((p) => p.id != id).toList(),
    );
    try {
      await ref.read(alertasProvider.notifier).refrescar();
    } catch (_) {
      ref.invalidate(alertasProvider);
    }
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