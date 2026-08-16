import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/constants/precio_promedio.dart';
import 'package:lastbite/core/constants/vida_util.dart';

void main() {
  group('precioEstimado', () {
    test('devuelve el precio de una categoría conocida', () {
      expect(precioEstimado('Verdura'), precioPromedioPorCategoria['Verdura']);
    });

    test('una categoría desconocida cae a Otro', () {
      expect(precioEstimado('Marciano'), precioPromedioPorCategoria['Otro']);
    });

    test('el lookup ignora mayúsculas y espacios', () {
      expect(precioEstimado('  verdura  '), precioEstimado('Verdura'));
      expect(precioEstimado('CARNE'), precioEstimado('Carne'));
    });

    test('una categoría vacía cae a Otro sin lanzar', () {
      expect(precioEstimado(''), precioPromedioPorCategoria['Otro']);
    });
  });

  group('ahorroEstimado', () {
    test('un mapa vacío da cero', () {
      expect(ahorroEstimado({}), 0);
    });

    test('multiplica por la cantidad salvada', () {
      expect(ahorroEstimado({'Verdura': 3}), precioEstimado('Verdura') * 3);
    });

    test('suma varias categorías', () {
      final esperado = precioEstimado('Verdura') * 2 + precioEstimado('Carne');
      expect(ahorroEstimado({'Verdura': 2, 'Carne': 1}), esperado);
    });

    test('las categorías desconocidas aportan el precio de Otro', () {
      expect(ahorroEstimado({'Marciano': 1}), precioEstimado('Otro'));
    });
  });

  test('cubre exactamente las mismas categorías que vida_util', () {
    expect(
      precioPromedioPorCategoria.keys.toSet(),
      vidaUtilPorCategoria.keys.toSet(),
    );
  });

  test('todos los precios son positivos', () {
    for (final entry in precioPromedioPorCategoria.entries) {
      expect(entry.value, greaterThan(0), reason: 'categoría ${entry.key}');
    }
  });
}
