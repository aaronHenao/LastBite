import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/navigation/main_shell.dart';
import 'package:lastbite/core/notifications/notification_service.dart';
import 'package:lastbite/core/notifications/vencimiento_checker.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/blocked_screen.dart';
import 'features/auth/presentation/pending_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.init();

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

class _AuthGate extends ConsumerStatefulWidget {
  const _AuthGate();

  @override
  ConsumerState<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<_AuthGate> {
  bool _initDone = false;

  @override
  Widget build(BuildContext context) {
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

        if (!_initDone) {
          _initDone = true;

          Future.microtask(() async {
            await NotificationService.instance.solicitarPermisos();
            VencimientoChecker.instance.verificar();
          });
        }

        switch (user.status) {
          case 'blocked':
            return const BlockedScreen();
          case 'pendingApproval':
            return const PendingScreen();
          default:
            return const MainShell();
        }
      },
    );
  }
}