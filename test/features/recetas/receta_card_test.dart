import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    // Dos etiquetas visibles; lo que no entra se resume en un contador.
    expect(find.text('arroz'), findsOneWidget);
    expect(find.textContaining('más'), findsOneWidget);
    expect(find.text('tripas de salchichas'), findsNothing);
  });
}
