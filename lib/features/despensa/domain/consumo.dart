/// Entidad que registra cada vez que un usuario consume (salva) un producto.
/// Relacionada con: AuthUser (uid) y Producto (productoId).
class Consumo {
  final String id;
  final String productoId;
  final String nombreProducto;
  final String emoji;
  final String uid;
  final DateTime consumidoEn;
  final int diasRestantesAlConsumir;

  const Consumo({
    required this.id,
    required this.productoId,
    required this.nombreProducto,
    required this.emoji,
    required this.uid,
    required this.consumidoEn,
    required this.diasRestantesAlConsumir,
  });

  /// Indica si el producto fue consumido a tiempo (antes de vencer).
  bool get consumidoATiempo => diasRestantesAlConsumir >= 0;

  /// Indica si fue consumido en estado urgente (≤ 3 días).
  bool get consumidoEnUrgente =>
      diasRestantesAlConsumir >= 0 && diasRestantesAlConsumir <= 3;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'emoji': emoji,
      'uid': uid,
      'consumidoEn': consumidoEn.toIso8601String(),
      'diasRestantesAlConsumir': diasRestantesAlConsumir,
    };
  }

  factory Consumo.fromMap(Map<String, dynamic> map) {
    return Consumo(
      id: map['id'] as String,
      productoId: map['productoId'] as String,
      nombreProducto: map['nombreProducto'] as String,
      emoji: map['emoji'] as String,
      uid: map['uid'] as String,
      consumidoEn: DateTime.parse(map['consumidoEn'] as String),
      diasRestantesAlConsumir: map['diasRestantesAlConsumir'] as int,
    );
  }
}
