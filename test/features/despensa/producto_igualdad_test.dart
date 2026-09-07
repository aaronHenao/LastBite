import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';

Producto _producto({String id = '1', String nombre = 'Leche'}) => Producto(
  id: id,
  nombre: nombre,
  emoji: '🥛',
  categoria: 'Leche',
  cantidad: '1 L',
  fechaCaducidad: DateTime(2026, 3, 14),
  esFresco: false,
);

void main() {
  group('Producto define igualdad por contenido', () {
    test('dos instancias con los mismos datos son iguales', () {
      expect(_producto(), _producto());
      expect(_producto().hashCode, _producto().hashCode);
    });

    test('un campo distinto las separa', () {
      expect(_producto(), isNot(_producto(nombre: 'Yogur')));
      expect(_producto(), isNot(_producto(id: '2')));
    });

    test('dos listas con el mismo contenido son iguales', () {
      // Sin esto, cada re-emision del stream de Firestore se tomaba como un
      // cambio real: regeneraba las alertas y volvia a llamar a Spoonacular.
      final a = [_producto(id: '1'), _producto(id: '2', nombre: 'Pan')];
      final b = [_producto(id: '1'), _producto(id: '2', nombre: 'Pan')];
      expect(a, equals(b));
    });
  });
}
