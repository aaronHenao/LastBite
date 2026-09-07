import 'package:flutter/material.dart';

/// Sistema de diseño de LastBite.
///
/// Regla que ordena todo lo demas: **el color de marca y el color de estado no
/// comparten tokens**. El verde identifica la app; la urgencia de un alimento
/// es informacion y tiene su propia escala. Mezclarlos fue el origen de casi
/// todos los problemas visuales de la version anterior.
///
/// Los contrastes anotados estan calculados sobre el fondo real de cada caso
/// segun WCAG 2.1. El minimo es 4.5:1 para texto normal.
class AppColors {
  // ---------------------------------------------------------------- marca

  /// Verde de huerta, profundo para poder llevar texto. 7.46:1 sobre `papel`.
  static const marca = Color(0xFF3D5A2B);

  /// Estado presionado y acentos secundarios. 5.44:1 sobre `papel`.
  static const marcaClara = Color(0xFF4E7038);

  /// Fondo de bloques de marca. Nunca lleva texto encima que no sea `marca`.
  static const marcaSuave = Color(0xFFE4EDD8);

  // -------------------------------------------------------------- neutros

  /// Fondo de la app. Papel calido, no gris: un gris puro al lado de este
  /// verde se ve sucio.
  static const papel = Color(0xFFFBFAF6);

  /// Tarjetas y hojas.
  static const superficie = Color(0xFFFFFFFF);

  /// Fondo de bloques secundarios dentro de una tarjeta.
  static const superficieSuave = Color(0xFFF2F1E9);

  /// Texto principal. 15.75:1 sobre `papel`.
  static const tinta = Color(0xFF1C2114);

  /// Texto secundario. 6.77:1 sobre `papel` y nunca por debajo de 5.8 sobre
  /// el resto de las superficies, incluidas las tenidas por un color de
  /// estado. Opaco a proposito: la version anterior era negro con alfa, y
  /// cualquier `withValues` encima lo volvia ilegible.
  static const apagado = Color(0xFF525C42);

  /// Separadores y contornos.
  static const contorno = Color(0xFFE2E0D2);

  // --------------------------------------------------- estado del alimento

  /// Ya vencido. 6.53:1 con texto blanco encima.
  static const vencido = Color(0xFFB02B23);

  /// Vence hoy o mañana. 4.83:1 con texto blanco encima.
  static const critico = Color(0xFFB85519);

  /// Vence en dos o tres dias. 5.09:1 con texto blanco encima.
  static const urgente = Color(0xFF946509);

  /// Vence esta semana. Informa sin alarmar, por eso es neutro.
  static const proximo = Color(0xFF525C42);

}

/// Paleta del modo oscuro. Mismos roles, valores propios: no se invierte la
/// paleta clara, se aclaran los semanticos para que sigan pasando contraste.
class AppColorsOscuro {
  static const marca = Color(0xFFA3C97D); // 9.60:1
  static const marcaClara = Color(0xFFB8DA94);
  static const marcaSuave = Color(0xFF263019);

  // El fondo baja y la tarjeta sube: en la version anterior casi no se
  // separaban y todo se leia como una mancha.
  static const papel = Color(0xFF0F130C);
  static const superficie = Color(0xFF1A2015);
  static const superficieSuave = Color(0xFF232B1C);
  static const tinta = Color(0xFFEDF1E3); // 16.35:1
  static const apagado = Color(0xFFA3AF93); // 8.14:1
  static const contorno = Color(0xFF38412C);

  static const vencido = Color(0xFFF07167); // 6.22:1
  static const critico = Color(0xFFF0883E); // 7.11:1
  static const urgente = Color(0xFFE3B341); // 9.24:1
  static const proximo = Color(0xFF9BA88C);
}

/// Paletas de alto contraste. Todas las combinaciones superan 9:1, muy por
/// encima del 4.5 que pide la norma: sirven a quien tiene baja visión severa,
/// y tambien a cualquiera bajo el sol directo.
class AppPaletasContraste {
  static const clara = AppPalette(
    marca: Color(0xFF24391A),
    marcaClara: Color(0xFF24391A),
    marcaSuave: Color(0xFFE8F0DE),
    papel: Color(0xFFFFFFFF),
    superficie: Color(0xFFFFFFFF),
    superficieSuave: Color(0xFFF0F0EC),
    tinta: Color(0xFF000000),
    apagado: Color(0xFF2E3423),
    // El borde deja de ser una insinuacion: separa de verdad.
    contorno: Color(0xFF2E3423),
    vencido: Color(0xFF8E1B15),
    critico: Color(0xFF7A3208),
    urgente: Color(0xFF5C3D04),
    proximo: Color(0xFF2E3423),
  );

