// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/features/auth/domain/auth_user.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';
import 'package:lastbite/features/alertas/domain/alerta.dart';
import 'package:lastbite/core/services/permission_service.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

AuthUser _usuario({
  String status = 'active',
  UserRole role = UserRole.active,
}) {
  return AuthUser(
    uid: 'test-uid',
    email: 'test@test.com',
    status: status,
    role: role,
  );
}

Producto _producto({
  int diasHastaVencimiento = 10,
  SyncStatus syncStatus = SyncStatus.synced,
}) {
  return Producto(
    id: 'prod-1',
    nombre: 'Leche',
    emoji: '🥛',
    categoria: 'Lácteos',
    cantidad: '1 L',
    fechaCaducidad: DateTime.now().add(Duration(days: diasHastaVencimiento)),
    esFresco: false,
    syncStatus: syncStatus,
  );
}

Alerta? _generarAlerta(Producto producto) {
  final dias = producto.diasRestantes;
  AlertaTipo? tipo;
  if (dias < 0) tipo = AlertaTipo.vencido;
  else if (dias <= 1) tipo = AlertaTipo.aviso1;
  else if (dias <= 3) tipo = AlertaTipo.aviso3;
  else if (dias <= 5) tipo = AlertaTipo.aviso5;
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

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  final permisos = PermissionService();


  // TEST 1: Usuario active puede agregar producto
 
  test('TEST 1: Usuario active puede agregar producto', () {
    final user = _usuario(status: 'active', role: UserRole.active);
    expect(permisos.puedeAgregarProducto(user), isTrue);
    print('TEST 1 PASÓ: Usuario active puede agregar');
  });


  // TEST 2: Usuario blocked no puede agregar producto

  test('TEST 2: Usuario blocked NO puede agregar producto', () {
    final user = _usuario(status: 'blocked', role: UserRole.active);
    expect(permisos.puedeAgregarProducto(user), isFalse);
    print('TEST 2 PASÓ: Usuario blocked no puede agregar');
  });


  // TEST 3: Usuario pendingApproval no puede agregar producto

  test('TEST 3: Usuario pendingApproval NO puede agregar producto', () {
    final user = _usuario(status: 'pendingApproval', role: UserRole.active);
    expect(permisos.puedeAgregarProducto(user), isFalse);
    print('TEST 3 PASÓ: Usuario pendingApproval no puede agregar');
  });

  // TEST 4: Producto creado sin conexión queda como pendingSync
  
  test('TEST 4: Producto sin conexión queda como pendingSync', () {
    final producto = _producto(syncStatus: SyncStatus.pendingSync);
    expect(producto.syncStatus, equals(SyncStatus.pendingSync));
    expect(producto.isPendingSync, isTrue);
    print('TEST 4 PASÓ: Producto sin conexión es pendingSync');
  });

  // TEST 5: Producto synced no se reintenta
  
  test('TEST 5: Producto synced no necesita reintento', () {
    final producto = _producto(syncStatus: SyncStatus.synced);
    expect(producto.isPendingSync, isFalse);
    print('TEST 5 PASÓ: Producto synced no se reintenta');
  });


  // TEST 6: Alerta se genera correctamente según días restantes
  
  group('TEST 6: Alertas según días restantes', () {
    test('6a: 5 días → aviso5', () {
      final alerta = _generarAlerta(_producto(diasHastaVencimiento: 5));
      expect(alerta?.tipo, equals(AlertaTipo.aviso5));
      print('TEST 6a PASÓ');
    });
    test('6b: 3 días → aviso3', () {
      final alerta = _generarAlerta(_producto(diasHastaVencimiento: 3));
      expect(alerta?.tipo, equals(AlertaTipo.aviso3));
      print('TEST 6b PASÓ');
    });
    test('6c: 1 día → aviso1', () {
      final alerta = _generarAlerta(_producto(diasHastaVencimiento: 1));
      expect(alerta?.tipo, equals(AlertaTipo.aviso1));
      print('TEST 6c PASÓ');
    });
    test('6d: vencido → alerta vencido', () {
      final alerta = _generarAlerta(_producto(diasHastaVencimiento: -1));
      expect(alerta?.tipo, equals(AlertaTipo.vencido));
      print('TEST 6d PASÓ');
    });
    test('6e: 10 días → sin alerta', () {
      final alerta = _generarAlerta(_producto(diasHastaVencimiento: 10));
      expect(alerta, isNull);
      print('TEST 6e PASÓ');
    });
  });


  // TEST 7: Viewer no puede agregar producto

  test('TEST 7: Usuario viewer NO puede agregar producto', () {
    final user = _usuario(status: 'active', role: UserRole.viewer);
    expect(permisos.puedeAgregarProducto(user), isFalse);
    print('TEST 7 PASÓ: Viewer no puede agregar');
  });

  // TEST 8: Admin puede eliminar cualquier producto
  test('TEST 8: Admin puede eliminar cualquier producto', () {
    final user = _usuario(status: 'active', role: UserRole.admin);
    expect(permisos.puedeEliminarCualquierProducto(user), isTrue);
    print('TEST 8 PASÓ: Admin puede eliminar cualquier producto');
  });


  // TEST 9: Producto vencido debe eliminarse, no consumirse
 
  test('TEST 9: Producto vencido debe eliminarse no consumirse', () {
    final producto = _producto(diasHastaVencimiento: -1);
    expect(permisos.debeEliminarseEnVezDeConsumir(producto), isTrue);
    print('TEST 9 PASÓ: Producto vencido debe eliminarse');
  });

 
  // TEST 10: Estado de negocio del producto es correcto
 
  test('TEST 10: Estado de negocio del producto es correcto', () {
    expect(_producto(diasHastaVencimiento: 10).estado, equals(ProductoEstado.disponible));
    expect(_producto(diasHastaVencimiento: 3).estado, equals(ProductoEstado.urgente));
    expect(_producto(diasHastaVencimiento: 1).estado, equals(ProductoEstado.critico));
    expect(_producto(diasHastaVencimiento: -1).estado, equals(ProductoEstado.vencido));
    print('TEST 10 PASÓ: Estados de negocio correctos');
  });
}
