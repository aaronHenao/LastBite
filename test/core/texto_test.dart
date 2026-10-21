import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/utils/texto.dart';

void main() {
  group('coincideBusqueda', () {
    test('ignora tildes, mayusculas y espacios sobrantes', () {
      expect(coincideBusqueda('Limón', '  LIMON '), isTrue);
      expect(coincideBusqueda('Pan integral', 'pan   integral'), isTrue);
    });

    test('no depende del orden de las palabras', () {
      expect(coincideBusqueda('Leche entera', 'entera leche'), isTrue);
    });

    test('busca por el comienzo de cada palabra', () {
      expect(coincideBusqueda('Queso campesino', 'camp'), isTrue);
      expect(coincideBusqueda('Queso campesino', 'pesino'), isFalse);
    });

    test('perdona un error de tipeo en palabras largas', () {
      expect(coincideBusqueda('Leche entera', 'lehce'), isTrue);
      expect(coincideBusqueda('Arroz blanco', 'arros'), isTrue);
      expect(coincideBusqueda('Leche entera', 'leh'), isFalse);
    });

    test('en palabras cortas no inventa coincidencias', () {
      // Un error en una palabra de cuatro letras ya es otro alimento.
      expect(coincideBusqueda('Perejil', 'pera'), isFalse);
    });

    test('todas las palabras buscadas tienen que aparecer', () {
      expect(coincideBusqueda('Leche entera', 'leche descremada'), isFalse);
    });

    test('una busqueda vacia lo muestra todo', () {
      expect(coincideBusqueda('Leche', '   '), isTrue);
    });
  });
}
