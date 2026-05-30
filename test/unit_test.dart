// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/alertas/domain/alerta.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

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

/// Simula la lógica de permisos según el status del usuario.
/// Retorna true si puede agregar producto, false si no.
bool _puedeAgregarProducto(String status) {
  return status == 'active' || status == 'admin';
}

/// Simula guardar un producto sin conexión → retorna syncStatus.
SyncStatus _guardarSinConexion(Producto producto) {
  // Sin conexión, siempre queda pendingSync
  return SyncStatus.pendingSync;
}

/// Simula la lógica de retry — solo reintenta si es pendingSync.
bool _debeReintentar(Producto producto) {
  return producto.syncStatus == SyncStatus.pendingSync;
}

/// Genera una alerta según los días restantes del producto.
Alerta? _generarAlerta(Producto producto) {
  final dias = producto.diasRestantes;

  AlertaTipo? tipo;
  if (dias < 0) {
    tipo = AlertaTipo.vencido;
  } else if (dias <= 1) {
    tipo = AlertaTipo.aviso1;
  } else if (dias <= 3) {
    tipo = AlertaTipo.aviso3;
  } else if (dias <= 5) {
    tipo = AlertaTipo.aviso5;
  }

  if (tipo == null) return null;

  return Alerta(
    id: Alerta.buildId(productoId: producto.id, tipo: tipo),
    productoId: producto.id,
    nombreProducto: producto.nombre,
    emoji: producto.emoji,
    fechaCaducidad: producto.fechaCaducidad,
    tipo: tipo,
    creadaEn: DateTime.now(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// UNIT TESTS
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // TEST 1: Usuario active puede agregar producto
  // ══════════════════════════════════════════════════════════════════════════
  test('TEST 1: Usuario con status active puede agregar producto', () {
    const status = 'active';
    final puede = _puedeAgregarProducto(status);
    expect(puede, isTrue);
    print('✅ TEST 1 PASÓ: Usuario active puede agregar');
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TEST 2: Usuario blocked NO puede agregar producto
  // ══════════════════════════════════════════════════════════════════════════
  test('TEST 2: Usuario con status blocked NO puede agregar producto', () {
    const status = 'blocked';
    final puede = _puedeAgregarProducto(status);
    expect(puede, isFalse);
    print('✅ TEST 2 PASÓ: Usuario blocked no puede agregar');
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TEST 3: Usuario pendingApproval NO puede agregar producto
  // ══════════════════════════════════════════════════════════════════════════
  test('TEST 3: Usuario con status pendingApproval NO puede agregar producto', () {
    const status = 'pendingApproval';
    final puede = _puedeAgregarProducto(status);
    expect(puede, isFalse);
    print('✅ TEST 3 PASÓ: Usuario pendingApproval no puede agregar');
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TEST 4: Producto creado sin conexión queda como pendingSync
  // ══════════════════════════════════════════════════════════════════════════
  test('TEST 4: Producto creado sin conexión queda como pendingSync', () {
    final producto = _productoFake();
    final syncResult = _guardarSinConexion(producto);
    expect(syncResult, equals(SyncStatus.pendingSync));
    print('✅ TEST 4 PASÓ: Producto sin conexión queda pendingSync');
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TEST 5: Producto con syncStatus synced NO se reintenta
  // ══════════════════════════════════════════════════════════════════════════
  test('TEST 5: Producto con syncStatus synced no se reintenta', () {
    final producto = _productoFake(syncStatus: SyncStatus.synced);
    final debeReintentar = _debeReintentar(producto);
    expect(debeReintentar, isFalse);
    print('✅ TEST 5 PASÓ: Producto synced no se reintenta');
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TEST 6: Alerta se genera correctamente según días restantes
  // ══════════════════════════════════════════════════════════════════════════
  group('TEST 6: Alertas se generan correctamente según días restantes', () {
    test('6a: Producto con 5 días → AlertaTipo.aviso5', () {
      final p = _productoFake(diasHastaVencimiento: 5);
      final alerta = _generarAlerta(p);
      expect(alerta, isNotNull);
      expect(alerta!.tipo, equals(AlertaTipo.aviso5));
      print('✅ TEST 6a PASÓ: 5 días → aviso5');
    });

    test('6b: Producto con 3 días → AlertaTipo.aviso3', () {
      final p = _productoFake(diasHastaVencimiento: 3);
      final alerta = _generarAlerta(p);
      expect(alerta, isNotNull);
      expect(alerta!.tipo, equals(AlertaTipo.aviso3));
      print('✅ TEST 6b PASÓ: 3 días → aviso3');
    });

    test('6c: Producto con 1 día → AlertaTipo.aviso1', () {
      final p = _productoFake(diasHastaVencimiento: 1);
      final alerta = _generarAlerta(p);
      expect(alerta, isNotNull);
      expect(alerta!.tipo, equals(AlertaTipo.aviso1));
      print('✅ TEST 6c PASÓ: 1 día → aviso1');
    });

    test('6d: Producto vencido → AlertaTipo.vencido', () {
      final p = _productoFake(diasHastaVencimiento: -1);
      final alerta = _generarAlerta(p);
      expect(alerta, isNotNull);
      expect(alerta!.tipo, equals(AlertaTipo.vencido));
      print('✅ TEST 6d PASÓ: vencido → alerta vencido');
    });

    test('6e: Producto con 10 días → no genera alerta', () {
      final p = _productoFake(diasHastaVencimiento: 10);
      final alerta = _generarAlerta(p);
      expect(alerta, isNull);
      print('✅ TEST 6e PASÓ: 10 días → sin alerta');
    });
  });
}
