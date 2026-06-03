import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lastbite/features/despensa/data/despensa_repository.dart';
import '../notifications/notification_service.dart';
import '../../features/alertas/domain/alerta.dart';

class VencimientoChecker {
  VencimientoChecker._();
  static final instance = VencimientoChecker._();

  final _db = FirebaseFirestore.instance;

  Future<void> verificar() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final repo = DespensaRepository(userId: user.uid);
    final debe = await repo.debeEnviarNotificaciones();
    if (!debe) return; 

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('alertas')
        .get();

    final alertas = snapshot.docs
        .where((doc) => doc.id != '_meta')
        .map((doc) => Alerta.fromMap({...doc.data(), 'id': doc.id}))
        .where((a) => !a.estaOculta)
        .toList();

    if (alertas.isEmpty) return;

    await _enviarNotificaciones(alertas);

    // Registra que ya se enviaron
    await repo.registrarEnvioNotificaciones();
  } catch (_) {}
}

  Future<void> _enviarNotificaciones(List<Alerta> alertas) async {
    final notif = NotificationService.instance;
    int id = 200;

    for (final alerta in alertas) {
      switch (alerta.tipo) {
        case AlertaTipo.aviso1:
          await notif.mostrarNotificacion(
            id: id++,
            titulo: '⚠️ ${alerta.nombreProducto} vence mañana',
            cuerpo: alerta.tieneReceta
                ? '${alerta.emoji} Aprovéchalo hoy — toca para ver una receta sugerida.'
                : '${alerta.emoji} Es tu último día para usarlo. ¡No lo desperdicies!',
            payload: 'alertas', // para el deep link
          );
          break;
        case AlertaTipo.aviso3:
          await notif.mostrarNotificacion(
            id: id++,
            titulo: '🕐 ${alerta.nombreProducto} vence en 3 días',
            cuerpo:
                '${alerta.emoji} Planifica una receta antes de que sea tarde.',
            payload: 'alertas',
          );
          break;
        case AlertaTipo.vencido:
          await notif.mostrarNotificacion(
            id: id++,
            titulo: '🚨 ${alerta.nombreProducto} ya venció',
            cuerpo:
                '${alerta.emoji} Retíralo de tu despensa.',
            payload: 'alertas',
          );
          break;
        case AlertaTipo.aviso5:
          break; // aviso5 no genera push
      }
    }
  }
}