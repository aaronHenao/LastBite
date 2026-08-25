class ItemCompra {
  final String id;
  final String nombre;
  final String emoji;
  final bool comprado;
  final DateTime agregadoEn;
  final DateTime? fechaConsumido;
  final DateTime? fechaVencido;

  const ItemCompra({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.comprado,
    required this.agregadoEn,
    this.fechaConsumido,
    this.fechaVencido,
  });

  ItemCompra copyWith({
    bool? comprado,
    DateTime? fechaConsumido,
    DateTime? fechaVencido,
  }) => ItemCompra(
    id: id,
    nombre: nombre,
    emoji: emoji,
    comprado: comprado ?? this.comprado,
    agregadoEn: agregadoEn,
    fechaConsumido: fechaConsumido ?? this.fechaConsumido,
    fechaVencido: fechaVencido ?? this.fechaVencido,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'emoji': emoji,
    'comprado': comprado,
    'agregadoEn': agregadoEn.toIso8601String(),
    'fechaConsumido': fechaConsumido?.toIso8601String(),
    'fechaVencido': fechaVencido?.toIso8601String(),
  };

  factory ItemCompra.fromMap(Map<String, dynamic> map) => ItemCompra(
    id: map['id'] as String,
    nombre: map['nombre'] as String,
    emoji: map['emoji'] as String,
    comprado: map['comprado'] as bool? ?? false,
    agregadoEn: DateTime.parse(map['agregadoEn'] as String),
    fechaConsumido: map['fechaConsumido'] == null
        ? null
        : DateTime.tryParse(map['fechaConsumido'] as String) ??
              DateTime.parse(map['fechaConsumido'] as String),
    fechaVencido: map['fechaVencido'] == null
        ? null
        : DateTime.tryParse(map['fechaVencido'] as String) ??
              DateTime.parse(map['fechaVencido'] as String),
  );
}