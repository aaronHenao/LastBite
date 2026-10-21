import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/features/consulta_rapida/data/historial_busqueda_repository.dart';

final historialBusquedaRepositoryProvider = Provider<HistorialBusquedaRepository>(
  (ref) => HistorialBusquedaRepository(),
);

class HistorialBusquedaNotifier extends StateNotifier<List<String>> {
  HistorialBusquedaNotifier(this._repo) : super(const []) {
    _cargar();
  }

  final HistorialBusquedaRepository _repo;

  Future<void> _cargar() async {
    state = await _repo.obtener();
  }

  Future<void> agregar(String busqueda) async {
    state = await _repo.agregar(busqueda);
  }

  Future<void> limpiar() async {
    state = await _repo.limpiar();
  }
}

final historialBusquedaProvider =
    StateNotifierProvider<HistorialBusquedaNotifier, List<String>>(
      (ref) =>
          HistorialBusquedaNotifier(ref.watch(historialBusquedaRepositoryProvider)),
    );
