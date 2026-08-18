class ItemCompra {
  final String id;
  final String nombre;
  final String emoji;
  final bool comprado;
  final DateTime agregadoEn;

  const ItemCompra({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.comprado,
    required this.agregadoEn,
  });

  ItemCompra copyWith({bool? comprado}) => ItemCompra(
        id: id,
        nombre: nombre,
        emoji: emoji,
        comprado: comprado ?? this.comprado,
        agregadoEn: agregadoEn,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'emoji': emoji,
        'comprado': comprado,
        'agregadoEn': agregadoEn.toIso8601String(),
      };

  factory ItemCompra.fromMap(Map<String, dynamic> map) => ItemCompra(
        id: map['id'] as String,
        nombre: map['nombre'] as String,
        emoji: map['emoji'] as String,
        comprado: map['comprado'] as bool? ?? false,
        agregadoEn: DateTime.parse(map['agregadoEn'] as String),
      );
}