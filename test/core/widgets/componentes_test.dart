import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/widgets/boton_volver.dart';
import 'package:lastbite/core/widgets/estado_error.dart';
import 'package:lastbite/core/widgets/estado_vacio.dart';
import 'package:lastbite/core/widgets/pastilla_estado.dart';

Future<void> _montar(
  WidgetTester tester,
  Widget hijo, {
  double ancho = 400,
}) async {
  tester.view.physicalSize = Size(ancho, 700);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: ListView(children: [hijo])),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PastillaEstado', () {
    testWidgets('sin urgencia no dibuja pastilla, solo la fecha', (
      tester,
    ) async {
      await _montar(tester, const PastillaEstado(dias: 30));

      expect(find.text('30d'), findsOneWidget);
      expect(find.byType(Container), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cada tramo dice su estado con palabras', (tester) async {
      for (final caso in {-2: '¡Vencido!', 0: 'Hoy', 1: 'Mañana', 5: '5d'}.entries) {
        await _montar(tester, PastillaEstado(dias: caso.key));
        expect(find.text(caso.value), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('BotonVolver', () {
    testWidgets('cumple el minimo de 44x44', (tester) async {
      await _montar(tester, const BotonVolver());

      final alto = tester.getSize(find.byType(InkWell).first).height;
      expect(alto, greaterThanOrEqualTo(44));
      expect(tester.takeException(), isNull);
    });

    testWidgets('vuelve al tocarlo', (tester) async {
      var toques = 0;
      await _montar(tester, BotonVolver(onTap: () => toques++));

      // El Align deja el boton pegado a la izquierda: el centro del widget
      // cae fuera de su zona tocable, que es justo lo que se busca.
      await tester.tap(find.text('Volver'));
      expect(toques, 1);
    });
  });

  group('EstadoVacio', () {
    testWidgets('muestra el siguiente paso, no solo que esta vacio', (
      tester,
    ) async {
      var pulsado = false;
      await _montar(
        tester,
        EstadoVacio(
          icono: Icons.inbox_rounded,
          titulo: 'Todavía no hay nada',
          descripcion: 'Agregá tu primer producto para empezar.',
          textoAccion: 'Agregar producto',
          onAccion: () => pulsado = true,
        ),
      );

      expect(find.text('Agregar producto'), findsOneWidget);
      await tester.tap(find.text('Agregar producto'));
      expect(pulsado, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('EstadoError', () {
    testWidgets('el mensaje es para personas y el detalle queda plegado', (
      tester,
    ) async {
      await _montar(
        tester,
        EstadoError(
          mensaje: 'No pudimos cargar tus alertas.',
          detalle: Exception('[cloud_firestore/permission-denied]'),
          onReintentar: () {},
        ),
      );

      expect(find.text('No pudimos cargar tus alertas.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      // El texto tecnico existe pero no se muestra hasta desplegarlo.
      expect(
        find.textContaining('permission-denied'),
        findsNothing,
      );

      await tester.tap(find.text('Detalle técnico'));
      await tester.pumpAndSettle();
      expect(find.textContaining('permission-denied'), findsOneWidget);
    });
  });

  testWidgets('los componentes no desbordan en ancho de web', (tester) async {
    await _montar(
      tester,
      const Column(
        children: [
          BotonVolver(),
          PastillaEstado(dias: 1),
          EstadoVacio(
            icono: Icons.inbox_rounded,
            titulo: 'Vacío',
            descripcion: 'Nada por aquí.',
          ),
        ],
      ),
      ancho: 1400,
    );
    expect(tester.takeException(), isNull);
  });
}
