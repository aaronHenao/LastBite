import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/features/alertas/domain/alerta.dart';

Alerta _alerta(AlertaTipo tipo, DateTime creadaEn) => Alerta(
  id: '${tipo.name}-${creadaEn.day}',
  productoId: 'p1',
  nombreProducto: 'Leche',
  emoji: '🥛',
  fechaCaducidad: creadaEn.add(const Duration(days: 1)),
  tipo: tipo,
  creadaEn: creadaEn,
);

void main() {
  test('la prioridad ordena de mas urgente a menos', () {
    expect(_alerta(AlertaTipo.vencido, DateTime(2026)).prioridad, 4);
    expect(_alerta(AlertaTipo.aviso1, DateTime(2026)).prioridad, 3);
    expect(_alerta(AlertaTipo.aviso3, DateTime(2026)).prioridad, 2);
    expect(_alerta(AlertaTipo.aviso5, DateTime(2026)).prioridad, 1);
  });

  test('lo vencido va antes que un aviso mas reciente', () {
    // El orden anterior era solo por creadaEn, asi que un producto ya vencido
    // quedaba debajo de un primer aviso generado hoy.
    final vencidoViejo = _alerta(AlertaTipo.vencido, DateTime(2026, 3, 1));
    final avisoNuevo = _alerta(AlertaTipo.aviso5, DateTime(2026, 3, 10));

    final lista = [avisoNuevo, vencidoViejo]
      ..sort((a, b) {
        final porUrgencia = b.prioridad.compareTo(a.prioridad);
        if (porUrgencia != 0) return porUrgencia;
        return b.creadaEn.compareTo(a.creadaEn);
      });

    expect(lista.first.tipo, AlertaTipo.vencido);
  });
}
