import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';

import '../data/despensa_compartida_repository.dart';
import '../domain/despensa_compartida.dart';

final despensaCompartidaRepoProvider = Provider<DespensaCompartidaRepository>(
  (_) => DespensaCompartidaRepository(),
);

/// Id de la despensa compartida activa, o null si el usuario esta en su
/// despensa personal. Es la fuente de verdad que enruta a los repositorios.
final despensaCompartidaIdProvider = StreamProvider<String?>((ref) async* {
  final user = await ref.watch(firebaseUserProvider.future);
  if (user == null) {
    yield null;
    return;
  }
  yield* ref.watch(despensaCompartidaRepoProvider).idCompartidaStream(user.uid);
});

/// Despensa compartida activa con sus miembros, en tiempo real.
final despensaCompartidaProvider = StreamProvider<DespensaCompartida?>((
  ref,
) async* {
  final id = await ref.watch(despensaCompartidaIdProvider.future);
  if (id == null) {
    yield null;
    return;
  }
  yield* ref.watch(despensaCompartidaRepoProvider).despensaStream(id);
});

/// Cantidad de productos en la despensa personal: define si hay que ofrecer
/// la migracion al entrar a una compartida.
final productosPersonalesCountProvider = FutureProvider<int>((ref) async {
  final user = await ref.watch(firebaseUserProvider.future);
  if (user == null) return 0;
  return ref
      .watch(despensaCompartidaRepoProvider)
      .contarProductosPersonales(user.uid);
});

/// Valida un codigo de invitacion sin unirse. Devuelve el id de la despensa o
/// null si el codigo no existe.
final buscarPorCodigoProvider = FutureProvider.family<String?, String>((
  ref,
  codigo,
) => ref.read(despensaCompartidaRepoProvider).buscarPorCodigo(codigo));

class CompartidaNotifier extends AsyncNotifier<void> {
  DespensaCompartidaRepository get _repo =>
      ref.read(despensaCompartidaRepoProvider);

  @override
  Future<void> build() async {}

  Future<User> _usuario() async {
    final user = await ref.read(firebaseUserProvider.future);
    if (user == null) {
      throw DespensaCompartidaException('Debes iniciar sesión.');
    }
    return user;
  }

  MiembroDespensa _comoMiembro(User user) => MiembroDespensa(
    uid: user.uid,
    nombre: user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email ?? 'Miembro'),
    email: user.email,
    fotoUrl: user.photoURL,
    unidoEn: DateTime.now(),
  );

  Future<void> crear({required String nombre, required bool migrar}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _usuario();
      final despensa = await _repo.crear(
        nombre: nombre,
        admin: _comoMiembro(user),
      );
      if (migrar) {
        await _repo.migrarProductosPersonales(
          userId: user.uid,
          despensaId: despensa.id,
        );
      }
      _refrescarDependientes();
    });
    _propagarError();
  }

  Future<void> unirse({required String codigo, required bool migrar}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _usuario();
      final despensa = await _repo.unirsePorCodigo(
        codigo: codigo,
        usuario: _comoMiembro(user),
      );
      if (migrar) {
        await _repo.migrarProductosPersonales(
          userId: user.uid,
          despensaId: despensa.id,
        );
      }
      _refrescarDependientes();
    });
    _propagarError();
  }

  Future<void> salir(String despensaId, {String? nuevoAdminUid}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _usuario();
      await _repo.salir(
        despensaId: despensaId,
        userId: user.uid,
        nuevoAdminUid: nuevoAdminUid,
      );
      _refrescarDependientes();
    });
    _propagarError();
  }

  Future<void> expulsar({
    required String despensaId,
    required String userId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _usuario();
      await _repo.expulsar(
        despensaId: despensaId,
        adminUid: user.uid,
        userId: userId,
      );
    });
    _propagarError();
  }

  Future<void> eliminar(String despensaId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _usuario();
      await _repo.eliminar(despensaId: despensaId, adminUid: user.uid);
      _refrescarDependientes();
    });
    _propagarError();
  }

  void _refrescarDependientes() {
    ref.invalidate(productosPersonalesCountProvider);
  }

  /// AsyncValue.guard captura el error; la UI lo espera como excepcion.
  void _propagarError() {
    final error = state.error;
    if (error != null) throw error;
  }
}

final compartidaProvider = AsyncNotifierProvider<CompartidaNotifier, void>(
  CompartidaNotifier.new,
);
