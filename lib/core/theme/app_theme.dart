import 'package:flutter/material.dart';

class AppColors {
  // Paleta de la imagen aplicada a tus variables existentes
  static const bg = Color(0xFFFAFAF7);           // #FAFAF7 - Fondo
  static const surface = Color(0xFFD7E4C0);      // #D7E4C0 - Acento (usado como superficie secundaria)
  static const card = Color(0xFFFFFFFF);         // Blanco para las tarjetas del diseño
  static const green = Color(0xFF7C8B4C);        // #7C8B4C - Color Primario (Verde principal)
  static const accent = Color(0xFFA8B98A);       // #A8B98A - Color Secundario
  static const yellow = Color(0xFFD7E4C0);       // #D7E4C0 - Color de Acento claro

  // Textos
  static const textMain = Color(0xFF2E3423);     // #2E3423 - Texto principal
  static const textMuted = Color(0x992E3423);    // Texto principal con opacidad para el estilo "muted"

  // Bordes y separadores
  static const border = Color(0xFFDDE2D3);       // Borde suave a tono con la paleta

  // Peligro / Error (Adaptado sutilmente para que no rompa con la estética orgánica)
  static const danger = Color(0xFFC05141);       // Rojo terracota suave para alertas
}

class AppTheme {
  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.green,                  // Usamos tu variable 'green' como primario
      secondary: AppColors.accent,               // Tu 'accent' como secundario
      surface: AppColors.card,                   // Tus tarjetas en blanco
    ),
    useMaterial3: true,
    fontFamily: 'Montserrat',                    // Fuente principal de la interfaz según la imagen
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontFamily: 'Playfair Display',          // Fuente para títulos según la imagen
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Playfair Display',          // Títulos grandes o destacados de la marca
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textMain,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textMain),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textMuted),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    ),
  );

  static Color diasColor(int dias) {
    if (dias <= 0) return AppColors.danger;
    if (dias <= 1) return AppColors.danger;
    if (dias <= 3) return AppColors.accent;     // Mantiene tu lógica usando tus variables originales
    if (dias <= 7) return AppColors.yellow;
    return AppColors.green;
  }

  static Color diasBackground(int dias) =>
      diasColor(dias).withValues(alpha: 0.15);         // Corregido a con la sintaxis habitual de opacidad

  static String diasLabel(int dias) {
    if (dias <= 0) return '¡Vencido!';
    if (dias == 1) return '1d ⚠️';
    return '${dias}d';
  }
}