  static const oscura = AppPalette(
    marca: Color(0xFFC3E3A0),
    marcaClara: Color(0xFFC3E3A0),
    marcaSuave: Color(0xFF1C2814),
    papel: Color(0xFF000000),
    superficie: Color(0xFF0B0F08),
    superficieSuave: Color(0xFF141A10),
    tinta: Color(0xFFFFFFFF),
    apagado: Color(0xFFD3DCC4),
    contorno: Color(0xFFD3DCC4),
    vencido: Color(0xFFFFA79E),
    critico: Color(0xFFFFB067),
    urgente: Color(0xFFFFD470),
    proximo: Color(0xFFD3DCC4),
  );
}

/// Escala de espaciado. Cualquier separacion sale de aca; no se inventan
/// numeros intermedios.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 20.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Radios. Antes convivian ocho valores distintos para el mismo tipo de
/// superficie.
abstract final class AppRadius {
  /// Chips y pastillas de estado.
  static const chip = 999.0;

  /// Campos de texto y botones.
  static const sm = 10.0;

  /// Tarjetas.
  static const md = 14.0;

  /// Hojas inferiores y dialogos.
  static const lg = 20.0;
}

/// Movimiento. El movimiento confirma una accion, no decora.
abstract final class AppMotion {
  static const entra = Duration(milliseconds: 240);
  static const mueve = Duration(milliseconds: 240);
  static const sale = Duration(milliseconds: 180);
  static const pulsa = Duration(milliseconds: 150);
  static const expresiva = Duration(milliseconds: 480);

  static const curvaEntra = Curves.easeOut;
  static const curvaMueve = Curves.easeInOut;
  static const curvaSale = Curves.easeIn;
  static const curvaPulsa = Curves.ease;

  /// Para el gesto que celebra algo, como salvar un alimento.
  static const curvaExpresiva = Cubic(0.23, 1, 0.32, 1);

  /// Respeta el ajuste de "reducir movimiento" del sistema. Quien lo activa
  /// suele hacerlo por mareo o sensibilidad vestibular, no por gusto.
  static Duration duracion(BuildContext context, Duration valor) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : valor;
}

/// Paleta accesible desde el contexto, para que una pantalla se pinte sola en
/// claro y en oscuro. Las pantallas migran a esto en lugar de leer las
/// constantes estaticas de [AppColors].
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.marca,
    required this.marcaClara,
    required this.marcaSuave,
    required this.papel,
    required this.superficie,
    required this.superficieSuave,
    required this.tinta,
    required this.apagado,
    required this.contorno,
    required this.vencido,
    required this.critico,
    required this.urgente,
    required this.proximo,
  });

  final Color marca;
  final Color marcaClara;
  final Color marcaSuave;
  final Color papel;
  final Color superficie;
  final Color superficieSuave;
  final Color tinta;
  final Color apagado;
  final Color contorno;
  final Color vencido;
  final Color critico;
  final Color urgente;
  final Color proximo;

  static const clara = AppPalette(
    marca: AppColors.marca,
    marcaClara: AppColors.marcaClara,
    marcaSuave: AppColors.marcaSuave,
    papel: AppColors.papel,
    superficie: AppColors.superficie,
    superficieSuave: AppColors.superficieSuave,
    tinta: AppColors.tinta,
    apagado: AppColors.apagado,
    contorno: AppColors.contorno,
    vencido: AppColors.vencido,
    critico: AppColors.critico,
    urgente: AppColors.urgente,
    proximo: AppColors.proximo,
  );

  static const oscura = AppPalette(
    marca: AppColorsOscuro.marca,
    marcaClara: AppColorsOscuro.marcaClara,
    marcaSuave: AppColorsOscuro.marcaSuave,
    papel: AppColorsOscuro.papel,
    superficie: AppColorsOscuro.superficie,
    superficieSuave: AppColorsOscuro.superficieSuave,
    tinta: AppColorsOscuro.tinta,
    apagado: AppColorsOscuro.apagado,
    contorno: AppColorsOscuro.contorno,
    vencido: AppColorsOscuro.vencido,
    critico: AppColorsOscuro.critico,
    urgente: AppColorsOscuro.urgente,
    proximo: AppColorsOscuro.proximo,
  );

  /// Color del estado de un alimento, o **null** cuando no necesita insignia.
  /// Un producto en buen estado no se marca: el color aparece solo cuando algo
  /// reclama atencion, y por contraste lo urgente salta sin gritar.
  Color? urgenciaPorDias(int dias) {
    if (dias < 0) return vencido;
    if (dias <= 1) return critico;
    if (dias <= 3) return urgente;
    if (dias <= 7) return proximo;
    return null;
  }

  @override
  AppPalette copyWith({
    Color? marca,
    Color? marcaClara,
    Color? marcaSuave,
    Color? papel,
    Color? superficie,
    Color? superficieSuave,
    Color? tinta,
    Color? apagado,
    Color? contorno,
    Color? vencido,
    Color? critico,
    Color? urgente,
    Color? proximo,
  }) => AppPalette(
    marca: marca ?? this.marca,
    marcaClara: marcaClara ?? this.marcaClara,
    marcaSuave: marcaSuave ?? this.marcaSuave,
    papel: papel ?? this.papel,
    superficie: superficie ?? this.superficie,
    superficieSuave: superficieSuave ?? this.superficieSuave,
    tinta: tinta ?? this.tinta,
    apagado: apagado ?? this.apagado,
    contorno: contorno ?? this.contorno,
    vencido: vencido ?? this.vencido,
    critico: critico ?? this.critico,
    urgente: urgente ?? this.urgente,
    proximo: proximo ?? this.proximo,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      marca: Color.lerp(marca, other.marca, t)!,
      marcaClara: Color.lerp(marcaClara, other.marcaClara, t)!,
      marcaSuave: Color.lerp(marcaSuave, other.marcaSuave, t)!,
      papel: Color.lerp(papel, other.papel, t)!,
      superficie: Color.lerp(superficie, other.superficie, t)!,
      superficieSuave: Color.lerp(superficieSuave, other.superficieSuave, t)!,
      tinta: Color.lerp(tinta, other.tinta, t)!,
      apagado: Color.lerp(apagado, other.apagado, t)!,
      contorno: Color.lerp(contorno, other.contorno, t)!,
      vencido: Color.lerp(vencido, other.vencido, t)!,
      critico: Color.lerp(critico, other.critico, t)!,
      urgente: Color.lerp(urgente, other.urgente, t)!,
      proximo: Color.lerp(proximo, other.proximo, t)!,
    );
  }
}

