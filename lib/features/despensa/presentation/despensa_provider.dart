import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import '../data/despensa_repository.dart';
import '../domain/producto.dart';

class DespensaNotifier extends AsyncNotifier<List<Producto>> {

  late DespensaRepository _repo;
  int _salvados = 0;
  int get salvados => _salvados;

  @override
  Future<List<Producto>> build() async {
    final user = await ref.watch(firebaseUserProvider.future);
    if (user == null) return [];

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
  }

  Future<void> consumir(String id) async {
    await _repo.eliminar(id);
    await _repo.incrementarSalvados();    // ← incrementa en Firestore
    _salvados++;
    state = AsyncData(
      (state.value ?? []).where((p) => p.id != id).toList(),
    );
  }

  Future<void> eliminar(String id) async {
    await _repo.eliminar(id);
    state = AsyncData(
      (state.value ?? []).where((p) => p.id != id).toList(),
    );
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