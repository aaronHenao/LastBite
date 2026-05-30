import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/features/auth/presentation/blocked_screen.dart';
import 'package:lastbite/features/auth/presentation/pending_screen.dart';
import 'package:lastbite/features/despensa/presentation/widgets/ui_states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {

  // TEST 1: Estado vacío
  testWidgets('TEST 1: Si no hay productos, se muestra el estado vacío',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EmptyDespensaState()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No tienes productos aún'), findsOneWidget);
  });

  // TEST 2: Estado de error
  
  testWidgets('TEST 2: Si hay error al cargar, se muestra mensaje de error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorDespensaState(mensaje: 'Error de conexión simulado'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Error al cargar los productos'), findsOneWidget);
    expect(find.text('Error de conexión simulado'), findsOneWidget);
  });

  // TEST 3: BlockedScreen
  
  testWidgets('TEST 3: Si status es blocked, se muestra BlockedScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: BlockedScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Acceso bloqueado'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });


  // TEST 4: PendingScreen
  
  testWidgets('TEST 4: Si status es pendingApproval, se muestra PendingScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PendingScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cuenta pendiente'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });


  // TEST 5: PendingSyncBadge

  testWidgets('TEST 5: PendingSyncBadge muestra el texto Pendiente',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: PendingSyncBadge())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pendiente'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_sync_rounded), findsOneWidget);
  });

  // TEST 6: OfflineBanner
    testWidgets('TEST 6: OfflineBanner muestra mensaje de sin conexión',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(children: [OfflineBanner()]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
  });
}
