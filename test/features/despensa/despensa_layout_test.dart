import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/compartida/presentation/compartida_provider.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import 'package:lastbite/features/despensa/presentation/despensa_screen.dart';

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

Producto _producto({required String nombre, required int dias}) => Producto(
  id: nombre,
  nombre: nombre,
  emoji: '🥛',
  categoria: 'Leche',
  cantidad: '1 L',
  fechaCaducidad: DateTime.now().add(Duration(days: dias, hours: 1)),
  esFresco: false,
);

Future<void> _montar(
  WidgetTester tester, {
  required double ancho,
  List<Producto> productos = const [],
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
        despensaProvider.overrideWith(() => _DespensaFalsa(productos)),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const DespensaScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  final productos = [
    _producto(nombre: 'Leche', dias: 1),
    _producto(nombre: 'Arroz', dias: 40),
  ];

  testWidgets('en movil el encabezado va arriba', (tester) async {
    await _montar(tester, ancho: 400, productos: productos);

    expect(find.text('PRÓXIMOS A VENCER'), findsOneWidget);
    expect(find.text('EN BUEN ESTADO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('en web las cifras quedan en un rail a la izquierda', (
    tester,
  ) async {
    await _montar(tester, ancho: 1500, productos: productos);

    // El rail arranca pegado al borde izquierdo, no centrado.
    final rail = tester.getRect(find.text('PRODUCTOS'));
    expect(rail.left, lessThan(300));

    // Y las secciones de producto viven a su derecha.
    final seccion = tester.getRect(find.text('PRÓXIMOS A VENCER'));
    expect(seccion.left, greaterThan(260));
    expect(tester.takeException(), isNull);
  });

  testWidgets('el ahorro queda anclado al pie del rail', (tester) async {
    await _montar(tester, ancho: 1500, productos: productos);

    // Arriba la identidad y las cifras; el ahorro empujado al fondo, para que
    // el rail ocupe su alto en vez de amontonarse contra el borde superior.
    final cifra = tester.getRect(find.text('PRODUCTOS'));
    // Sin consumos todavia, la tarjeta muestra su texto de arranque.
    final ahorro = tester.getRect(
      find.textContaining('empezar a sumar').first,
    );
    expect(ahorro.top, greaterThan(cifra.bottom + 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desborda en ninguno de los tres anchos', (tester) async {
    for (final ancho in [360.0, 800.0, 1600.0]) {
      await _montar(tester, ancho: ancho, productos: productos);
      expect(tester.takeException(), isNull, reason: 'ancho $ancho');
    }
  });
}
