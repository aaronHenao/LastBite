/// Estadísticas de la despensa de un usuario.
/// Relacionada con: AuthUser (uid), Producto y Consumo.
class EstadisticasDespensa {
  final String uid;
  final int totalProductos;
  final int productosUrgentes;
  final int productosVencidos;
  final int salvados;
  final DateTime ultimaActualizacion;

  const EstadisticasDespensa({
    required this.uid,
    required this.totalProductos,
    required this.productosUrgentes,
    required this.productosVencidos,
    required this.salvados,
    required this.ultimaActualizacion,
  });

  /// Porcentaje de productos salvados sobre el total histórico.
  double get porcentajeSalvados {
    final total = salvados + productosVencidos;
    if (total == 0) return 0;
    return (salvados / total) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'totalProductos': totalProductos,
      'productosUrgentes': productosUrgentes,
      'productosVencidos': productosVencidos,
      'salvados': salvados,
      'ultimaActualizacion': ultimaActualizacion.toIso8601String(),
    };
  }

  factory EstadisticasDespensa.fromMap(Map<String, dynamic> map) {
    return EstadisticasDespensa(
      uid: map['uid'] as String,
      totalProductos: (map['totalProductos'] as num?)?.toInt() ?? 0,
      productosUrgentes: (map['productosUrgentes'] as num?)?.toInt() ?? 0,
      productosVencidos: (map['productosVencidos'] as num?)?.toInt() ?? 0,
      salvados: (map['salvados'] as num?)?.toInt() ?? 0,
      ultimaActualizacion: DateTime.tryParse(
            map['ultimaActualizacion']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  EstadisticasDespensa copyWith({
    int? totalProductos,
    int? productosUrgentes,
    int? productosVencidos,
    int? salvados,
    DateTime? ultimaActualizacion,
  }) {
    return EstadisticasDespensa(
      uid: uid,
      totalProductos: totalProductos ?? this.totalProductos,
      productosUrgentes: productosUrgentes ?? this.productosUrgentes,
      productosVencidos: productosVencidos ?? this.productosVencidos,
      salvados: salvados ?? this.salvados,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }
}
