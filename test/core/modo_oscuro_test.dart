import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/l10n/app_localizations.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/widgets/estado_vacio.dart';
import 'package:lastbite/core/widgets/pastilla_estado.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/widgets/producto_card.dart';

Producto _producto({required int dias}) => Producto(
  id: '1',
  nombre: 'Leche entera',
  emoji: '🥛',
  categoria: 'Leche',
  cantidad: '1 L',
  fechaCaducidad: DateTime.now().add(Duration(days: dias, hours: 1)),
  esFresco: false,
);

Future<void> _montar(WidgetTester tester, ThemeData tema) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      // Idioma fijo: las aserciones comparan textos concretos y el entorno

      // de pruebas arranca en ingles.
      locale: const Locale('es'),

      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      theme: tema,
      home: Scaffold(
        body: ListView(
          children: [
            ProductoCard(producto: _producto(dias: 1)),
            ProductoCard(producto: _producto(dias: 20)),
            const PastillaEstado(dias: 3),
            const EstadoVacio(
              icono: Icons.inbox_rounded,
              titulo: 'Nada por aquí',
              descripcion: 'Agregá algo para empezar.',
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('la app se pinta en los dos temas', () {
    testWidgets('claro', (tester) async {
      await _montar(tester, AppTheme.light);
      expect(tester.takeException(), isNull);
      expect(find.text('Mañana'), findsOneWidget);
    });

    testWidgets('oscuro', (tester) async {
      await _montar(tester, AppTheme.dark);
      expect(tester.takeException(), isNull);
      expect(find.text('Mañana'), findsOneWidget);
    });
  });

  test('cada tema trae su propia paleta', () {
    final clara = AppTheme.light.extension<AppPalette>();
    final oscura = AppTheme.dark.extension<AppPalette>();

    expect(clara, isNotNull);
    expect(oscura, isNotNull);
    expect(clara!.papel, isNot(oscura!.papel));
    expect(clara.tinta, isNot(oscura.tinta));
    // El fondo oscuro es realmente oscuro y el claro realmente claro.
    expect(clara.papel.computeLuminance(), greaterThan(0.8));
    expect(oscura.papel.computeLuminance(), lessThan(0.05));
  });

  test('la escala de urgencia existe en los dos temas', () {
    for (final paleta in [AppPalette.clara, AppPalette.oscura]) {
      expect(paleta.urgenciaPorDias(-1), isNotNull);
      expect(paleta.urgenciaPorDias(1), isNotNull);
      expect(paleta.urgenciaPorDias(3), isNotNull);
      expect(paleta.urgenciaPorDias(30), isNull);
      // Los tramos no se repiten entre si.
      final tramos = {
        paleta.urgenciaPorDias(-1),
        paleta.urgenciaPorDias(1),
        paleta.urgenciaPorDias(3),
      };
      expect(tramos.length, 3);
    }
  });
}
