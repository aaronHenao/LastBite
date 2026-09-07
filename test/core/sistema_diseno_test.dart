import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastbite/core/theme/app_theme.dart';

void main() {
  group('la paleta separa marca de estado', () {
    test('ningun color de marca se usa para comunicar urgencia', () {
      final marca = {
        AppColors.marca,
        AppColors.marcaClara,
        AppColors.marcaSuave,
      };
      final estados = {AppColors.vencido, AppColors.critico, AppColors.urgente};

      expect(marca.intersection(estados), isEmpty);
    });

    test('ningun token repite el valor de otro', () {
      // yellow y surface eran el mismo hex, asi que el chip de "7 dias" era
      // invisible sobre cualquier superficie.
      final tokens = [
        AppColors.marca,
        AppColors.marcaClara,
        AppColors.marcaSuave,
        AppColors.papel,
        AppColors.superficie,
        AppColors.superficieSuave,
        AppColors.tinta,
        AppColors.contorno,
        AppColors.vencido,
        AppColors.critico,
        AppColors.urgente,
      ];
      expect(tokens.toSet().length, tokens.length);
    });

    test('la escala de urgencia es estrictamente decreciente', () {
      expect(AppTheme.colorUrgencia(-1), AppColors.vencido);
      expect(AppTheme.colorUrgencia(0), AppColors.critico);
      expect(AppTheme.colorUrgencia(1), AppColors.critico);
      expect(AppTheme.colorUrgencia(3), AppColors.urgente);
      expect(AppTheme.colorUrgencia(7), AppColors.proximo);
      // Mas de una semana no gana color.
      expect(AppTheme.colorUrgencia(8), isNull);
      expect(AppTheme.colorUrgencia(365), isNull);
    });
  });

  group('contraste', () {
    double luminancia(Color c) => c.computeLuminance();
    double ratio(Color a, Color b) {
      final l = [luminancia(a), luminancia(b)]..sort();
      return (l[1] + 0.05) / (l[0] + 0.05);
    }

    test('el texto principal y el secundario pasan AA sobre el fondo', () {
      expect(ratio(AppColors.tinta, AppColors.papel), greaterThan(4.5));
      expect(ratio(AppColors.apagado, AppColors.papel), greaterThan(4.5));
    });

    test('cada color de estado pasa AA con texto blanco encima', () {
      for (final color in [
        AppColors.vencido,
        AppColors.critico,
        AppColors.urgente,
      ]) {
        expect(
          ratio(const Color(0xFFFFFFFF), color),
          greaterThan(4.5),
          reason: 'La pastilla solida lleva texto blanco',
        );
      }
    });

    test('el modo oscuro tambien pasa AA', () {
      for (final color in [
        AppColorsOscuro.tinta,
        AppColorsOscuro.apagado,
        AppColorsOscuro.marca,
        AppColorsOscuro.vencido,
        AppColorsOscuro.critico,
        AppColorsOscuro.urgente,
      ]) {
        expect(ratio(color, AppColorsOscuro.papel), greaterThan(4.5));
      }
    });
  });
}
