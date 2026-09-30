import 'dart:convert';

import '../datasources/recetas_remote_exception.dart';

/// Receta tal como la genera el LLM, ya validada.
///
/// Se convierte a los mapas con forma Spoonacular que esperan
/// `RecetaBusquedaRemoteModel` y `RecetaDetalleRemoteModel`: asi las
/// pantallas y los modelos existentes siguen funcionando sin cambios.
class RecetaIaModel {
  const RecetaIaModel({
    required this.titulo,
    required this.ingredientes,
    required this.pasos,
    this.tipos = const [],
    this.minutos,
    this.porciones,
    this.descripcionImagen = '',
  });

  final String titulo;
  final List<IngredienteIa> ingredientes;
  final List<String> pasos;
  final List<String> tipos;
  final int? minutos;
  final int? porciones;

  /// Descripcion visual en ingles para generar la ilustracion del plato
  /// ("A bowl of chicken soup with rice and carrots").
  final String descripcionImagen;

  /// Id estable a partir del titulo. Queda por encima de 1.000.000.000 para
  /// no chocar con los ids de Spoonacular que siguen guardados en alertas
  /// viejas, y por debajo de 2^31 para ser un int seguro tambien en web.
  int get id => idRecetaIa(titulo);

  /// Ingredientes que se asume que hay en cualquier cocina. Cuentan como
  /// "Tienes" para que una receta no parezca imposible por la sal.
  static const basicos = {'sal', 'pimienta', 'aceite', 'agua'};

  // ------------------------------------------------------------- parseo

  /// Recetas que ya llegaron completas en una respuesta a medio recibir
  /// (streaming). Recorre el arreglo `recetas` contando llaves fuera de los
  /// strings y decodifica cada objeto cerrado; lo que falla se ignora.
  static List<Map<String, dynamic>> objetosCompletos(String parcial) {
    final clave = parcial.indexOf('"recetas"');
    final inicio = parcial.indexOf('[', clave == -1 ? 0 : clave);
    if (inicio == -1) return const [];

    final objetos = <Map<String, dynamic>>[];
    var profundidad = 0;
    var desde = -1;
    var enString = false;
    var escapado = false;

    for (var i = inicio + 1; i < parcial.length; i++) {
      final c = parcial[i];
      if (enString) {
        if (escapado) {
          escapado = false;
        } else if (c == '\\') {
          escapado = true;
        } else if (c == '"') {
          enString = false;
        }
        continue;
      }

      if (c == '"') {
        enString = true;
      } else if (c == '{' || c == '[') {
        if (profundidad == 0 && c == '{') desde = i;
        profundidad++;
      } else if (c == '}' || c == ']') {
        profundidad--;
        if (profundidad < 0) break; // cierre del arreglo recetas
        if (profundidad == 0 && c == '}' && desde != -1) {
          try {
            final objeto = jsonDecode(parcial.substring(desde, i + 1));
            if (objeto is Map) objetos.add(Map<String, dynamic>.from(objeto));
          } on FormatException {
            // Objeto mal formado: se salta.
          }
          desde = -1;
        }
      }
    }
    return objetos;
  }

  /// Lee la respuesta cruda del modelo. Descarta las recetas incompletas y
  /// lanza [RecetasRemoteException] si no queda ninguna usable.
  static List<RecetaIaModel> parsearRespuesta(String contenido) {
    final decodificado = _decodificarJson(contenido);

    final List<dynamic> lista;
    if (decodificado is List) {
      lista = decodificado;
    } else if (decodificado is Map && decodificado['recetas'] is List) {
      lista = decodificado['recetas'] as List;
    } else if (decodificado is Map && decodificado['titulo'] != null) {
      lista = [decodificado];
    } else {
      lista = const [];
    }

    final recetas = <RecetaIaModel>[];
    final titulos = <String>{};
    for (final item in lista) {
      if (item is! Map) continue;
      final receta = RecetaIaModel.fromJson(Map<String, dynamic>.from(item));
      // Dos recetas con el mismo titulo tendrian el mismo id.
      if (receta != null && titulos.add(_normalizar(receta.titulo))) {
        recetas.add(receta);
      }
    }

    if (recetas.isEmpty) {
      throw const RecetasRemoteException(
        message: 'La IA no devolvió recetas válidas. Intenta de nuevo.',
      );
    }
    return recetas;
  }

