import 'package:flutter/material.dart';

/// Ajustes de accesibilidad y apariencia que la persona elige en la app.
///
/// Todo esto existe tambien en el sistema operativo, pero no todo el mundo
/// sabe donde esta ni puede cambiarlo: en un telefono prestado, en una
/// computadora del trabajo, o simplemente porque quiere la letra grande solo
/// aca. Poder decidirlo dentro de la app es parte de que sea accesible.
@immutable
class Preferencias {
  const Preferencias({
    this.tema = ThemeMode.system,
    this.escalaTexto = 1.0,
    this.altoContraste = false,
    this.reducirMovimiento = false,
    this.idioma,
  });

  final ThemeMode tema;

  /// Multiplica el tamaño de todo el texto. La app esta probada hasta 2.0.
  final double escalaTexto;

  /// Sube el contraste al maximo y refuerza los bordes.
  final bool altoContraste;

  /// Apaga las animaciones aunque el sistema no lo pida.
  final bool reducirMovimiento;

  /// Codigo del idioma elegido, o null para seguir el del dispositivo.
  final String? idioma;

  /// Idiomas con traduccion completa.
  static const idiomasDisponibles = <({String codigo, String nombre})>[
    (codigo: 'es', nombre: 'Español'),
    (codigo: 'en', nombre: 'English'),
    (codigo: 'pt', nombre: 'Português'),
  ];

  /// Los pasos que ofrece el ajuste. La app esta probada hasta el ultimo.
  static const escalasDisponibles = <({double valor, String etiqueta})>[
    (valor: 1.0, etiqueta: 'Normal'),
    (valor: 1.3, etiqueta: 'Grande'),
    (valor: 1.6, etiqueta: 'Más grande'),
    (valor: 2.0, etiqueta: 'Máximo'),
  ];

  Preferencias copyWith({
    ThemeMode? tema,
    double? escalaTexto,
    bool? altoContraste,
    bool? reducirMovimiento,
    String? idioma,
    bool limpiarIdioma = false,
  }) => Preferencias(
    tema: tema ?? this.tema,
    escalaTexto: escalaTexto ?? this.escalaTexto,
    altoContraste: altoContraste ?? this.altoContraste,
    reducirMovimiento: reducirMovimiento ?? this.reducirMovimiento,
    idioma: limpiarIdioma ? null : (idioma ?? this.idioma),
  );

  Map<String, dynamic> toMap() => {
    'tema': tema.name,
    'escalaTexto': escalaTexto,
    'altoContraste': altoContraste,
    'reducirMovimiento': reducirMovimiento,
    'idioma': idioma,
  };

  factory Preferencias.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Preferencias();
    return Preferencias(
      tema: switch (map['tema']?.toString()) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      escalaTexto: (map['escalaTexto'] as num?)?.toDouble().clamp(1.0, 2.0) ?? 1.0,
      altoContraste: map['altoContraste'] as bool? ?? false,
      reducirMovimiento: map['reducirMovimiento'] as bool? ?? false,
      idioma: map['idioma'] as String?,
    );
  }
}
