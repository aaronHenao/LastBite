import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/l10n/app_localizations.dart';
import 'package:lastbite/core/preferencias/preferencias.dart';
import 'package:lastbite/core/preferencias/preferencias_provider.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/ajustes/presentation/ajustes_screen.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';

class _PreferenciasFalsas extends PreferenciasNotifier {
  _PreferenciasFalsas(this._iniciales);
  final Preferencias _iniciales;

  @override
  Stream<Preferencias> build() => Stream.value(_iniciales);
}

Future<void> _montar(
  WidgetTester tester, {
  Preferencias iniciales = const Preferencias(),
}) async {
  tester.view.physicalSize = const Size(500, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        firebaseUserProvider.overrideWith((ref) => Stream<User?>.value(null)),
        preferenciasProvider.overrideWith(() => _PreferenciasFalsas(iniciales)),
      ],
      child: MaterialApp(
        // Idioma fijo: las aserciones comparan textos concretos y el entorno

        // de pruebas arranca en ingles.
        locale: const Locale('es'),

        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        theme: iniciales.altoContraste
            ? AppTheme.lightContraste
            : AppTheme.light,
        home: const AjustesScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('ofrece los cuatro ajustes', (tester) async {
    await _montar(tester);

    expect(find.text('TAMAÑO DEL TEXTO'), findsOneWidget);
    expect(find.text('CONTRASTE'), findsOneWidget);
    expect(find.text('MOVIMIENTO'), findsOneWidget);
    expect(find.text('APARIENCIA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cumple las pautas de accesibilidad', (tester) async {
    final handle = tester.ensureSemantics();
    await _montar(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('el propio panel aguanta el texto al maximo', (tester) async {
    // Quien viene a agrandar la letra puede llegar con la letra ya agrandada.
    await _montar(tester, iniciales: const Preferencias(escalaTexto: 2.0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('en alto contraste sigue pasando el contraste', (tester) async {
    final handle = tester.ensureSemantics();
    await _montar(tester, iniciales: const Preferencias(altoContraste: true));

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  test('la paleta de alto contraste supera con holgura el minimo', () {
    double ratio(Color a, Color b) {
      final l = [a.computeLuminance(), b.computeLuminance()]..sort();
      return (l[1] + 0.05) / (l[0] + 0.05);
    }

    for (final paleta in [
      AppPaletasContraste.clara,
      AppPaletasContraste.oscura,
    ]) {
      for (final color in [
        paleta.tinta,
        paleta.apagado,
        paleta.marca,
        paleta.vencido,
        paleta.critico,
        paleta.urgente,
      ]) {
        expect(ratio(color, paleta.papel), greaterThan(9.0));
      }
    }
  });
}
