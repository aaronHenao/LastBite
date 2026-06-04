import 'package:flutter/material.dart';

class AppColors {
  // Paleta de la imagen aplicada a tus variables existentes
  static const bg = Color(0xFFFAFAF7);           
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
      primary: AppColors.green,
      secondary: AppColors.accent,
      surface: AppColors.card,
    ),
    useMaterial3: true,
    fontFamily: 'Montserrat',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: AppColors.textMain,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textMain,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMain,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    ),
  );

  static Color diasColor(int dias) {
    if (dias <= 0) return AppColors.danger;
    if (dias <= 1) return AppColors.danger;
    if (dias <= 3) return AppColors.accent;
    if (dias <= 7) return AppColors.yellow;
    return AppColors.green;
  }

  static Color diasBackground(int dias) =>
      diasColor(dias).withValues(alpha: 0.15);

  static String diasLabel(int dias) {
    if (dias <= 0) return '¡Vencido!';
    if (dias == 1) return '1d ⚠️';
    return '${dias}d';
  }
}
