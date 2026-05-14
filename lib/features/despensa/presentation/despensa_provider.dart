import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    await ref.read(alertasProvider.notifier).refrescar();
  }

  Future<void> consumir(String id) async {
    await _repo.eliminar(id);
    await _repo.incrementarSalvados();
    _salvados++;
    state = AsyncData(
      (state.value ?? []).where((p) => p.id != id).toList(),
    );
    await ref.read(alertasProvider.notifier).refrescar();
  }

  Future<void> eliminar(String id) async {
    await _repo.eliminar(id);
    state = AsyncData(
      (state.value ?? []).where((p) => p.id != id).toList(),
    );
    await ref.read(alertasProvider.notifier).refrescar();
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