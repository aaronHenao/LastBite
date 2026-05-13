import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';
import '../domain/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

//instancia única del servicio
final authServiceProvider = Provider<AuthService>((_) => AuthService());

//stream del estado de sesión, escucha cambios en tiempo real
final authStateProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges,
);

//stream directo de firebase
final firebaseUserProvider = StreamProvider<User?>(
  (_) => FirebaseAuth.instance.authStateChanges(),
);