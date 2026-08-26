import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/compartida/presentation/compartida_provider.dart';
import 'package:lastbite/features/compartida/domain/despensa_compartida.dart';
import 'package:lastbite/features/compartida/presentation/compartida_screen.dart';

/// El uid es lo unico que la pantalla usa del usuario de Firebase.
class _UsuarioFalso implements User {
  _UsuarioFalso(this.uid);

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DespensaCompartida _despensa() => DespensaCompartida(
  id: 'd1',
  nombre: 'Casa Calad',
  codigo: 'ABC234',
  adminUid: 'admin-1',
  creadaEn: DateTime(2026, 1, 1),
  miembros: [
    MiembroDespensa(
      uid: 'admin-1',
      nombre: 'Emmanuel',
      email: 'emmanuel@example.com',
      unidoEn: DateTime(2026, 1, 1),
    ),
    MiembroDespensa(
      uid: 'miembro-2',
      nombre: 'Aaron',
      email: 'aaron@example.com',
      unidoEn: DateTime(2026, 1, 2),
    ),
  ],
);

Future<void> _montarConDespensa(
  WidgetTester tester, {
  required double ancho,
  required String uid,
}) async {
  tester.view.physicalSize = Size(ancho, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        firebaseUserProvider.overrideWith(
          (ref) => Stream<User?>.value(_UsuarioFalso(uid)),
        ),
        despensaCompartidaProvider.overrideWith(
          (ref) => Stream.value(_despensa()),
        ),
        productosPersonalesCountProvider.overrideWith((ref) async => 0),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const DespensaCompartidaScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _montar(WidgetTester tester, {required double ancho}) async {
  tester.view.physicalSize = Size(ancho, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        firebaseUserProvider.overrideWith((ref) => Stream<User?>.value(null)),
        despensaCompartidaProvider.overrideWith((ref) => Stream.value(null)),
        productosPersonalesCountProvider.overrideWith((ref) async => 0),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const DespensaCompartidaScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin despensa muestra las dos acciones en movil', (tester) async {
    await _montar(tester, ancho: 400);

    expect(find.text('Crear despensa'), findsOneWidget);
    expect(find.text('Unirme con código'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sin despensa tambien renderiza en web sin desbordarse', (
    tester,
  ) async {
    await _montar(tester, ancho: 1400);

    expect(find.text('Crear despensa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el admin ve el codigo, los miembros y el boton de eliminar', (
    tester,
  ) async {
    await _montarConDespensa(tester, ancho: 400, uid: 'admin-1');

    expect(find.text('ABC234'), findsOneWidget);
    expect(find.text('MIEMBROS (2)'), findsOneWidget);
    expect(find.text('Emmanuel (tú)'), findsOneWidget);
    expect(find.text('Aaron'), findsOneWidget);
    expect(find.text('Eliminar despensa'), findsOneWidget);
    expect(find.text('Salir de la despensa'), findsNothing);
    // Solo puede expulsar al otro miembro, no a si mismo.
    expect(find.byTooltip('Eliminar miembro'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('un miembro no admin no puede expulsar y solo puede salir', (
    tester,
  ) async {
    await _montarConDespensa(tester, ancho: 400, uid: 'miembro-2');

    expect(find.text('Salir de la despensa'), findsOneWidget);
    expect(find.text('Eliminar despensa'), findsNothing);
    expect(find.byTooltip('Eliminar miembro'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('con despensa tambien renderiza en web sin desbordarse', (
    tester,
  ) async {
    await _montarConDespensa(tester, ancho: 1400, uid: 'admin-1');

    expect(find.text('ABC234'), findsOneWidget);
    expect(find.text('Aaron'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
