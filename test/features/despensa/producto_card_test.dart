import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/l10n/app_localizations.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/widgets/producto_card.dart';

Producto _con({required int dias}) => Producto(
  id: '1',
  nombre: 'Yogur griego natural con frutos rojos',
  emoji: '🥣',
  categoria: 'Yogur',
  cantidad: '500 g',
  fechaCaducidad: DateTime.now().add(Duration(days: dias, hours: 1)),
  esFresco: false,
);

Future<void> _montar(
  WidgetTester tester, {
  required int dias,
  required double ancho,
}) async {
  tester.view.physicalSize = Size(ancho, 400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      // Idioma fijo: las aserciones comparan textos concretos y el entorno

      // de pruebas arranca en ingles.
      locale: const Locale('es'),

      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      theme: AppTheme.light,
      home: Scaffold(
        body: ListView(
          children: [ProductoCard(producto: _con(dias: dias))],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('la insignia solo aparece cuando el producto reclama atencion', () {
    testWidgets('un producto en buen estado no lleva pastilla', (tester) async {
      await _montar(tester, dias: 20, ancho: 400);

      expect(find.text('20d'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsNothing);
      // Sin color de estado: la tarjeta se ve tranquila.
      expect(AppTheme.colorUrgencia(20), isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('un producto vencido lo dice con palabras, no solo con color', (
      tester,
    ) async {
      await _montar(tester, dias: -3, ancho: 400);

      // Antes mostraba "-3d", que no significa nada para quien usa la app.
      expect(find.text('¡Vencido!'), findsOneWidget);
      expect(find.text('-3d'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el de mañana se distingue del de la semana', (tester) async {
      await _montar(tester, dias: 1, ancho: 400);
      expect(find.text('Mañana'), findsOneWidget);

      expect(AppTheme.colorUrgencia(1), isNot(AppTheme.colorUrgencia(3)));
      expect(AppTheme.colorUrgencia(3), isNot(AppTheme.colorUrgencia(7)));
      expect(AppTheme.colorUrgencia(-1), isNot(AppTheme.colorUrgencia(1)));
      expect(tester.takeException(), isNull);
    });
  });

  group('no desborda', () {
    testWidgets('con nombre largo en pantalla angosta', (tester) async {
      await _montar(tester, dias: 0, ancho: 320);
      expect(tester.takeException(), isNull);
    });

    testWidgets('en ancho de web', (tester) async {
      await _montar(tester, dias: 5, ancho: 1400);
      expect(tester.takeException(), isNull);
    });
  });
}
