import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/auth_user.dart';

/// Error al entrar o registrarse. [codigo] es el de Firebase
/// ('email-already-in-use', 'popup-blocked'...) o [cancelado]. El servicio no
/// arma frases: la pantalla las pone en el idioma activo.
class ErrorAuth implements Exception {
  const ErrorAuth(this.codigo, [this.detalle]);

  /// La persona cerro la ventana de Google: no es un error que mostrar.
  static const cancelado = 'cancelado';

  final String codigo;

  /// Mensaje tecnico de Firebase, para diagnosticar.
  final String? detalle;

  @override
  String toString() => 'ErrorAuth($codigo${detalle == null ? '' : ': $detalle'})';
}

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
      // En web, google_sign_in.signIn() esta obsoleto: no devuelve idToken y
      // depende de People API. Firebase abre su propio popup de Google.
      if (kIsWeb) {
        final cred = await _auth.signInWithPopup(GoogleAuthProvider());
        return _mapUser(cred.user!);
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const ErrorAuth(ErrorAuth.cancelado);

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      return _mapUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        throw const ErrorAuth(ErrorAuth.cancelado);
      }
      throw _mapError(e);
    }
  }

  //logout

  Future<void> cerrarSesion() async {
    if (!kIsWeb) await _googleSignIn.signOut();
    await _auth.signOut();
  }

  //helpers

  AuthUser _mapUser(User user) => AuthUser(
    uid: user.uid,
    email: user.email,
    nombre: user.displayName,
    fotoUrl: user.photoURL,
  );

  ErrorAuth _mapError(FirebaseAuthException e) => ErrorAuth(e.code, e.message);
}
