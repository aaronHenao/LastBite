import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/constants/precio_promedio.dart';
import 'package:lastbite/core/constants/vida_util.dart';

void main() {
  group('precioDeCategoria', () {
    test('devuelve la entrada de una categoría conocida', () {
      expect(precioDeCategoria('Carne').base, BaseMedida.kilo);
      expect(precioDeCategoria('Leche').base, BaseMedida.litro);
      expect(precioDeCategoria('Huevo').base, BaseMedida.unidad);
    });

    test('ignora mayúsculas y espacios', () {
      expect(
        precioDeCategoria('  carne  ').precio,
        precioDeCategoria('Carne').precio,
      );
    });

    test('una categoría desconocida cae a Otro', () {
      expect(
        precioDeCategoria('Marciano').precio,
        preciosPorCategoria['Otro']!.precio,
      );
    });
  });

  group('leerCantidad', () {
    test('lee masa y la normaliza a kilos', () {
      final r = leerCantidad('500 g')!;
      expect(r.base, BaseMedida.kilo);
      expect(r.valor, closeTo(0.5, 1e-9));
    });

    test('lee volumen y lo normaliza a litros', () {
      final r = leerCantidad('250 ml')!;
      expect(r.base, BaseMedida.litro);
      expect(r.valor, closeTo(0.25, 1e-9));
    });

    test('acepta coma decimal y falta de espacio', () {
      expect(leerCantidad('1,5 L')!.valor, closeTo(1.5, 1e-9));
      expect(leerCantidad('2unidades')!.valor, closeTo(2, 1e-9));
    });

    test('un número sin unidad se cuenta como unidades', () {
      final r = leerCantidad('3')!;
      expect(r.base, BaseMedida.unidad);
      expect(r.valor, closeTo(3, 1e-9));
    });

    test('convierte onzas y libras a kilos', () {
      expect(leerCantidad('1 lb')!.valor, closeTo(0.453592, 1e-6));
      expect(leerCantidad('1 oz')!.base, BaseMedida.kilo);
    });

    test('devuelve null cuando no hay número o la unidad es desconocida', () {
      expect(leerCantidad(''), isNull);
      expect(leerCantidad('al gusto'), isNull);
      expect(leerCantidad('2 cda'), isNull);
      expect(leerCantidad('1 taza'), isNull);
      expect(leerCantidad('0 g'), isNull);
    });
  });

  group('cantidadEnBase', () {
    test('usa la cantidad leída cuando la dimensión coincide', () {
      expect(cantidadEnBase('Carne', '2 kg'), closeTo(2, 1e-9));
      expect(cantidadEnBase('Leche', '500 ml'), closeTo(0.5, 1e-9));
      expect(cantidadEnBase('Huevo', '12 unidades'), closeTo(12, 1e-9));
    });

    test('intercambia masa y volumen asumiendo densidad 1', () {
      // Leche se cotiza por litro pero el empaque viene en gramos.
      expect(cantidadEnBase('Leche', '900 g'), closeTo(0.9, 1e-9));
    });

    test('cae a la referencia si no se puede leer la cantidad', () {
      expect(
        cantidadEnBase('Carne', 'al gusto'),
        preciosPorCategoria['Carne']!.referencia,
      );
      expect(
        cantidadEnBase('Verdura', '2 cda'),
        preciosPorCategoria['Verdura']!.referencia,
      );
    });

    test('cae a la referencia si mezcla conteo con peso', () {
      // Huevo se cotiza por unidad; 500 g no dice cuántos huevos son.
      expect(
        cantidadEnBase('Huevo', '500 g'),
        preciosPorCategoria['Huevo']!.referencia,
      );
    });
  });

  group('ahorroEstimado', () {
    test('un mapa vacío da cero', () {
      expect(ahorroEstimado({}), 0);
    });

    test('escala con la cantidad, no con el número de productos', () {
      final medioKilo = ahorroEstimado({'Carne': 0.5});
      final dosKilos = ahorroEstimado({'Carne': 2.0});
      expect(dosKilos, medioKilo * 4);
    });

    test('suma varias categorías', () {
      final esperado =
          (preciosPorCategoria['Verdura']!.precio * 1.5 +
                  preciosPorCategoria['Leche']!.precio * 2.0)
              .round();
      expect(ahorroEstimado({'Verdura': 1.5, 'Leche': 2.0}), esperado);
    });

    test('las categorías desconocidas se cobran como Otro', () {
      expect(
        ahorroEstimado({'Marciano': 1.0}),
        preciosPorCategoria['Otro']!.precio,
      );
    });
  });

  group('integridad de la tabla', () {
    test('cubre exactamente las mismas categorías que vida_util', () {
      expect(
        preciosPorCategoria.keys.toSet(),
        vidaUtilPorCategoria.keys.toSet(),
      );
    });

    test('todos los precios y referencias son positivos', () {
      for (final entry in preciosPorCategoria.entries) {
        expect(entry.value.precio, greaterThan(0), reason: entry.key);
        expect(entry.value.referencia, greaterThan(0), reason: entry.key);
      }
    });
  });
}
