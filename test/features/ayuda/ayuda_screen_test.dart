import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/widgets/boton_ayuda.dart';
import 'package:lastbite/features/ayuda/presentation/ayuda_screen.dart';
import 'package:lastbite/l10n/app_localizations.dart';

Future<void> _montar(
  WidgetTester tester,
  Widget pantalla, {
  double escalaTexto = 1.0,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(escalaTexto)),
        child: child!,
      ),
      home: pantalla,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el boton "?" abre la ayuda en la seccion de la pantalla', (
    tester,
  ) async {
    await _montar(
      tester,
      const Scaffold(body: BotonAyuda(seccion: SeccionAyuda.recetas)),
    );

    await tester.tap(find.byTooltip('Abrir ayuda'));
    await tester.pumpAndSettle();

    // Solo la seccion de recetas esta desplegada.
    expect(
      find.text('¿Qué significa el porcentaje de cada receta?'),
      findsOneWidget,
    );
    expect(find.text('¿Cómo marco que usé un producto?'), findsNothing);
  });

  testWidgets('muestra los primeros pasos y todas las secciones', (
    tester,
  ) async {
    await _montar(tester, const AyudaScreen());

    expect(find.text('PRIMEROS PASOS'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Búsqueda, cuenta y ajustes'),
      200,
    );
    expect(find.text('Búsqueda, cuenta y ajustes'), findsOneWidget);
  });

  testWidgets('no se rompe con el texto al doble', (tester) async {
    await _montar(
      tester,
      const AyudaScreen(seccion: SeccionAyuda.despensa),
      escalaTexto: 2.0,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('cumple las pautas de toque, etiqueta y contraste', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _montar(tester, const AyudaScreen(seccion: SeccionAyuda.recetas));

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
