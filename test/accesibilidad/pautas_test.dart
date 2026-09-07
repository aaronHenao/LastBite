import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/l10n/app_localizations.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/widgets/boton_volver.dart';
import 'package:lastbite/core/widgets/estado_error.dart';
import 'package:lastbite/core/widgets/estado_vacio.dart';
import 'package:lastbite/core/widgets/pastilla_estado.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/widgets/producto_card.dart';

Producto _producto({int dias = 1}) => Producto(
  id: '1',
  nombre: 'Leche entera deslactosada',
  emoji: '🥛',
  categoria: 'Leche',
  cantidad: '1 L',
  // La hora extra evita que el redondeo de inDays reste un dia; con fechas
  // ya vencidas hay que correrla al otro lado.
  fechaCaducidad: DateTime.now().add(
    Duration(days: dias, hours: dias < 0 ? -1 : 1),
  ),
  esFresco: false,
);

Future<void> _montar(
  WidgetTester tester,
  Widget hijo, {
  ThemeData? tema,
  double escalaTexto = 1.0,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      // Idioma fijo: las aserciones comparan textos concretos y el entorno

      // de pruebas arranca en ingles.
      locale: const Locale('es'),

      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      theme: tema ?? AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(escalaTexto)),
        child: Scaffold(body: ListView(children: [hijo])),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('lector de pantalla', () {
    testWidgets('la tarjeta se anuncia como una frase util', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, ProductoCard(producto: _producto()));

      // Antes el lector deletreaba el emoji y leia "1 L · Leche" suelto.
      expect(
        find.bySemanticsLabel(
          'Leche entera deslactosada, 1 L, Leche, vence mañana',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('un producto vencido dice hace cuanto', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, ProductoCard(producto: _producto(dias: -3)));

      expect(
        find.bySemanticsLabel(RegExp('vencido hace 3 días')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('movimiento reducido', () {
    testWidgets('las animaciones se apagan si el sistema lo pide', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) => Scaffold(
                body: Text(
                  '${AppMotion.duracion(context, AppMotion.mueve).inMilliseconds}',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });
  });

  group('zonas de toque', () {
    testWidgets('cumplen el minimo de Android', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const BotonVolver());
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('cumplen el minimo de iOS', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const BotonVolver());
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('lo que se toca tiene etiqueta', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(
        tester,
        Column(
          children: [
            const BotonVolver(),
            EstadoVacio(
              icono: Icons.inbox_rounded,
              titulo: 'Vacío',
              descripcion: 'Nada por aquí.',
              textoAccion: 'Agregar',
              onAccion: () {},
            ),
            EstadoError(mensaje: 'Falló', onReintentar: () {}),
          ],
        ),
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });

  group('contraste de texto', () {
    testWidgets('en tema claro', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, ProductoCard(producto: _producto()));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('en tema oscuro', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(
        tester,
        ProductoCard(producto: _producto()),
        tema: AppTheme.dark,
      );
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('texto ampliado', () {
    testWidgets('la tarjeta de producto aguanta el doble de tamano', (
      tester,
    ) async {
      // Quien necesita texto grande no deberia encontrarse la pantalla rota.
      await _montar(
        tester,
        ProductoCard(producto: _producto()),
        escalaTexto: 2.0,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('la pastilla de estado aguanta el doble', (tester) async {
      await _montar(tester, const PastillaEstado(dias: 1), escalaTexto: 2.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el estado vacio aguanta el doble', (tester) async {
      await _montar(
        tester,
        const EstadoVacio(
          icono: Icons.inbox_rounded,
          titulo: 'Tu despensa está vacía',
          descripcion: 'Agregá lo que tengas en casa.',
        ),
        escalaTexto: 2.0,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
