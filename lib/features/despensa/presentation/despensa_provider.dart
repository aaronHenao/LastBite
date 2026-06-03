import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/notifications/vencimiento_checker.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/despensa/data/app_database.dart';
import '../data/despensa_repository.dart';
import '../domain/producto.dart';

final _dbProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// Stream que emite true si hay internet, false si no.
final conectividadProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );
});

class DespensaNotifier extends AsyncNotifier<List<Producto>> {
  late DespensaRepository _repo;
  late AppDatabase _db;

  int _salvados = 0;
  int get salvados => _salvados;

  @override
  Future<List<Producto>> build() async {
    final user = await ref.watch(firebaseUserProvider.future);
    if (user == null) return [];

    _db = ref.read(_dbProvider);
    _repo = DespensaRepository(userId: user.uid, db: _db);

    // Al recuperar conexión: sincronizar pendientes y recargar desde local (sin recrearse múltiples veces)
    ref.listen(conectividadProvider, (_, next) {
      next.whenData((tieneConexion) async {
        if (tieneConexion) {
          await _repo.sincronizarPendientes();
          // Recargar desde DB local (ya actualizada con synced)
          final productos = await _db.obtenerProductos(user.uid);
          state = AsyncData(productos);
        }
      });
    });

    final resultados = await Future.wait([
      _repo.cargarProductos(),
      _repo.cargarSalvados(),
    ]);

    _salvados = resultados[1] as int;
    return resultados[0] as List<Producto>;
  }

  Future<void> agregar(Producto producto) async {
    final conectividad = await Connectivity().checkConnectivity();
    final tieneConexion =
        !conectividad.contains(ConnectivityResult.none);

    final productoFinal = producto.copyWith(
      syncStatus: tieneConexion
          ? SyncStatus.synced
          : SyncStatus.pendingSync,
    );

    await _repo.guardar(productoFinal);

    state = AsyncData([
      ...state.value ?? [],
      productoFinal,
    ]);

    // Revisión de vencimientos (del sistema original)
    Future.delayed(const Duration(seconds: 5), () {
      VencimientoChecker.instance.verificar();
    });
  }

  Future<void> consumir(String id) async {
    final producto =
        (state.value ?? []).firstWhere((p) => p.id == id);

    await _repo.eliminar(id);
    await _repo.incrementarSalvados();

    if (producto.urgente) {
      await _repo.invalidarRecetasPorIngrediente(producto.nombre);
    }

    _salvados++;

    state = AsyncData(
      (state.value ?? []).where((p) => p.id != id).toList(),
    );

    // Revisión de vencimientos
    VencimientoChecker.instance.verificar();
  }

  Future<void> eliminar(String id) async {
    await _repo.eliminar(id);

    state = AsyncData(
      (state.value ?? []).where((p) => p.id != id).toList(),
    );
  }

  List<Producto> get urgentes {
    return [...(state.value ?? [])]
      ..sort(
        (a, b) => a.diasRestantes.compareTo(b.diasRestantes),
      );
  }
}

final despensaProvider =
    AsyncNotifierProvider<DespensaNotifier, List<Producto>>(
  DespensaNotifier.new,
);