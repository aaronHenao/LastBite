import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lastbite/l10n/traducciones.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Function(String?)? onNotificationTap;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // flutter_local_notifications no tiene implementacion web: sin este guard
    // initialize() lanza MissingPluginException, y como main() lo espera antes
    // de runApp(), la app nunca monta y queda en blanco.
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        //llama el callback cuando el usuario toca la notificación
        onNotificationTap?.call(response.payload);
      },
    );

    _initialized = true;
  }

  Future<void> solicitarPermisos() async {
    final plugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await plugin?.requestNotificationsPermission();
  }

  /// No hace nada en web: ver el guard de init().
  Future<void> mostrarNotificacion({
    required int id,
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      'lastbite_vencimientos',
      textosActuales.notifCanal,
      channelDescription: textosActuales.notifCanalDescripcion,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      id,
      titulo,
      cuerpo,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
  }
}
