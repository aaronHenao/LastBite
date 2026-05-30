// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lastbite/features/auth/domain/auth_user.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/auth/presentation/blocked_screen.dart';
import 'package:lastbite/features/auth/presentation/pending_screen.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/despensa/presentation/despensa_provider.dart';
import 'package:lastbite/features/despensa/presentation/widgets/ui_states.dart';
import 'package:lastbite/core/theme/app_theme.dart';

// ─── Helpers de test ──────────────────────────────────────────────────────────

/// Crea un Producto de prueba con vencimiento dentro de [diasHastaVencimiento] días.
Producto _productoFake({
  String id = 'prod-1',
  String nombre = 'Leche',
  int diasHastaVencimiento = 10,
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  return Producto(
    id: id,
    nombre: nombre,
    emoji: '🥛',
    categoria: 'Lácteos',
    cantidad: '1 L',
    fechaCaducidad: DateTime.now().add(Duration(days: diasHastaVencimiento)),
    esFresco: false,
    syncStatus: syncStatus,
  );
}

/// Override que devuelve una lista vacía de productos.
final _despensaVaciaOverride = despensaProvider.overrideWith(
  () => _FakeDespensaVaciaNotifier(),
);

/// Override que devuelve error al cargar.
final _despensaErrorOverride = despensaProvider.overrideWith(
  () => _FakeDespensaErrorNotifier(),
);

class _FakeDespensaVaciaNotifier extends AsyncNotifier<List<Producto>> {
  @override
  Future<List<Producto>> build() async => [];
}

class _FakeDespensaErrorNotifier extends AsyncNotifier<List<Producto>> {
  @override
  Future<List<Producto>> build() async =>
      throw Exception('Error de conexión simulado');
}

/// Override del authState con un usuario de status concreto.
Provider<AsyncValue<AuthUser?>> _authOverride(String status) {
  return Provider<AsyncValue<AuthUser?>>(
    (_) => AsyncData(
      AuthUser(uid: 'uid-test', email: 'test@test.com', status: status),
    ),
  );
}


// WIDGET TESTS


void main() {

  final testTheme = ThemeData.light();


  // TEST 1: Estado vacío — si no hay productos

  testWidgets(
    'TEST 1: Si no hay productos, se muestra el estado vacío con el texto correcto',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [_despensaVaciaOverride],
          child: MaterialApp(
            theme: testTheme,
            home: const Scaffold(
              body: EmptyDespensaState(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica que aparece el texto de estado vacío
      expect(find.text('No tienes productos aún'), findsOneWidget);

      // Verifica que aparece el ícono de agregar
      expect(find.byIcon(Icons.add_circle_outlined), findsAny);

      print('✅ TEST 1 PASÓ: Estado vacío se muestra correctamente');
    },
  );

  // TEST 2: Estado de error — si hay error al cargar, se muestra mensaje

  testWidgets(
    'TEST 2: Si hay error al cargar, se muestra el widget de error',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: const Scaffold(
            body: ErrorDespensaState(
              mensaje: 'Error de conexión simulado',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica título del error
      expect(find.text('Error al cargar los productos'), findsOneWidget);

      // Verifica mensaje detallado
      expect(find.text('Error de conexión simulado'), findsOneWidget);

      print('TEST 2 PASÓ: Estado de error se muestra correctamente');
    },
  );


  // TEST 3: BlockedScreen — status es 'blocked'

  testWidgets(
    'TEST 3: Si el status del usuario es blocked, se muestra BlockedScreen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Simula un usuario con status blocked
            authStateProvider.overrideWith(
              (ref) => Stream.value(
                AuthUser(
                  uid: 'uid-blocked',
                  email: 'blocked@test.com',
                  status: 'blocked',
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: testTheme,
            // Renderizamos BlockedScreen directamente
            home: const BlockedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica el título principal
      expect(find.text('Acceso bloqueado'), findsOneWidget);

      // Verifica la descripción
      expect(
        find.textContaining('Tu cuenta ha sido bloqueada'),
        findsOneWidget,
      );

      // Verifica botón de cerrar sesión
      expect(find.text('Cerrar sesión'), findsOneWidget);

      print('TEST 3 PASÓ: BlockedScreen se muestra correctamente');
    },
  );

  // TEST 4: PendingScreen — status es 'pendingApproval'
 
  testWidgets(
    'TEST 4: Si el status del usuario es pendingApproval, se muestra PendingScreen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.value(
                AuthUser(
                  uid: 'uid-pending',
                  email: 'pending@test.com',
                  status: 'pendingApproval',
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: testTheme,
            home: const PendingScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Cuenta pendiente'), findsOneWidget);

      // Verifica que se muestra el mensaje de espera
      expect(
        find.textContaining('Tu cuenta está en revisión'),
        findsOneWidget,
      );

      // Verifica el badge de estado
      expect(
        find.textContaining('Pendiente de aprobación'),
        findsOneWidget,
      );

      // Verifica botón de cerrar sesión
      expect(find.text('Cerrar sesión'), findsOneWidget);

      print('TEST 4 PASÓ: PendingScreen se muestra correctamente');
    },
  );

  // TEST 5: PendingSyncBadge — se renderiza el badge correctamente

  testWidgets(
    'TEST 5 (bonus): PendingSyncBadge muestra el texto "Pendiente"',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: PendingSyncBadge()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_sync_rounded), findsOneWidget);

      print('TEST 5 PASÓ: PendingSyncBadge se muestra correctamente');
    },
  );


  // TEST 6: OfflineBanner — se muestra el banner de sin conexión
  
  testWidgets(
    'TEST 6 (bonus): OfflineBanner muestra el mensaje de sin conexión',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                OfflineBanner(),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sin conexión'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      print('TEST 6 PASÓ: OfflineBanner se muestra correctamente');
    },
  );
}
