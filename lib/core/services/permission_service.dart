import 'package:lastbite/features/auth/domain/auth_user.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';

/// Servicio de permisos y reglas de negocio de LastBite.
class PermissionService {

  // REGLA 1: Solo active y admin pueden agregar productos
  bool puedeAgregarProducto(AuthUser user) {
    return user.isActive && !user.isViewer;
  }

  // REGLA 2: Blocked y pending no pueden acceder al módulo principal
  bool puedeAccederModuloPrincipal(AuthUser user) {
    return !user.isBlocked && !user.isPending;
  }

  // REGLA 3: Pending no puede crear registros
  bool puedeCrerRegistros(AuthUser user) {
    return user.isActive && !user.isViewer;
  }

  // REGLA 4: Solo admin puede eliminar productos de otros usuarios
  bool puedeEliminarCualquierProducto(AuthUser user) {
    return user.isAdmin;
  }

  // REGLA 5: Solo active y admin pueden consumir, y el producto no puede estar vencido
  bool puedeConsumirProducto(AuthUser user, Producto producto) {
    return user.isActive && !user.isViewer && !producto.vencido;
  }

  // REGLA 6: Producto vencido debe eliminarse, no consumirse
  bool debeEliminarseEnVezDeConsumir(Producto producto) {
    return producto.vencido;
  }

  // REGLA 7: Solo admin puede ver estadísticas globales
  bool puedeVerEstadisticasGlobales(AuthUser user) {
    return user.isAdmin;
  }

  // REGLA 8: Viewer solo tiene acceso de lectura
  bool soloTieneAccesoLectura(AuthUser user) {
    return user.isViewer;
  }
}