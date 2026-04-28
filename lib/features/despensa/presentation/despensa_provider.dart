import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/info_nutricional.dart';
import '../domain/producto.dart';
import '../data/datasources/open_food_facts_remote_data_source.dart';

class DespensaNotifier extends Notifier<List<Producto>> {
  @override
  List<Producto> build() {
    return <Producto>[];
  }

  void agregar(Producto producto) {
    state = [...state, producto];
  }

  void consumir(String id) {
    //elimina el producto y eventualmente sumará a "salvados"
    state = state.where((p) => p.id != id).toList();
  }

  void eliminar(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  //devuelve los productos ordenados por urgencia, será usado por el moto de recetas
  List<Producto> get urgentes {
    return [...state]
      ..sort((a, b) => a.diasRestantes.compareTo(b.diasRestantes));
  }
}

final _openFoodFactsProvider = Provider<OpenFoodFactsRemoteDataSource>((ref) {
  return OpenFoodFactsRemoteDataSource();
});

final infoNutricionalProvider = FutureProvider.family<InfoNutricional?, String>(
  (ref, codigo) async {
    final dataSource = ref.read(_openFoodFactsProvider);
    return dataSource.obtenerNutricionPorCodigo(codigo: codigo);
  },
);

//provider global para acceder a la despensa desde cualquier parte de la app, se puede usar para escuchar cambios o para modificar el estado de la despensa
final despensaProvider = NotifierProvider<DespensaNotifier, List<Producto>>(
  DespensaNotifier.new,
);
