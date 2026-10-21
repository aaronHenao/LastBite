import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/l10n/app_localizations.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';
import 'package:lastbite/features/recetas/presentation/widgets/receta_card.dart';

Receta _receta() => Receta(
  id: 1,
  titulo: 'Boudin con arroz criollo y guarnición de verduras salteadas',
  imagenUrl: '',
  ingredientesUsados: 3,
  ingredientesFaltantes: 4,
  likes: 0,
  minutosPreparacion: 45,
  ingredientes: const [
    'arroz',
    'carne de cerdo',
    'hígado de cerdo',
    'tripas de salchichas',
  ],
);

Future<void> _montarEnCelda(WidgetTester tester, double ancho) async {
  tester.view.physicalSize = Size(ancho, 900);
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
        body: GridView(
          // Misma celda que usa la pantalla de recetas.
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 420,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 268,
          ),
          children: [RecetaCard(receta: _receta(), onTap: () {})],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la tarjeta no desborda su celda con muchos ingredientes', (
    tester,
  ) async {
    // Con titulo largo y cuatro ingredientes, las etiquetas se iban a dos
    // filas y la tarjeta desbordaba 30 pixeles.
    for (final ancho in [700.0, 1100.0, 1600.0]) {
      await _montarEnCelda(tester, ancho);
      expect(tester.takeException(), isNull, reason: 'ancho $ancho');
    }
  });

  testWidgets('resume los ingredientes que no entran', (tester) async {
    await _montarEnCelda(tester, 1100);

    // Dos etiquetas visibles; lo que se tiene y no entra se resume en un
    // contador, y lo que falta va aparte: no se mezclan.
    expect(find.text('arroz'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
    expect(find.text('Faltan 4'), findsOneWidget);
    expect(find.text('tripas de salchichas'), findsNothing);
  });

  group('detalle', () {
    Future<void> montarDetalle(WidgetTester tester, Receta receta) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          theme: AppTheme.light,
          home: Scaffold(
            body: RecetaDetalleSheet(
              receta: receta,
              productosEnDespensa: const {'pechuga de pollo', 'limón'},
              isDialog: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    final receta = Receta(
      id: 2,
      titulo: 'Pollo al limón',
      imagenUrl: '',
      ingredientesUsados: 3,
      ingredientesFaltantes: 1,
      likes: 0,
      ingredientes: const [
        'Pollo (300 g)',
        'Jugo de limon (2 cucharadas)',
        'Sal',
        'Crema de leche con un nombre larguísimo que no entra en una sola '
            'línea de la pantalla (100 ml)',
      ],
      instrucciones: 'Corta el pollo.\nSofríe con limón.\nAgrega la crema.',
    );

    testWidgets('marca cada ingrediente con la misma regla que el match', (
      tester,
    ) async {
      // Una receta "75 %" mostraba la sal como "Falta" y no reconocia el
      // limon sin tilde: el porcentaje y las marcas no cuadraban.
      await montarDetalle(tester, receta);

      expect(find.text('✓ Tienes'), findsNWidgets(2));
      expect(find.text('Básico'), findsOneWidget);
      expect(find.text('Falta'), findsOneWidget);
      expect(find.text('Tienes 3 de 4 ingredientes'), findsOneWidget);
      expect(find.text('75% match'), findsOneWidget);
      expect(find.textContaining('se asume que los tienes'), findsOneWidget);
    });

    testWidgets('la preparacion va en pasos numerados y nada desborda', (
      tester,
    ) async {
      await montarDetalle(tester, receta);

      expect(tester.takeException(), isNull);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Agrega la crema.'), findsOneWidget);
    });
  });
}
