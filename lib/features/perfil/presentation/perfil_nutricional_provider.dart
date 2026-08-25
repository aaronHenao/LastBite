import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import '../data/perfil_nutricional_repository.dart';
import '../domain/perfil_nutricional.dart';

class PerfilNutricionalNotifier extends AsyncNotifier<PerfilNutricional?> {
  PerfilNutricionalRepository? _repository;

  @override
  Future<PerfilNutricional?> build() async {
    final user = await ref.watch(firebaseUserProvider.future);
    if (user == null) return null;
    _repository = PerfilNutricionalRepository(userId: user.uid);
    return _repository!.cargar();
  }

  Future<void> guardar(PerfilNutricional perfil) async {
    final repository = _repository;
    if (repository == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.guardar(perfil);
      return perfil;
    });
  }
}

final perfilNutricionalProvider =
    AsyncNotifierProvider<PerfilNutricionalNotifier, PerfilNutricional?>(
      PerfilNutricionalNotifier.new,
    );
