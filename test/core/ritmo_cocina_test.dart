import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/constants/ritmo_cocina.dart';

void main() {
  group('priorizarRecetasRapidas', () {
    test('entre semana prioriza las recetas rapidas', () {
      // 2026-08-24 es lunes; hasta el viernes 28.
      for (var dia = 24; dia <= 28; dia++) {
        final fecha = DateTime(2026, 8, dia);
        expect(
          priorizarRecetasRapidas(fecha),
          isTrue,
          reason: 'weekday ${fecha.weekday} deberia priorizar rapidas',
        );
      }
    });

    test('el fin de semana no prioriza las rapidas', () {
      final sabado = DateTime(2026, 8, 29);
      final domingo = DateTime(2026, 8, 30);

      expect(sabado.weekday, DateTime.saturday);
      expect(domingo.weekday, DateTime.sunday);
      expect(priorizarRecetasRapidas(sabado), isFalse);
      expect(priorizarRecetasRapidas(domingo), isFalse);
    });

    test('la hora del dia no influye, solo el dia', () {
      final lunesTemprano = DateTime(2026, 8, 24, 6, 30);
      final lunesDeNoche = DateTime(2026, 8, 24, 23, 45);

      expect(priorizarRecetasRapidas(lunesTemprano), isTrue);
      expect(priorizarRecetasRapidas(lunesDeNoche), isTrue);
    });

    test('cubre los siete dias sin huecos', () {
      final rapidas = <int>[];
      final elaboradas = <int>[];

      // 2026-08-24 lunes .. 2026-08-30 domingo
      for (var dia = 24; dia <= 30; dia++) {
        final fecha = DateTime(2026, 8, dia);
        (priorizarRecetasRapidas(fecha) ? rapidas : elaboradas).add(
          fecha.weekday,
        );
      }

      expect(rapidas, hasLength(5));
      expect(elaboradas, hasLength(2));
    });
  });

  group('explicacionRitmo', () {
    test('el texto distingue el dia de semana del fin de semana', () {
      final lunes = DateTime(2026, 8, 24);
      final sabado = DateTime(2026, 8, 29);

      expect(explicacionRitmo(lunes), isNot(explicacionRitmo(sabado)));
      expect(explicacionRitmo(lunes), isNotEmpty);
      expect(explicacionRitmo(sabado), isNotEmpty);
    });
  });
}
