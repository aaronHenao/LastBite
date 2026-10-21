import 'package:lastbite/core/constants/unidades_medida.dart';

import 'app_localizations.dart';

/// Datos guardados en español que se muestran en el idioma activo.
///
/// Las categorias ('Leche', 'Verdura') y las cantidades ("2 unidad",
/// "1 taza") se guardan en Firestore tal cual y sirven de clave para la vida
/// util, los precios y el ahorro. No se pueden traducir en el dato: se
/// traducen al mostrarlos, aca.
extension TextosDominio on L10n {
  /// Nombre de una categoria guardada. Si no es una conocida, va tal cual.
  String categoria(String categoria) =>
      switch (categoria.trim().toLowerCase()) {
        'verdura' => categoriaVerdura,
        'fruta' => categoriaFruta,
        'hierba' => categoriaHierba,
        'carne' => categoriaCarne,
        'pollo' => categoriaPollo,
        'pescado' => categoriaPescado,
        'huevo' => categoriaHuevo,
        'leche' => categoriaLeche,
        'yogur' => categoriaYogur,
        'queso' => categoriaQueso,
        'mantequilla' => categoriaMantequilla,
        'pan' => categoriaPan,
        'embutido' => categoriaEmbutido,
        'jugo' => categoriaJugo,
        'grano' => categoriaGrano,
        'conserva' => categoriaConserva,
        'cereal' => categoriaCereal,
        'otro' => categoriaOtro,
        _ => categoria,
      };

  /// Unidad tal como se ofrece al elegirla. Las del sistema metrico son
  /// iguales en todos los idiomas.
  String unidad(UnidadMedida unidad) => switch (unidad) {
    UnidadMedida.unidad => unidadUnidad,
    UnidadMedida.cucharada => unidadCucharada,
    UnidadMedida.taza => unidadTaza,
    _ => unidad.abreviatura,
  };

  /// Cantidad guardada ("2 unidad", "1,5 taza", "500 g") en el idioma activo.
  /// Lo que no sigue ese formato, como el texto de Open Food Facts, va tal
  /// cual.
  String cantidad(String guardada) {
    final partes = RegExp(
      r'^\s*([0-9]+(?:[.,][0-9]+)?)\s*([a-zA-Z]*)\s*$',
    ).firstMatch(guardada);
    if (partes == null) return guardada;

    final numero = partes.group(1)!;
    final valor = num.tryParse(numero.replaceAll(',', '.')) ?? 0;
    return switch (partes.group(2)!.toLowerCase()) {
      '' || 'unidad' || 'unidades' || 'u' || 'und' => cantidadUnidades(
        numero,
        valor,
      ),
      'taza' || 'tazas' => cantidadTazas(numero, valor),
      'cda' => cantidadCucharadas(numero),
      _ => guardada,
    };
  }
}