  /// null si falta lo minimo para cocinarla: titulo, ingredientes y pasos.
  static RecetaIaModel? fromJson(Map<String, dynamic> json) {
    final titulo = _texto(json['titulo'] ?? json['title']);
    if (titulo.isEmpty) return null;

    final ingredientes = <IngredienteIa>[];
    final rawIngredientes = json['ingredientes'] ?? json['ingredients'];
    if (rawIngredientes is List) {
      for (final item in rawIngredientes) {
        final ingrediente = IngredienteIa.fromJson(item);
        if (ingrediente != null) ingredientes.add(ingrediente);
      }
    }
    if (ingredientes.isEmpty) return null;

    final pasos = <String>[];
    final rawPasos = json['pasos'] ?? json['instrucciones'] ?? json['steps'];
    if (rawPasos is List) {
      for (final paso in rawPasos) {
        final limpio = _sinNumeracion(_texto(paso));
        if (limpio.isNotEmpty) pasos.add(limpio);
      }
    } else if (rawPasos is String) {
      pasos.addAll(
        rawPasos
            .split('\n')
            .map((p) => _sinNumeracion(p.trim()))
            .where((p) => p.isNotEmpty),
      );
    }
    if (pasos.isEmpty) return null;

    final rawTipos = json['tipos'] ?? json['dishTypes'];
    final tipos = rawTipos is List
        ? rawTipos
              .map((t) => _tipoPlato(_texto(t)))
              .whereType<String>()
              .toSet()
              .toList()
        : const <String>[];

    return RecetaIaModel(
      titulo: _capitalizar(titulo),
      ingredientes: ingredientes,
      pasos: pasos,
      tipos: tipos,
      minutos: _entero(json['minutos'] ?? json['readyInMinutes']),
      porciones: _entero(json['porciones'] ?? json['servings']),
      descripcionImagen: _texto(
        json['imagen'] ?? json['foto'] ?? json['image'],
      ),
    );
  }

  // ------------------------------------------------ conversion a "raw"

  /// Mapa con forma de resultado de busqueda de Spoonacular. Los ingredientes
  /// que el usuario tiene van primero: la tarjeta marca "Tienes" por posicion.
  Map<String, dynamic> toBusquedaRaw(
    List<String> despensa, {
    String imagen = '',
  }) {
    final despensaNorm = despensa
        .map(_normalizar)
        .where((p) => p.length >= 3)
        .toList();

    final enDespensa = <String>[];
    final basicosUsados = <String>[];
    final faltantes = <String>[];

    for (final ingrediente in ingredientes) {
      final nombre = _normalizar(ingrediente.nombre);
      final tiene = despensaNorm.any(
        (p) => nombre.contains(p) || (nombre.length >= 3 && p.contains(nombre)),
      );

      if (tiene) {
        enDespensa.add(ingrediente.texto);
      } else if (basicos.any((b) => nombre == b || nombre.startsWith('$b '))) {
        basicosUsados.add(ingrediente.texto);
      } else {
        faltantes.add(ingrediente.texto);
      }
    }

    final usados = [...enDespensa, ...basicosUsados];

    return {
      'id': id,
      'title': titulo,
      'image': imagen,
      'usedIngredients': [
        for (final n in usados) {'name': n},
      ],
      'missedIngredients': [
        for (final n in faltantes) {'name': n},
      ],
      'usedIngredientCount': usados.length,
      'missedIngredientCount': faltantes.length,
      'readyInMinutes': minutos,
      'dishTypes': tipos,
      'likes': 0,
      'servings': porciones,
      'instructions': instrucciones,
    };
  }

  /// Mapa con la forma que espera `RecetaDetalleRemoteModel.fromApiRaw`.
  Map<String, dynamic> toDetalleRaw(
    List<String> despensa, {
    String imagen = '',
  }) {
    final busqueda = toBusquedaRaw(despensa);
    final ordenados = [
      ...(busqueda['usedIngredients'] as List),
      ...(busqueda['missedIngredients'] as List),
    ];

    return {
      'information': {
        'id': id,
        'title': titulo,
        'image': imagen,
        'readyInMinutes': minutos,
        'servings': porciones,
        'aggregateLikes': 0,
        'dishTypes': tipos,
        'extendedIngredients': ordenados,
        'instructions': instrucciones,
      },
      'equipment': {'equipment': <Map<String, dynamic>>[]},
    };
  }

  /// Pasos numerados, uno por linea.
  String get instrucciones => [
    for (var i = 0; i < pasos.length; i++) '${i + 1}. ${pasos[i]}',
  ].join('\n');

  // ------------------------------------------------------------ utilidades

  static Object? _decodificarJson(String contenido) {
    var texto = contenido
        // Modelos de razonamiento: el pensamiento no es parte de la respuesta.
        .replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '')
        .replaceAll(RegExp(r'```(?:json|JSON)?'), '')
        .trim();

