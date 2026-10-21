import 'package:firebase_auth/firebase_auth.dart';
import 'package:lastbite/features/compartida/data/despensa_compartida_repository.dart';
import 'package:lastbite/core/data/despensa_ref.dart';
import 'package:lastbite/features/despensa/data/despensa_repository.dart';
import 'package:lastbite/l10n/traducciones.dart';
import '../notifications/notification_service.dart';
import '../../features/alertas/domain/alerta.dart';

class VencimientoChecker {
  VencimientoChecker._();
  static final instance = VencimientoChecker._();

  Future<void> verificar() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final compartidaId = await DespensaCompartidaRepository().idCompartidaDe(
      user.uid,
    );
    final repo = DespensaRepository(
      userId: user.uid,
      despensaCompartidaId: compartidaId,
    );
    final debe = await repo.debeEnviarNotificaciones();
    if (!debe) return; 

    final snapshot = await raizDespensa(
      userId: user.uid,
      despensaCompartidaId: compartidaId,
    ).collection('alertas').get();

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
    final t = textosActuales;
    int id = 200;

    for (final alerta in alertas) {
      switch (alerta.tipo) {
        case AlertaTipo.aviso1:
          await notif.mostrarNotificacion(
            id: id++,
            titulo: '⚠️ ${t.notifVenceManana(alerta.nombreProducto)}',
            cuerpo: alerta.tieneReceta
                ? '${alerta.emoji} ${t.notifVenceMananaConReceta}'
                : '${alerta.emoji} ${t.notifVenceMananaSinReceta}',
            payload: 'alertas', // para el deep link
          );
          break;
        case AlertaTipo.aviso3:
          await notif.mostrarNotificacion(
            id: id++,
            titulo: '🕐 ${t.notifVenceEn3(alerta.nombreProducto)}',
            cuerpo: '${alerta.emoji} ${t.notifVenceEn3Cuerpo}',
            payload: 'alertas',
          );
          break;
        case AlertaTipo.vencido:
          await notif.mostrarNotificacion(
            id: id++,
            titulo: '🚨 ${t.notifVencido(alerta.nombreProducto)}',
            cuerpo: '${alerta.emoji} ${t.notifVencidoCuerpo}',
            payload: 'alertas',
          );
          break;
        case AlertaTipo.aviso5:
          break; // aviso5 no genera push
      }
    }
  }
}