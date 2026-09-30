import 'package:lastbite/features/despensa/domain/producto.dart';

import 'alerta.dart';

/// Alertas que corresponde crear para [productos] y que todavia no existen.
///
/// Un producto vencido tiene la alerta `vencido`; si no, una por cada umbral
/// que ya alcanzo (5, 3 y 1 dia), asi que puede tener varias a la vez.
///
/// [existentesIds] incluye las alertas descartadas: una alerta descartada no
/// se vuelve a crear. Antes "Borrar todo" borraba los documentos y guardaba
/// la fecha del borrado, y se descartaba toda alerta cuyo aviso "debia" haber
/// saltado antes de esa fecha. Un producto agregado despues del borrado que
/// vencia pronto se quedaba sin ninguna alerta.
List<Alerta> alertasPendientes({
  required List<Producto> productos,
  required Set<String> existentesIds,
  DateTime? ahora,
}) {
  final momento = ahora ?? DateTime.now();
  final nuevas = <Alerta>[];

  void agregar(Producto producto, AlertaTipo tipo) {
    final id = Alerta.buildId(productoId: producto.id, tipo: tipo);
    if (existentesIds.contains(id)) return;
    nuevas.add(
      Alerta(
        id: id,
        productoId: producto.id,
        nombreProducto: producto.nombre,
        emoji: producto.emoji,
        fechaCaducidad: producto.fechaCaducidad,
        tipo: tipo,
        creadaEn: momento,
      ),
    );
  }

  for (final producto in productos) {
    final dias = producto.diasRestantes;
    if (dias < 0) {
      agregar(producto, AlertaTipo.vencido);
      continue;
    }
    if (dias <= 5) agregar(producto, AlertaTipo.aviso5);
    if (dias <= 3) agregar(producto, AlertaTipo.aviso3);
    if (dias <= 1) agregar(producto, AlertaTipo.aviso1);
  }

  return nuevas;
}

/// Primero lo mas urgente; a igual urgencia, lo mas reciente. Antes se
/// ordenaba solo por creadaEn, asi que un producto ya vencido quedaba debajo
/// de un primer aviso de hoy.
List<Alerta> ordenarAlertas(Iterable<Alerta> alertas) =>
    alertas.toList()..sort((a, b) {
      final porUrgencia = b.prioridad.compareTo(a.prioridad);
      if (porUrgencia != 0) return porUrgencia;
      return b.creadaEn.compareTo(a.creadaEn);
    });
