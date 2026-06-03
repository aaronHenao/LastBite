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

  Future<void> mostrarNotificacion({
    required int id,
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'lastbite_vencimientos',
      'Alertas de vencimiento',
      channelDescription: 'Notificaciones de productos próximos a vencer',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      id,
      titulo,
      cuerpo,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
  }
}