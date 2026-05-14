import 'package:lastbite/features/recetas/domain/receta.dart';

enum AlertaTipo { aviso5, aviso3, aviso1, vencido }

class Alerta {
  final String id;
  final String productoId;
  final String nombreProducto;
  final String emoji;
  final DateTime fechaCaducidad;
  final AlertaTipo tipo;
  final DateTime creadaEn;
  final Receta? recetaSugerida;

  const Alerta({
    required this.id,
    required this.productoId,
    required this.nombreProducto,
    required this.emoji,
    required this.fechaCaducidad,
    required this.tipo,
    required this.creadaEn,
    this.recetaSugerida,
  });

  bool get tieneReceta => recetaSugerida != null;

  int get prioridad {
    switch (tipo) {
      case AlertaTipo.vencido:
        return 4;
      case AlertaTipo.aviso1:
        return 3;
      case AlertaTipo.aviso3:
        return 2;
      case AlertaTipo.aviso5:
        return 1;
    }
  }

  String get etiqueta {
    switch (tipo) {
      case AlertaTipo.aviso5:
        return '5d';
      case AlertaTipo.aviso3:
        return '3d';
      case AlertaTipo.aviso1:
        return '1d';
      case AlertaTipo.vencido:
        return 'Vencido';
    }
  }

  String get titulo {
    switch (tipo) {
      case AlertaTipo.aviso5:
        return 'Primer aviso';
      case AlertaTipo.aviso3:
        return 'Aviso critico';
      case AlertaTipo.aviso1:
        return 'Ultimo dia';
      case AlertaTipo.vencido:
        return 'Producto vencido';
    }
  }

  String get mensaje {
    switch (tipo) {
      case AlertaTipo.aviso5:
        return 'Tu $nombreProducto vencera en 5 dias. Ten cuidado.';
      case AlertaTipo.aviso3:
        return 'Tu $nombreProducto vence en 3 dias. Te sugerimos una receta.';
      case AlertaTipo.aviso1:
        return 'Tu $nombreProducto vence manana. Aprovechalo hoy.';
      case AlertaTipo.vencido:
        return 'Tu $nombreProducto ya caduco. Retiralo de la despensa.';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'emoji': emoji,
      'fechaCaducidad': fechaCaducidad.toIso8601String(),
      'tipo': tipo.name,
      'creadaEn': creadaEn.toIso8601String(),
      'receta': recetaSugerida == null ? null : _recetaToMap(recetaSugerida!),
    };
  }

  factory Alerta.fromMap(Map<String, dynamic> map) {
    final receta = _recetaFromMap(map['receta']);
    return Alerta(
      id: map['id']?.toString() ?? '',
      productoId: map['productoId']?.toString() ?? '',
      nombreProducto: map['nombreProducto']?.toString() ?? '',
      emoji: map['emoji']?.toString() ?? '',
      fechaCaducidad: DateTime.tryParse(
            map['fechaCaducidad']?.toString() ?? '',
          ) ??
          DateTime.now(),
      tipo: _parseTipo(map['tipo']?.toString()),
      creadaEn: DateTime.tryParse(map['creadaEn']?.toString() ?? '') ??
          DateTime.now(),
      recetaSugerida: receta,
    );
  }

  static String buildId({
    required String productoId,
    required AlertaTipo tipo,
  }) =>
      '${productoId}_${tipo.name}';

  static AlertaTipo _parseTipo(String? raw) {
    if (raw == null) return AlertaTipo.aviso5;
    return AlertaTipo.values.firstWhere(
      (tipo) => tipo.name == raw,
      orElse: () => AlertaTipo.aviso5,
    );
  }

  static Map<String, dynamic> _recetaToMap(Receta receta) {
    return {
      'id': receta.id,
      'titulo': receta.titulo,
      'imagenUrl': receta.imagenUrl,
      'ingredientesUsados': receta.ingredientesUsados,
      'ingredientesFaltantes': receta.ingredientesFaltantes,
      'likes': receta.likes,
      'ingredientes': receta.ingredientes ?? const <String>[],
    };
  }

  static Receta? _recetaFromMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw as Map);
    final ingredientes = (map['ingredientes'] as List?)
        ?.whereType<String>()
        .toList();

    return Receta(
      id: (map['id'] as num?)?.toInt() ?? 0,
      titulo: map['titulo']?.toString() ?? '',
      imagenUrl: map['imagenUrl']?.toString() ?? '',
      ingredientesUsados: (map['ingredientesUsados'] as num?)?.toInt() ?? 0,
      ingredientesFaltantes: (map['ingredientesFaltantes'] as num?)?.toInt() ?? 0,
      likes: (map['likes'] as num?)?.toInt() ?? 0,
      ingredientes: ingredientes,
    );
  }
}
