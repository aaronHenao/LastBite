import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/features/alertas/domain/alerta.dart';
import 'package:lastbite/features/alertas/domain/generar_alertas.dart';
import 'package:lastbite/features/despensa/domain/producto.dart';

Producto _producto(String id, int dias) => Producto(
  id: id,
  nombre: 'Leche $id',
  emoji: '🥛',
  categoria: 'Leche',
  cantidad: '1 L',
  // La hora extra evita que el redondeo de inDays reste un dia; con fechas
  // ya vencidas hay que correrla al otro lado.
  fechaCaducidad: DateTime.now().add(
    Duration(days: dias, hours: dias < 0 ? -1 : 1),
  ),
  esFresco: false,
);

List<AlertaTipo> _tipos(List<Alerta> alertas) =>
    alertas.map((a) => a.tipo).toList();

void main() {
  group('alertasPendientes', () {
    test('un producto crea una alerta por cada umbral alcanzado', () {
      expect(
        _tipos(
          alertasPendientes(productos: [_producto('a', 1)], existentesIds: {}),
        ),
        [AlertaTipo.aviso5, AlertaTipo.aviso3, AlertaTipo.aviso1],
      );
      expect(
        _tipos(
          alertasPendientes(productos: [_producto('b', 4)], existentesIds: {}),
        ),
        [AlertaTipo.aviso5],
      );
      expect(
        alertasPendientes(productos: [_producto('c', 9)], existentesIds: {}),
        isEmpty,
      );
    });

    test('un producto vencido solo crea la alerta de vencido', () {
      expect(
        _tipos(
          alertasPendientes(productos: [_producto('d', -2)], existentesIds: {}),
        ),
        [AlertaTipo.vencido],
      );
    });

    test('no repite alertas que ya existen, aunque esten descartadas', () {
      final existentes = {
        Alerta.buildId(productoId: 'e', tipo: AlertaTipo.aviso5),
        Alerta.buildId(productoId: 'e', tipo: AlertaTipo.aviso3),
      };
      expect(
        _tipos(
          alertasPendientes(
            productos: [_producto('e', 1)],
            existentesIds: existentes,
          ),
        ),
        [AlertaTipo.aviso1],
      );
    });

    test(
      'un producto agregado despues de "Borrar todo" si genera sus alertas',
      () {
        // Regresion: antes se descartaba toda alerta cuyo aviso "debia" haber
        // saltado antes del ultimo borrado, y este producto (vence en 2 dias,
        // agregado despues de borrar) se quedaba sin ninguna.
        final borradas = {
          Alerta.buildId(productoId: 'viejo', tipo: AlertaTipo.aviso5),
        };
        expect(
          _tipos(
            alertasPendientes(
              productos: [_producto('nuevo', 2)],
              existentesIds: borradas,
            ),
          ),
          [AlertaTipo.aviso5, AlertaTipo.aviso3],
        );
      },
    );
  });

  test('ordenarAlertas: lo mas urgente primero, luego lo mas reciente', () {
    Alerta alerta(String id, AlertaTipo tipo, int dia) => Alerta(
      id: id,
      productoId: id,
      nombreProducto: id,
      emoji: '',
      fechaCaducidad: DateTime(2026, 10, dia),
      tipo: tipo,
      creadaEn: DateTime(2026, 9, dia),
    );

    final ordenadas = ordenarAlertas([
      alerta('a5-viejo', AlertaTipo.aviso5, 1),
      alerta('vencido', AlertaTipo.vencido, 2),
      alerta('a5-nuevo', AlertaTipo.aviso5, 9),
    ]);
    expect(ordenadas.map((a) => a.id), ['vencido', 'a5-nuevo', 'a5-viejo']);
  });
}
