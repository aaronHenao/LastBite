import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/constants/unidades_medida.dart';
import 'package:lastbite/core/constants/vida_util.dart';

void main() {
  group('dimension', () {
    test('clasifica cada unidad en su magnitud', () {
      expect(UnidadMedida.gramo.dimension, DimensionMedida.masa);
      expect(UnidadMedida.kilogramo.dimension, DimensionMedida.masa);
      expect(UnidadMedida.mililitro.dimension, DimensionMedida.volumen);
      expect(UnidadMedida.taza.dimension, DimensionMedida.volumen);
      expect(UnidadMedida.unidad.dimension, DimensionMedida.conteo);
    });
  });

  group('unidadesPara', () {
    test('lo que se vende por peso no admite volumen', () {
      final carne = unidadesPara('Carne');
      expect(carne, contains(UnidadMedida.gramo));
      expect(carne, contains(UnidadMedida.kilogramo));
      expect(carne, isNot(contains(UnidadMedida.taza)));
      expect(carne, isNot(contains(UnidadMedida.litro)));
    });

    test('lo que se vende por volumen no admite peso', () {
      final leche = unidadesPara('Leche');
      expect(leche, contains(UnidadMedida.litro));
      expect(leche, contains(UnidadMedida.mililitro));
      expect(leche, isNot(contains(UnidadMedida.kilogramo)));
    });

    test('lo contable siempre admite unidad', () {
      expect(unidadesPara('Huevo').first, UnidadMedida.unidad);
    });

    test("'Otro' acepta todo porque no se puede asumir nada", () {
      expect(unidadesPara('Otro'), UnidadMedida.values);
    });

    test('ignora mayúsculas y espacios', () {
      expect(unidadesPara('  carne  '), unidadesPara('Carne'));
    });

    test('toda categoría ofrece al menos una unidad', () {
      for (final categoria in vidaUtilPorCategoria.keys) {
        expect(unidadesPara(categoria), isNotEmpty, reason: categoria);
      }
    });
  });

  group('unidadValida', () {
    test('acepta las coherentes y rechaza las que no', () {
      expect(unidadValida('Carne', UnidadMedida.gramo), isTrue);
      expect(unidadValida('Carne', UnidadMedida.cucharada), isFalse);
      expect(unidadValida('Leche', UnidadMedida.litro), isTrue);
      expect(unidadValida('Leche', UnidadMedida.gramo), isFalse);
      expect(unidadValida('Huevo', UnidadMedida.unidad), isTrue);
      expect(unidadValida('Huevo', UnidadMedida.taza), isFalse);
    });
  });
}
