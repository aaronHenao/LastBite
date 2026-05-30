import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/auth_user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        return await _mapUserConPerfil(user);
      });

  AuthUser? get usuarioActual {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  // ── email / contraseña ────────────────────────────────────────────────────

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

      final user = _auth.currentUser!;

      // Crear documento en Firestore con status 'active' por defecto
      await _db.collection('users').doc(user.uid).set({
        'name': nombre.trim(),
        'email': email.trim(),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AuthUser(
        uid: user.uid,
        email: user.email,
        nombre: user.displayName,
        fotoUrl: user.photoURL,
        status: 'active',
      );
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
      return await _mapUserConPerfil(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // ── Google ────────────────────────────────────────────────────────────────

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
      final user = cred.user!;

      // Si es la primera vez, crear perfil en Firestore
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return await _mapUserConPerfil(user);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // ── logout ────────────────────────────────────────────────────────────────

  Future<void> cerrarSesion() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  /// Lee el perfil completo desde Firestore incluyendo el status.
  Future<AuthUser> _mapUserConPerfil(User user) async {
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      final status = doc.data()?['status'] as String? ?? 'active';
      return AuthUser(
        uid: user.uid,
        email: user.email,
        nombre: user.displayName,
        fotoUrl: user.photoURL,
        status: status,
      );
    } catch (_) {
      // Si Firestore falla, asumir active para no bloquear al usuario
      return _mapUser(user);
    }
  }

  /// Mapeo simple sin Firestore (solo para compatibilidad).
  AuthUser _mapUser(User user) => AuthUser(
        uid: user.uid,
        email: user.email,
        nombre: user.displayName,
        fotoUrl: user.photoURL,
        status: 'active',
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
