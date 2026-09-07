import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/navigation/main_shell.dart';
import 'package:lastbite/core/notifications/notification_service.dart';
import 'package:lastbite/core/notifications/vencimiento_checker.dart';
import 'core/theme/app_theme.dart';
import 'core/preferencias/preferencias.dart';
import 'l10n/app_localizations.dart';
import 'core/preferencias/preferencias_provider.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.instance.init();

  runApp(const ProviderScope(child: LastBiteApp()));
}

class LastBiteApp extends ConsumerWidget {
  const LastBiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs =
        ref.watch(preferenciasProvider).valueOrNull ?? const Preferencias();

    return MaterialApp(
      title: 'LastBite',
      // Todas las pantallas leen la paleta del contexto, asi que basta con
      // elegir el tema aca para que el modo oscuro y el alto contraste se
      // pinten solos.
      theme: prefs.altoContraste ? AppTheme.lightContraste : AppTheme.light,
      darkTheme: prefs.altoContraste ? AppTheme.darkContraste : AppTheme.dark,
      themeMode: prefs.tema,
      // null deja que Flutter elija segun el idioma del dispositivo.
      locale: prefs.idioma == null ? null : Locale(prefs.idioma!),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final sistema = MediaQuery.of(context);

        // Mientras el ajuste de la app este en Normal manda el del sistema:
        // quien ya configuro su telefono no pierde esa eleccion. Al elegir un
        // tamaño aqui, esa eleccion pasa a mandar. El tope de 2.0 es hasta
        // donde estan probadas las pantallas.
        final escala = prefs.escalaTexto == 1.0
            ? sistema.textScaler
            : TextScaler.linear(prefs.escalaTexto);

        return MediaQuery(
          data: sistema.copyWith(
            textScaler: escala.clamp(maxScaleFactor: 2.0),
            disableAnimations:
                sistema.disableAnimations || prefs.reducirMovimiento,
          ),
          child: child!,
        );
      },
      home: const _AuthGate(),
    );
  }
}

// Decide qué mostrar según el estado de sesión
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const LoginScreen(),
      data: (user) {
        if (user != null) {
          NotificationService.instance.solicitarPermisos();
          Future.delayed(const Duration(seconds: 3), () {
            VencimientoChecker.instance.verificar();
          });
          return const MainShell();
        }
        return const LoginScreen();
      },
    );
  }
}
