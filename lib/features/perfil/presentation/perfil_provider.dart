import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import '../data/lista_compras_repository.dart';
import '../domain/item_compra.dart';

class ListaComprasNotifier extends AsyncNotifier<List<ItemCompra>> {
  late ListaComprasRepository _repo;

  @override
  Future<List<ItemCompra>> build() async {
    final user = await ref.watch(firebaseUserProvider.future);
    if (user == null) return [];
    _repo = ListaComprasRepository(userId: user.uid);
    return _repo.cargar();
  }

  Future<void> agregar(ItemCompra item) async {
    await _repo.agregarSiNoExiste(item);
    state = AsyncData(await _repo.cargar());
  }

  Future<void> toggleComprado(String id) async {
    final items = state.value ?? [];
    final item = items.firstWhere((i) => i.id == id);
    final nuevoEstado = !item.comprado;
    await _repo.marcarComprado(id, nuevoEstado);
    state = AsyncData(
      items.map((i) => i.id == id ? i.copyWith(comprado: nuevoEstado) : i).toList(),
    );
  }

  Future<void> limpiarComprados() async {
    await _repo.limpiarComprados();
    state = AsyncData(await _repo.cargar());
  }

  Future<void> eliminar(String id) async {
    await _repo.eliminar(id);
    state = AsyncData((state.value ?? []).where((i) => i.id != id).toList());
  }
}

final listaComprasProvider =
    AsyncNotifierProvider<ListaComprasNotifier, List<ItemCompra>>(
  ListaComprasNotifier.new,
);