    final inicioObjeto = texto.indexOf('{');
    final inicioLista = texto.indexOf('[');
    final int inicio;
    final String cierre;
    if (inicioObjeto == -1 && inicioLista == -1) {
      throw const RecetasRemoteException(
        message: 'La IA respondió en un formato inesperado. Intenta de nuevo.',
      );
    } else if (inicioLista == -1 ||
        (inicioObjeto != -1 && inicioObjeto < inicioLista)) {
      inicio = inicioObjeto;
      cierre = '}';
    } else {
      inicio = inicioLista;
      cierre = ']';
    }

    final fin = texto.lastIndexOf(cierre);
    if (fin <= inicio) {
      throw const RecetasRemoteException(
        message: 'La respuesta de la IA llegó incompleta. Intenta de nuevo.',
      );
    }
    texto = texto.substring(inicio, fin + 1);

    try {
      return jsonDecode(texto);
    } on FormatException {
      throw const RecetasRemoteException(
        message: 'La IA respondió en un formato inesperado. Intenta de nuevo.',
      );
    }
  }

  /// Traduce los tipos de plato a los valores (en ingles) que entiende
  /// `momento_comida.dart`. Los desconocidos se descartan.
  static String? _tipoPlato(String raw) {
    final t = _normalizar(raw);
    const validos = {
      'breakfast',
      'brunch',
      'morning meal',
      'main course',
      'main dish',
      'lunch',
      'dinner',
      'side dish',
      'salad',
      'soup',
      'snack',
      'dessert',
    };
    if (validos.contains(t)) return t;
    return switch (t) {
      'desayuno' => 'breakfast',
      'almuerzo' => 'lunch',
      'cena' => 'dinner',
      'plato principal' || 'plato fuerte' => 'main course',
      'acompanamiento' || 'guarnicion' => 'side dish',
      'ensalada' => 'salad',
      'sopa' => 'soup',
      'merienda' || 'onces' || 'pasabocas' => 'snack',
      'postre' => 'dessert',
      _ => null,
    };
  }

  static String _texto(Object? valor) => valor?.toString().trim() ?? '';

  static int? _entero(Object? valor) {
    if (valor is num) return valor > 0 ? valor.round() : null;
    final match = RegExp(r'\d+').firstMatch(valor?.toString() ?? '');
    final n = match == null ? null : int.tryParse(match.group(0)!);
    return n != null && n > 0 ? n : null;
  }

  static String _sinNumeracion(String paso) => paso
      .replaceFirst(
        RegExp(r'^(paso\s*)?\d+\s*[.):-]?\s*', caseSensitive: false),
        '',
      )
      .trim();

  static String _capitalizar(String texto) =>
      texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
}

class IngredienteIa {
  const IngredienteIa({required this.nombre, this.cantidad = ''});

  final String nombre;
  final String cantidad;

  /// Texto que se muestra: "Pechuga de pollo (300 g)".
  String get texto {
    final base = RecetaIaModel._capitalizar(nombre);
    return cantidad.isEmpty ? base : '$base ($cantidad)';
  }

  static IngredienteIa? fromJson(Object? raw) {
    if (raw is String) {
      final nombre = raw.trim();
      return nombre.isEmpty ? null : IngredienteIa(nombre: nombre);
    }
    if (raw is! Map) return null;

    final nombre = RecetaIaModel._texto(raw['nombre'] ?? raw['name']);
    if (nombre.isEmpty) return null;
    return IngredienteIa(
      nombre: nombre,
      cantidad: RecetaIaModel._texto(raw['cantidad'] ?? raw['amount']),
    );
  }
}

/// Minusculas, sin tildes y sin espacios sobrantes, para comparar nombres.
String _normalizar(String texto) {
  const conTilde = 'áéíóúüñàèìòù';
  const sinTilde = 'aeiouunaeiou';
  final buffer = StringBuffer();
  for (final c in texto.toLowerCase().trim().split('')) {
    final i = conTilde.indexOf(c);
    buffer.write(i == -1 ? c : sinTilde[i]);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// Hash polinomico del titulo normalizado. Las operaciones se mantienen por
/// debajo de 2^53, asi da el mismo id en Android y en web.
int idRecetaIa(String titulo) {
  const modulo = 1000000007;
  var hash = 0;
  for (final unidad in _normalizar(titulo).codeUnits) {
    hash = (hash * 31 + unidad) % modulo;
  }
  return 1000000000 + hash;
}
