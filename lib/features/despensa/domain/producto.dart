/// Estados de sincronización offline-first.
enum SyncStatus { synced, pendingSync, failedSync }

/// Estados de negocio del producto.
enum ProductoEstado { disponible, urgente, critico, vencido }

class Producto {
  final String id;
  final String nombre;
  final String emoji;
  final String categoria;
  final String cantidad;
  final DateTime fechaCaducidad;
  final bool esFresco;
  final String? codigoBarras;
  final String? imagenUrl;
  final SyncStatus syncStatus;

  Producto({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.categoria,
    required this.cantidad,
    required this.fechaCaducidad,
    required this.esFresco,
    this.codigoBarras,
    this.imagenUrl,
    this.syncStatus = SyncStatus.synced,
  });

  int get diasRestantes => fechaCaducidad.difference(DateTime.now()).inDays;

  bool get urgente => diasRestantes <= 3 && diasRestantes >= 0;
  bool get critico => diasRestantes <= 1 && diasRestantes >= 0;
  bool get vencido => diasRestantes < 0;
  bool get isPendingSync => syncStatus == SyncStatus.pendingSync;

  /// Estado de negocio calculado automáticamente.
  ProductoEstado get estado {
    if (vencido) return ProductoEstado.vencido;
    if (critico) return ProductoEstado.critico;
    if (urgente) return ProductoEstado.urgente;
    return ProductoEstado.disponible;
  }

  Producto copyWith({
    String? id,
    String? nombre,
    String? emoji,
    String? categoria,
    String? cantidad,
    DateTime? fechaCaducidad,
    bool? esFresco,
    String? codigoBarras,
    String? imagenUrl,
    SyncStatus? syncStatus,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      emoji: emoji ?? this.emoji,
      categoria: categoria ?? this.categoria,
      cantidad: cantidad ?? this.cantidad,
      fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
      esFresco: esFresco ?? this.esFresco,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'emoji': emoji,
      'categoria': categoria,
      'cantidad': cantidad,
      'fechaCaducidad': fechaCaducidad.toIso8601String(),
      'esFresco': esFresco,
      'codigoBarras': codigoBarras,
      'imagenUrl': imagenUrl,
      'syncStatus': syncStatus.name,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      emoji: map['emoji'] as String,
      categoria: map['categoria'] as String,
      cantidad: map['cantidad'] as String,
      fechaCaducidad: DateTime.parse(map['fechaCaducidad'] as String),
      esFresco: map['esFresco'] as bool,
      codigoBarras: map['codigoBarras'] as String?,
      imagenUrl: map['imagenUrl'] as String?,
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == (map['syncStatus'] as String? ?? 'synced'),
        orElse: () => SyncStatus.synced,
      ),
    );
  }
}
