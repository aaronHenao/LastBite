class AuthUser {
  final String uid;
  final String? email;
  final String? nombre;
  final String? fotoUrl;

  /// Estado de la cuenta leído desde Firestore.
  /// Valores posibles: active | blocked | pendingApproval | admin
  /// Por defecto es 'active' para no romper usuarios existentes.
  final String status;

  const AuthUser({
    required this.uid,
    this.email,
    this.nombre,
    this.fotoUrl,
    this.status = 'active',
  });
}
