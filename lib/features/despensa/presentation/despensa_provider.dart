import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/producto.dart';

class DespensaNotifier extends Notifier<List<Producto>> {

  @override
  List<Producto> build() {
    //por ahora inicializamos con los datos de ejemplo, cambia cuando empecemos a usar firebase
    return [...productosEjemplo];
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

//provider global para acceder a la despensa desde cualquier parte de la app, se puede usar para escuchar cambios o para modificar el estado de la despensa
final despensaProvider =
    NotifierProvider<DespensaNotifier, List<Producto>>(
  DespensaNotifier.new,
);