import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/navigation/main_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/blocked_screen.dart';
import 'features/auth/presentation/pending_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: LastBiteApp()));
}

class LastBiteApp extends StatelessWidget {
  const LastBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LastBite',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const _AuthGate(),
    );
  }
}


class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ),
      error: (_, __) => const LoginScreen(),
      data: (user) {
        if (user == null) return const LoginScreen();

        // Redirigir según el status leído desde Firestore
        switch (user.status) {
          case 'blocked':
            return const BlockedScreen();
          case 'pendingApproval':
            return const PendingScreen();
          case 'active':
          case 'admin':
          default:
            return const MainShell();
        }
      },
    );
  }
}
