import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/constants/vida_util.dart';
import 'package:lastbite/core/utils/categoria_mapper.dart';

void main() {
  group('esCategoriaFresca', () {
    test('reconoce las categorias frescas como se guardan de verdad', () {
      // Las categorias reales llevan mayuscula inicial. Compararlas en
      // minuscula hacia que todo producto escaneado se guardara como no fresco.
      expect(esCategoriaFresca('Fruta'), isTrue);
      expect(esCategoriaFresca('Verdura'), isTrue);
      expect(esCategoriaFresca('Hierba'), isTrue);
    });

    test('ignora mayusculas y espacios', () {
      expect(esCategoriaFresca(' fruta '), isTrue);
      expect(esCategoriaFresca('VERDURA'), isTrue);
    });

    test('lo que no es fresco no lo es', () {
      expect(esCategoriaFresca('Conserva'), isFalse);
      expect(esCategoriaFresca('Grano'), isFalse);
      expect(esCategoriaFresca(''), isFalse);
    });
  });

  group('emojiParaCategoria', () {
    test('da el mismo emoji sin importar como venga escrita la categoria', () {
      expect(emojiParaCategoria('Mantequilla'), emojiParaCategoria('mantequilla'));
      expect(emojiParaCategoria('Mantequilla'), '🧈');
    });

    test('cubre todas las categorias de vida util', () {
      // Antes habia tres mapas distintos y ninguno cubria Hierba ni Cereal.
      for (final categoria in vidaUtilPorCategoria.keys) {
        expect(
          emojiParaCategoria(categoria),
          isNot('🥫'),
          reason: '$categoria cae en el emoji por defecto',
          skip: categoria == 'Conserva' || categoria == 'Otro',
        );
      }
    });

    test('una categoria desconocida no revienta', () {
      expect(emojiParaCategoria('Marciano'), '🥫');
    });
  });
}
