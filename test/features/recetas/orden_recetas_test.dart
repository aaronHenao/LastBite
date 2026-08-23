import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/constants/momento_comida.dart';
import 'package:lastbite/features/recetas/domain/orden_recetas.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';

/// Construye una receta con lo minimo para ordenar.
///
/// `usados`/`faltantes` definen el porcentajeMatch, que es el criterio de
/// desempate final.
Receta _receta({
  required int id,
  required String titulo,
  int? minutos,
  List<String>? dishTypes,
  int usados = 2,
  int faltantes = 2,
}) {
  return Receta(
    id: id,
    titulo: titulo,
    imagenUrl: '',
    ingredientesUsados: usados,
    ingredientesFaltantes: faltantes,
    likes: 0,
    minutosPreparacion: minutos,
    dishTypes: dishTypes,
  );
}

List<String> _ordenar(
  List<Receta> recetas, {
  bool ordenarPorTiempo = false,
  MomentoComida? momento,
}) {
  final copia = [...recetas]..sort(
    (a, b) => compararRecetas(
      a,
      b,
      ordenarPorTiempo: ordenarPorTiempo,
      momento: momento,
    ),
  );
  return copia.map((r) => r.titulo).toList();
}

void main() {
  // Datos reales tomados de 10 llamadas a Spoonacular (findByIngredients +
  // informationBulk). 26 de 30 recetas devolvieron readyInMinutes = 45, por
  // eso los casos con tiempos distintos son los interesantes.
  group('orden por tiempo con datos reales de Spoonacular', () {
    test('despensa yogurt/banana/oats: 10, 20 y 45 min quedan ascendentes', () {
      final recetas = [
        _receta(id: 655340, titulo: 'de 45', minutos: 45),
        _receta(id: 638604, titulo: 'de 10', minutos: 10),
        _receta(id: 1021260, titulo: 'de 20', minutos: 20),
      ];

      expect(
        _ordenar(recetas, ordenarPorTiempo: true),
        ['de 10', 'de 20', 'de 45'],
      );
    });

    test('despensa lentils/pepper/cumin: la de 25 sube sobre las de 45', () {
      final recetas = [
        _receta(id: 664087, titulo: 'primera de 45', minutos: 45, usados: 3),
        _receta(id: 640062, titulo: 'la de 25', minutos: 25, usados: 1),
        _receta(id: 632710, titulo: 'segunda de 45', minutos: 45, usados: 2),
      ];

      expect(_ordenar(recetas, ordenarPorTiempo: true).first, 'la de 25');
    });

    test('con el orden apagado manda el match, no el tiempo', () {
      final recetas = [
        _receta(id: 1, titulo: 'lenta pero aprovecha', minutos: 45, usados: 4),
        _receta(id: 2, titulo: 'rapida', minutos: 10, usados: 1, faltantes: 4),
      ];

      expect(_ordenar(recetas).first, 'lenta pero aprovecha');
      expect(_ordenar(recetas, ordenarPorTiempo: true).first, 'rapida');
    });

    test('el empate de 45/45/45 cae al match, sin alterar nada mas', () {
      final recetas = [
        _receta(id: 1, titulo: 'match bajo', minutos: 45, usados: 1),
        _receta(id: 2, titulo: 'match alto', minutos: 45, usados: 4),
        _receta(id: 3, titulo: 'match medio', minutos: 45, usados: 2),
      ];

      expect(
        _ordenar(recetas, ordenarPorTiempo: true),
        ['match alto', 'match medio', 'match bajo'],
      );
    });

    test('las recetas sin tiempo conocido quedan al final', () {
      final recetas = [
        _receta(id: 1, titulo: 'sin tiempo', usados: 4),
        _receta(id: 2, titulo: 'con tiempo', minutos: 45, usados: 1),
      ];

      expect(
        _ordenar(recetas, ordenarPorTiempo: true),
        ['con tiempo', 'sin tiempo'],
      );
    });
  });

  group('orden por momento del dia', () {
    // dishTypes tal cual los devolvio Spoonacular en las 10 llamadas.
    const tiposDesayuno = ['morning meal', 'brunch', 'breakfast'];
    const tiposPrincipal = ['lunch', 'main course', 'main dish', 'dinner'];

    test('en la manana el desayuno sube sobre el plato fuerte', () {
      final recetas = [
        _receta(
          id: 1,
          titulo: 'plato fuerte',
          dishTypes: tiposPrincipal,
          usados: 4,
        ),
        _receta(
          id: 2,
          titulo: 'desayuno',
          dishTypes: tiposDesayuno,
          usados: 1,
          faltantes: 4,
        ),
      ];

      expect(
        _ordenar(recetas, momento: MomentoComida.desayuno).first,
        'desayuno',
      );
    });

    test('pasado el mediodia sube el plato fuerte', () {
      final recetas = [
        _receta(
          id: 1,
          titulo: 'desayuno',
          dishTypes: tiposDesayuno,
          usados: 4,
        ),
        _receta(
          id: 2,
          titulo: 'plato fuerte',
          dishTypes: tiposPrincipal,
          usados: 1,
          faltantes: 4,
        ),
      ];

      expect(
        _ordenar(recetas, momento: MomentoComida.principal).first,
        'plato fuerte',
      );
    });

    test('el momento manda sobre el tiempo', () {
      final recetas = [
        _receta(
          id: 1,
          titulo: 'plato fuerte rapido',
          minutos: 10,
          dishTypes: tiposPrincipal,
        ),
        _receta(
          id: 2,
          titulo: 'desayuno lento',
          minutos: 45,
          dishTypes: tiposDesayuno,
        ),
      ];

      expect(
        _ordenar(
          recetas,
          ordenarPorTiempo: true,
          momento: MomentoComida.desayuno,
        ).first,
        'desayuno lento',
      );
    });

    test('dentro del mismo momento desempata el tiempo', () {
      final recetas = [
        _receta(
          id: 1,
          titulo: 'fuerte lento',
          minutos: 45,
          dishTypes: tiposPrincipal,
        ),
        _receta(
          id: 2,
          titulo: 'fuerte rapido',
          minutos: 20,
          dishTypes: tiposPrincipal,
        ),
      ];

      expect(
        _ordenar(
          recetas,
          ordenarPorTiempo: true,
          momento: MomentoComida.principal,
        ).first,
        'fuerte rapido',
      );
    });

    test('sin dishTypes la receta no se prioriza ni se castiga de mas', () {
      // 1 de las 30 recetas reales vino con dishTypes vacio.
      final recetas = [
        _receta(id: 1, titulo: 'sin tipos', dishTypes: const [], usados: 4),
        _receta(id: 2, titulo: 'tambien sin tipos', usados: 1, faltantes: 4),
      ];

      // Ninguna encaja, asi que decide el match.
      expect(
        _ordenar(recetas, momento: MomentoComida.principal),
        ['sin tipos', 'tambien sin tipos'],
      );
    });

    test('sin momento definido el criterio no se aplica', () {
      final recetas = [
        _receta(
          id: 1,
          titulo: 'desayuno con match bajo',
          dishTypes: tiposDesayuno,
          usados: 1,
          faltantes: 4,
        ),
        _receta(id: 2, titulo: 'match alto', dishTypes: tiposPrincipal, usados: 4),
      ];

      expect(_ordenar(recetas).first, 'match alto');
    });
  });

  group('momentoComidaDe', () {
    test('antes de las 11 es desayuno', () {
      expect(momentoComidaDe(DateTime(2026, 8, 24, 7)), MomentoComida.desayuno);
      expect(
        momentoComidaDe(DateTime(2026, 8, 24, 10, 59)),
        MomentoComida.desayuno,
      );
    });

    test('desde las 11 es plato principal', () {
      expect(
        momentoComidaDe(DateTime(2026, 8, 24, 11)),
        MomentoComida.principal,
      );
      expect(
        momentoComidaDe(DateTime(2026, 8, 24, 20)),
        MomentoComida.principal,
      );
    });
  });

  group('encajaConMomento', () {
    test('reconoce los tipos reales de desayuno', () {
      expect(
        encajaConMomento(['morning meal', 'brunch', 'breakfast'],
            MomentoComida.desayuno),
        isTrue,
      );
    });

    test('reconoce los tipos reales de plato fuerte', () {
      expect(
        encajaConMomento(['lunch', 'main course', 'main dish', 'dinner'],
            MomentoComida.principal),
        isTrue,
      );
    });

    test('side dish y soup no cuentan como plato fuerte por si solos', () {
      expect(
        encajaConMomento(['side dish'], MomentoComida.principal),
        isFalse,
      );
    });

    test('ignora mayusculas y espacios', () {
      expect(
        encajaConMomento([' BREAKFAST '], MomentoComida.desayuno),
        isTrue,
      );
    });

    test('null y vacio no encajan con nada', () {
      expect(encajaConMomento(null, MomentoComida.desayuno), isFalse);
      expect(encajaConMomento(const [], MomentoComida.principal), isFalse);
    });
  });
}