/// Atajo para leer la paleta del tema activo.
extension AppPaletteContext on BuildContext {
  AppPalette get paleta =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.clara;
}

/// Familias tipograficas y sus roles. Tres familias con trabajos distintos:
/// antes habia una sola para todo, y por eso ningun nivel de la jerarquia se
/// distinguia del siguiente.
abstract final class AppFonts {
  /// Titulos de pantalla. Serif con caracter, algo organica.
  static const titulo = 'Fraunces';

  /// Interfaz: botones, etiquetas, cuerpo.
  static const interfaz = 'Montserrat';

  /// Datos: dias restantes, cantidades, codigos. Cifras de ancho fijo, asi
  /// las columnas de numeros se alinean y el codigo de invitacion se dicta
  /// sin errores.
  static const datos = 'IBMPlexMono';

  /// Fraunces es variable: el peso se pide por eje, no por archivo.
  static List<FontVariation> peso(double valor) => [
    FontVariation('wght', valor),
    // El eje optico ajusta el contraste de los trazos al tamaño del texto.
    FontVariation('opsz', 48),
  ];
}

/// Estilos para datos, que no encajan en los roles de Material.
abstract final class AppTextStyles {
  /// Cifras destacadas: dias restantes, cantidad salvada, ahorro del mes.
  static TextStyle dato(BuildContext context) => TextStyle(
    fontFamily: AppFonts.datos,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
    color: context.paleta.tinta,
  );

  /// Codigo de invitacion y demas texto que hay que dictar o copiar.
  static TextStyle codigo(BuildContext context) => TextStyle(
    fontFamily: AppFonts.datos,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 6,
    color: context.paleta.marca,
  );

  /// Rotulo de seccion en mayusculas.
  static TextStyle rotulo(BuildContext context) => TextStyle(
    fontFamily: AppFonts.datos,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.4,
    color: context.paleta.apagado,
  );
}

class AppTheme {
  static ThemeData get light => _construir(AppPalette.clara, Brightness.light);

  /// Variantes de alto contraste, para el ajuste que ofrece la app.
  static ThemeData get lightContraste =>
      _construir(AppPaletasContraste.clara, Brightness.light);

  static ThemeData get darkContraste =>
      _construir(AppPaletasContraste.oscura, Brightness.dark);

  /// Lista para usarse. Todavia no se conecta en `MaterialApp` porque las
  /// pantallas leen las constantes estaticas de [AppColors], que no cambian
  /// con el tema: se activa cuando cada pantalla pase a `context.paleta`.
  static ThemeData get dark => _construir(AppPalette.oscura, Brightness.dark);

