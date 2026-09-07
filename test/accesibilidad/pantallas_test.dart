import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/l10n/app_localizations.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/alertas/domain/alerta.dart';
import 'package:lastbite/features/alertas/presentation/alertas_provider.dart';
import 'package:lastbite/features/alertas/presentation/alertas_screen.dart';
import 'package:lastbite/features/agregar/presentation/agregar_screen.dart';
import 'package:lastbite/features/compartida/presentation/compartida_screen.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/compartida/presentation/compartida_provider.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import 'package:lastbite/features/despensa/presentation/despensa_screen.dart';
import 'package:lastbite/features/perfil/domain/item_compra.dart';
import 'package:lastbite/features/perfil/presentation/perfil_provider.dart';
import 'package:lastbite/features/perfil/presentation/perfil_screen.dart';

class _UsuarioFalso implements User {
  @override
  String get uid => 'u1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DespensaFalsa extends DespensaNotifier {
  _DespensaFalsa(this._productos);
  final List<Producto> _productos;

  @override
  Stream<List<Producto>> build() => Stream.value(_productos);
}

class _AlertasFalsas extends AlertasNotifier {
  _AlertasFalsas(this._alertas);
  final List<Alerta> _alertas;

  @override
  Future<List<Alerta>> build() async => _alertas;
}

class _ListaFalsa extends ListaComprasNotifier {
  _ListaFalsa(this._items);
  final List<ItemCompra> _items;

  @override
  Future<List<ItemCompra>> build() async => _items;
}

final _productos = [
  Producto(
    id: '1',
    nombre: 'Leche entera',
    emoji: '🥛',
    categoria: 'Leche',
    cantidad: '1 L',
    fechaCaducidad: DateTime.now().add(const Duration(days: 1, hours: 1)),
    esFresco: false,
  ),
];

final _compras = [
  ItemCompra(
    id: 'c1',
    nombre: 'Pan integral',
    emoji: '🍞',
    comprado: false,
    agregadoEn: DateTime(2026, 9, 1),
  ),
];

final _alertas = [
  Alerta(
    id: 'a1',
    productoId: '1',
    nombreProducto: 'Leche entera',
    emoji: '🥛',
    fechaCaducidad: DateTime.now().add(const Duration(days: 1, hours: 1)),
    tipo: AlertaTipo.aviso1,
    creadaEn: DateTime(2026, 9, 1),
  ),
];

Future<void> _montar(
  WidgetTester tester,
  Widget pantalla, {
  double ancho = 400,
  double escalaTexto = 1.0,
}) async {
  tester.view.physicalSize = Size(ancho, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        firebaseUserProvider.overrideWith(
          (ref) => Stream<User?>.value(_UsuarioFalso()),
        ),
        authStateProvider.overrideWith((ref) => const Stream.empty()),
        despensaCompartidaProvider.overrideWith((ref) => Stream.value(null)),
        despensaProvider.overrideWith(() => _DespensaFalsa(_productos)),
        listaComprasProvider.overrideWith(() => _ListaFalsa(_compras)),
        alertasProvider.overrideWith(() => _AlertasFalsas(_alertas)),
        productosPersonalesCountProvider.overrideWith((ref) async => 0),
      ],
      child: MaterialApp(
        // Idioma fijo: las aserciones comparan textos concretos y el entorno

        // de pruebas arranca en ingles.
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
        // Algunas pantallas no traen Scaffold propio porque viven dentro del
        // de MainShell: sin el, el fondo no se pinta y el verificador de
        // contraste mide contra la nada.
        home: Scaffold(body: pantalla),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('texto ampliado al doble', () {
    for (final caso in <String, Widget>{
      'despensa': const DespensaScreen(),
      'alertas': const AlertasScreen(),
      'perfil': const PerfilScreen(),
      'agregar': const AgregarScreen(),
      'despensa compartida': const DespensaCompartidaScreen(),
    }.entries) {
      testWidgets('${caso.key} no se rompe', (tester) async {
        await _montar(tester, caso.value, escalaTexto: 2.0);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('despensa', () {
    testWidgets('cumple las pautas de toque y de etiqueta', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const DespensaScreen());

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('cumple contraste de texto', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const DespensaScreen());

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('alertas', () {
    testWidgets('cumple las pautas de toque y de etiqueta', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const AlertasScreen());

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('descartar tiene boton, no solo el gesto de arrastre', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const AlertasScreen());

      // Quien usa lector de pantalla o un switch no puede arrastrar.
      expect(
        find.bySemanticsLabel('Descartar alerta de Leche entera'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('cumple contraste de texto', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const AlertasScreen());

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('agregar', () {
    testWidgets('cumple las pautas de toque y de etiqueta', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const AgregarScreen());

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('cumple contraste de texto', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const AgregarScreen());

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('despensa compartida', () {
    testWidgets('cumple las pautas de toque y de etiqueta', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const DespensaCompartidaScreen());

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('cumple contraste de texto', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const DespensaCompartidaScreen());

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('perfil', () {
    testWidgets('el check de la lista llega al minimo de toque', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const PerfilScreen());

      // Es la accion principal de la lista y medía 24px, la mitad del minimo.
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('el check se anuncia con su estado', (tester) async {
      final handle = tester.ensureSemantics();
      await _montar(tester, const PerfilScreen());

      expect(
        find.bySemanticsLabel('Marcar Pan integral como comprado'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
