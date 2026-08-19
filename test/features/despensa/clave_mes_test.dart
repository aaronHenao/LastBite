import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/features/despensa/data/despensa_repository.dart';

void main() {
  group('DespensaRepository.claveMes', () {
    test('rellena el mes con cero a la izquierda', () {
      expect(DespensaRepository.claveMes(DateTime(2026, 8, 15)), '2026-08');
    });

    test('no altera los meses de dos dígitos', () {
      expect(DespensaRepository.claveMes(DateTime(2026, 12, 31)), '2026-12');
    });

    test('el día no influye en la clave', () {
      expect(
        DespensaRepository.claveMes(DateTime(2026, 3, 1)),
        DespensaRepository.claveMes(DateTime(2026, 3, 31)),
      );
    });

    test('meses iguales de años distintos dan claves distintas', () {
      expect(
        DespensaRepository.claveMes(DateTime(2025, 8, 15)),
        isNot(DespensaRepository.claveMes(DateTime(2026, 8, 15))),
      );
    });
  });
}
