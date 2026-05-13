import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/auth_user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<AuthUser?> get authStateChanges => _auth.authStateChanges().map(
    (user) => user == null ? null : _mapUser(user),
  );

  AuthUser? get usuarioActual {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  //email-contraseña

  Future<AuthUser> registrar({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(nombre.trim());
      await cred.user?.reload();
      return _mapUser(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  //google

  final _googleSignIn = GoogleSignIn();

  Future<AuthUser> loginConGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Login cancelado');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      return _mapUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  //logout

  Future<void> cerrarSesion() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  //helpers

  AuthUser _mapUser(User user) => AuthUser(
    uid: user.uid,
    email: user.email,
    nombre: user.displayName,
    fotoUrl: user.photoURL,
  );

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Correo o contraseña incorrectos.';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