  static ThemeData _construir(AppPalette p, Brightness brillo) {
    final textTheme = _textTheme(p);

    return ThemeData(
      useMaterial3: true,
      brightness: brillo,
      scaffoldBackgroundColor: p.papel,
      fontFamily: AppFonts.interfaz,
      extensions: [p],
      colorScheme: ColorScheme(
        brightness: brillo,
        primary: p.marca,
        onPrimary: brillo == Brightness.light ? Colors.white : p.papel,
        secondary: p.marcaClara,
        onSecondary: brillo == Brightness.light ? Colors.white : p.papel,
        error: p.vencido,
        onError: brillo == Brightness.light ? Colors.white : p.papel,
        surface: p.superficie,
        onSurface: p.tinta,
      ),
      textTheme: textTheme,

      // Antes no existia: las pantallas que no usaban AuthField caian al
      // subrayado de Material, con dos lenguajes de formulario en la misma app.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.superficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: p.apagado),
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.apagado),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.contorno),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.contorno),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.marca, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.vencido),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.marca,
          foregroundColor: brillo == Brightness.light ? Colors.white : p.papel,
          // 48 de alto minimo, que es lo que pide la pauta de Android.
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.marca,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: p.contorno),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.marca,
          minimumSize: const Size(0, 48),
          textStyle: textTheme.labelLarge,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: p.apagado,
        ),
      ),

      // Antes salian con los colores por defecto de Material, ajenos a la app.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.tinta,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: p.papel),
        actionTextColor: p.marcaClara,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: p.superficie,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: p.apagado),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.superficie,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: p.superficie,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: p.contorno),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // El indicador salia en accent sobre el fondo: 2.01:1, parecia que la app
      // se habia colgado.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.marca,
        linearTrackColor: p.contorno,
        circularTrackColor: p.contorno,
      ),

      dividerTheme: DividerThemeData(color: p.contorno, space: 1, thickness: 1),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.selected)
              ? p.marca
              : Colors.transparent,
        ),
        side: BorderSide(color: p.apagado, width: 2),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (estados) =>
              estados.contains(WidgetState.selected) ? p.marca : p.apagado,
        ),
      ),
    );
  }

  /// Escala tipografica. Una sola familia por ahora; los roles ya estan
  /// separados para cuando se sumen las familias de titulo y de datos.
  static TextTheme _textTheme(AppPalette p) => TextTheme(
    displayLarge: TextStyle(
      fontFamily: AppFonts.titulo,
      fontVariations: AppFonts.peso(700),
      fontSize: 34,
      letterSpacing: -0.8,
      height: 1.0,
      color: p.tinta,
    ),
    displayMedium: TextStyle(
      fontFamily: AppFonts.titulo,
      fontVariations: AppFonts.peso(600),
      fontSize: 28,
      letterSpacing: -0.5,
      height: 1.05,
      color: p.tinta,
    ),
    displaySmall: TextStyle(
      fontFamily: AppFonts.titulo,
      fontVariations: AppFonts.peso(600),
      fontSize: 24,
      height: 1.1,
      color: p.tinta,
    ),
    headlineLarge: TextStyle(
      fontFamily: AppFonts.titulo,
      fontVariations: AppFonts.peso(600),
      fontSize: 22,
      height: 1.15,
      color: p.tinta,
    ),
    headlineMedium: TextStyle(
      fontFamily: AppFonts.titulo,
      fontVariations: AppFonts.peso(600),
      fontSize: 20,
      height: 1.2,
      color: p.tinta,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: p.tinta,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: p.tinta,
    ),
    titleSmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: p.apagado,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: p.tinta),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: p.tinta),
    bodySmall: TextStyle(fontSize: 12, height: 1.4, color: p.apagado),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: p.tinta,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: p.apagado,
    ),
    // 11 es el escalon mas chico. Nada baja de aca.
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
      color: p.apagado,
    ),
  );

  // ------------------------------------------------- estado de un alimento

  /// Color del estado, o **null** cuando el producto no necesita insignia.
  /// Es la regla del sistema hecha codigo: si no hay color que devolver, la
  /// tarjeta no dibuja chip.
  static Color? colorUrgencia(int dias) => AppPalette.clara.urgenciaPorDias(dias);

  /// Fondo de la pastilla de estado.
  static Color? fondoUrgencia(int dias) =>
      colorUrgencia(dias)?.withValues(alpha: 0.14);

  static String diasLabel(int dias) {
    if (dias < 0) return '¡Vencido!';
    if (dias == 0) return 'Hoy';
    if (dias == 1) return 'Mañana';
    return '${dias}d';
  }

}
