class AuthUser {
  final String uid;
  final String? email;
  final String? nombre;
  final String? fotoUrl;

  const AuthUser({
    required this.uid,
    this.email,
    this.nombre,
    this.fotoUrl,
  });
}