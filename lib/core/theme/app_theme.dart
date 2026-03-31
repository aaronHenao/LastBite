import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF2F4EE);
  static const surface = Color(0xFFE5EADF);
  static const card = Color(0xFFFFFFFF);
  static const green = Color(0xFF3D5A42);
  static const accent = Color(0xFFE67E22);
  static const yellow = Color(0xFFD4A373);

  // Textos
  static const textMain = Color(0xFF1A2421);
  static const textMuted = Color(0xFF636E72);

  // Bordes y separadores
  static const border = Color(0xFFDDE2D3);

  // Peligro / Error
  static const danger = Color(0xFFE67E22);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),
    useMaterial3: true,
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      titleLarge: TextStyle(
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
