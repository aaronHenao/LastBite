import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/l10n/app_localizations.dart';
import 'package:lastbite/l10n/traducciones.dart';

Map<String, dynamic> _leerArb(String idioma) =>
    jsonDecode(File('lib/l10n/app_$idioma.arb').readAsStringSync())
        as Map<String, dynamic>;

Future<void> _montar(WidgetTester tester, Locale idioma) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: idioma,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              Text(context.t.navDespensa),
              Text(context.t.despensaVaciaTitulo),
              Text(context.t.lectorVencidoHace(3)),
              Text(context.t.lectorVencidoHace(1)),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('los tres idiomas traducen exactamente las mismas claves', () {
    final base = _leerArb('es').keys.where((k) => !k.startsWith('@')).toSet();

    for (final idioma in ['en', 'pt']) {
      final otro = _leerArb(idioma).keys.where((k) => !k.startsWith('@'));
      expect(
        otro.toSet(),
        base,
        reason: 'app_$idioma.arb no coincide con el español',
      );
    }
  });

  test('los textos largos estan traducidos de verdad', () {
    // Comparar "ningun texto coincide" no sirve entre español y portugues,
    // que comparten muchas palabras. Se revisan claves donde los tres idiomas
    // tienen que diferir por fuerza.
    const debenDiferir = [
      'despensaVaciaTitulo',
      'despensaVaciaDescripcion',
      'ajustesDescripcion',
      'ajustesLectorAyuda',
      'alertasVaciasDescripcion',
      'cuentaCerrarSesion',
      'estadoManana',
    ];

    final es = _leerArb('es');
    final en = _leerArb('en');
    final pt = _leerArb('pt');

    for (final clave in debenDiferir) {
      expect({es[clave], en[clave], pt[clave]}.length, 3, reason: clave);
    }
  });

  testWidgets('la app cambia de idioma de verdad', (tester) async {
    await _montar(tester, const Locale('es'));
    expect(find.text('Despensa'), findsOneWidget);
    expect(find.text('Tu despensa está vacía'), findsOneWidget);

    await _montar(tester, const Locale('en'));
    expect(find.text('Pantry'), findsOneWidget);
    expect(find.text('Your pantry is empty'), findsOneWidget);

    await _montar(tester, const Locale('pt'));
    expect(find.text('Sua despensa está vazia'), findsOneWidget);
  });

  testWidgets('el plural funciona en cada idioma', (tester) async {
    await _montar(tester, const Locale('es'));
    expect(find.text('vencido hace 3 días'), findsOneWidget);
    expect(find.text('vencido hace 1 día'), findsOneWidget);

    await _montar(tester, const Locale('en'));
    expect(find.text('expired 3 days ago'), findsOneWidget);
    expect(find.text('expired 1 day ago'), findsOneWidget);
  });
}
