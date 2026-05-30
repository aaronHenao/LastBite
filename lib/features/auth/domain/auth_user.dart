/// Roles funcionales del sistema LastBite.
///
/// - admin   → puede ver todos los productos y gestionar usuarios
/// - active  → puede agregar, ver y consumir sus productos
/// - viewer  → solo puede ver productos, sin agregar ni eliminar
enum UserRole { admin, active, viewer }

class AuthUser {
  final String uid;
  final String? email;
  final String? nombre;
  final String? fotoUrl;

  /// Estado de la cuenta leído desde Firestore.
  /// Valores: active | blocked | pendingApproval | admin
  final String status;

  /// Rol funcional del usuario dentro de la app.
  /// Valores: admin | active | viewer
  final UserRole role;

  const AuthUser({
    required this.uid,
    this.email,
    this.nombre,
    this.fotoUrl,
    this.status = 'active',
    this.role = UserRole.active,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isViewer => role == UserRole.viewer;
  bool get isActive => status == 'active' || status == 'admin';
  bool get isBlocked => status == 'blocked';
  bool get isPending => status == 'pendingApproval';
}
