import 'dart:async';

import '../datasources/recetas_remote_exception.dart';
import '../models/receta_ia_model.dart';
import 'imagenes_recetas_service.dart';
import 'nvidia_nim_service.dart';
import 'package:lastbite/features/perfil/domain/perfil_nutricional.dart';

/// Genera recetas con un LLM (NVIDIA NIM) directamente en español, cada una
/// con una ilustracion generada por IA.
///
/// Devuelve mapas con forma Spoonacular para que los modelos y pantallas
/// existentes no cambien. Un LLM no puede "volver a pedir" una receta por id,
/// asi que cada receta se genera completa en la busqueda y queda guardada en
/// memoria: [obtenerDetalleRecetaRaw] la resuelve sin otra llamada.
class RecetasService {
  RecetasService({NvidiaNimService? ia, ImagenesRecetasService? imagenes})
    : _ia = ia ?? NvidiaNimService(),
      _imagenes = imagenes ?? ImagenesRecetasService();

  static const int maxRecetasPorBusqueda = 3;

  /// Tope de ingredientes que se mandan al prompt: con mas, el modelo se
  /// dispersa y el prompt gasta tokens sin mejorar las recetas.
  static const int _maxIngredientesPrompt = 25;

  /// Cuantas busquedas recuerda la sesion. Repetir una busqueda (volver a
  /// escribir "pollo") no debe gastar otro credito.
  static const int _maxBusquedasEnMemoria = 30;

  final NvidiaNimService _ia;
  final ImagenesRecetasService _imagenes;

  // Estaticos: cada pantalla crea sus propios datasources, y el detalle de una
  // receta generada desde Recetas tiene que poder leerse desde Alertas.
  static final Map<int, Map<String, dynamic>> _detalles = {};
  static final Map<String, List<Map<String, dynamic>>> _busquedas = {};

  /// Busquedas que todavia esperan a la IA. Si Recetas y Alertas piden lo
  /// mismo a la vez, la segunda espera a la primera en vez de pagar otra.
  static final Map<String, Future<List<Map<String, dynamic>>>> _enCurso = {};

  // Ya no hay traduccion; se mantiene por compatibilidad con los llamadores.
  String? get lastTranslationWarning => null;

  /// Resultado final de la busqueda (recetas con su imagen). Lo usan quienes
  /// no necesitan ver las recetas a medida que llegan, como las alertas.
  Future<List<Map<String, dynamic>>> buscarRecetasPorDespensaRaw({
    required List<String> productosDespensa,
    int number = 3,
    bool ignorePantry = false,
    PerfilNutricional? perfil,
    String? ingredientePrincipal,
  }) async {
    final pedido = _Pedido.de(
      productosDespensa: productosDespensa,
      number: number,
      perfil: perfil,
      ingredientePrincipal: ingredientePrincipal,
    );

    final enMemoria = _busquedas[pedido.clave];
    if (enMemoria != null) return enMemoria;

    final pendiente = _enCurso[pedido.clave];
    if (pendiente != null) return pendiente;

    final futuro = _generar(pedido).last;
    _enCurso[pedido.clave] = futuro;
    try {
      return await futuro;
    } finally {
      _enCurso.remove(pedido.clave);
    }
  }

  /// Igual que [buscarRecetasPorDespensaRaw], pero emite la lista cada vez
  /// que cambia: cuando termina de llegar una receta y cuando llega su
  /// imagen. El ultimo evento es el resultado completo.
  ///
  /// [ingredientePrincipal]: lo que el usuario busco o el producto de una
  /// alerta. Todas las recetas lo usan; [productosDespensa] es contexto para
  /// aprovechar lo que ya hay. [ignorePantry] no aplica a la IA.
  Stream<List<Map<String, dynamic>>> buscarRecetasPorDespensaStream({
    required List<String> productosDespensa,
    int number = 3,
    bool ignorePantry = false,
    PerfilNutricional? perfil,
    String? ingredientePrincipal,
  }) async* {
    final pedido = _Pedido.de(
      productosDespensa: productosDespensa,
      number: number,
      perfil: perfil,
      ingredientePrincipal: ingredientePrincipal,
    );

    final enMemoria = _busquedas[pedido.clave];
    if (enMemoria != null) {
      yield enMemoria;
      return;
    }

    final pendiente = _enCurso[pedido.clave];
    if (pendiente != null) {
      yield await pendiente;
      return;
    }

    yield* _generar(pedido);
  }

  Stream<List<Map<String, dynamic>>> _generar(_Pedido pedido) {
    final controller = StreamController<List<Map<String, dynamic>>>();

    Future<void> ejecutar() async {
      final recetas = <RecetaIaModel>[];
      final imagenes = <int, String>{};
      final pendientes = <Future<void>>[];
      var textoFinal = '';

      List<Map<String, dynamic>> lista() => [
        for (final r in recetas)
          r.toBusquedaRaw(pedido.contexto, imagen: imagenes[r.id] ?? ''),
      ];

      void agregar(RecetaIaModel receta) {
        if (recetas.length >= pedido.cantidad) return;
        // Dos recetas con el mismo titulo tendrian el mismo id.
        if (recetas.any((r) => r.id == receta.id)) return;
        recetas.add(receta);
        controller.add(lista());

        pendientes.add(
          _imagenes
              .generar(
                receta.descripcionImagen.isNotEmpty
                    ? receta.descripcionImagen
                    : receta.titulo,
                semilla: receta.id,
              )
              .then((imagen) {
                if (imagen == null) return;
                imagenes[receta.id] = imagen;
                controller.add(lista());
              }),
        );
      }

      try {
        var procesados = 0;
        await for (final parcial in _ia.completarStream(
          sistema: _promptSistema,
          usuario: _promptUsuario(pedido),
          // Una receta completa en JSON ronda los 250-350 tokens.
          maxTokens: 400 + pedido.cantidad * 800,
          esquemaJson: _esquemaRespuesta,
        )) {
          textoFinal = parcial;
          final objetos = RecetaIaModel.objetosCompletos(parcial);
          for (; procesados < objetos.length; procesados++) {
            final receta = RecetaIaModel.fromJson(objetos[procesados]);
            if (receta != null) agregar(receta);
          }
        }

        // Respuesta con otra forma (sin esquema, markdown...): el parseo
        // completo es mas tolerante que el incremental.
        if (recetas.isEmpty) {
          RecetaIaModel.parsearRespuesta(textoFinal).forEach(agregar);
        }

        await Future.wait(pendientes);

        final resultado = lista();
        for (final receta in recetas) {
          _detalles[receta.id] = receta.toDetalleRaw(
            pedido.contexto,
            imagen: imagenes[receta.id] ?? '',
          );
        }
        if (_busquedas.length >= _maxBusquedasEnMemoria) {
          _busquedas.remove(_busquedas.keys.first);
        }
        _busquedas[pedido.clave] = resultado;
        controller.add(resultado);
      } catch (e, st) {
        controller.addError(e, st);
      } finally {
        await controller.close();
      }
    }

    controller.onListen = ejecutar;
    return controller.stream;
  }

  Future<Map<String, dynamic>> obtenerDetalleRecetaRaw({
    required int recetaId,
  }) async {
    final detalle = _detalles[recetaId];
    if (detalle != null) return detalle;

    // Recetas de sesiones anteriores o de Spoonacular (alertas viejas): su
    // detalle no esta en memoria y no se puede volver a pedir por id.
    throw const RecetasRemoteException(
      message:
          'El detalle de esta receta ya no está disponible. '
          'Actualiza las sugerencias para generar una nueva.',
    );
  }

  // ---------------------------------------------------------------- prompt

  /// Forma exacta que debe devolver el modelo (misma que describe el prompt).
  static const Map<String, dynamic> _esquemaRespuesta = {
    'type': 'object',
    'properties': {
      'recetas': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'titulo': {'type': 'string'},
            'imagen': {'type': 'string'},
            'tipos': {
              'type': 'array',
              'items': {'type': 'string'},
            },
            'minutos': {'type': 'integer'},
            'porciones': {'type': 'integer'},
            'ingredientes': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': {
                  'nombre': {'type': 'string'},
                  'cantidad': {'type': 'string'},
                },
                'required': ['nombre', 'cantidad'],
              },
            },
            'pasos': {
              'type': 'array',
              'items': {'type': 'string'},
            },
          },
          'required': [
            'titulo',
            'imagen',
            'tipos',
            'minutos',
            'porciones',
            'ingredientes',
            'pasos',
          ],
        },
      },
    },
    'required': ['recetas'],
  };

  static const _promptSistema = '''
Eres el chef de LastBite, una app colombiana que ayuda a no desperdiciar comida.
Propones recetas caseras, realistas y fáciles, en español de Colombia.

Responde SOLO con JSON válido, sin texto antes ni después y sin markdown, con esta forma exacta:
{"recetas":[{"titulo":"Arroz con pollo","imagen":"A plate of yellow rice mixed with shredded chicken, peas and carrots","tipos":["main course"],"minutos":40,"porciones":4,"ingredientes":[{"nombre":"pechuga de pollo","cantidad":"500 g"}],"pasos":["Corta el pollo en cubos...","..."]}]}

Reglas:
- "imagen": UNA frase EN INGLÉS que describa cómo se ve el plato servido para dibujarlo: el recipiente (plate, bowl, pan) y los ingredientes visibles con su forma y color. Sin nombres propios de platos.
- "tipos": uno o más de: breakfast, brunch, main course, lunch, dinner, side dish, salad, soup, snack, dessert.
- "minutos": tiempo total en minutos (entero). "porciones": entero.
- "ingredientes": todos los que lleva la receta, con el nombre corto del alimento en minúscula (ej. "tomate", "leche") y la cantidad aparte. Usa los mismos nombres de la despensa cuando sea el mismo alimento.
- "pasos": entre 3 y 8 pasos concretos, sin numerarlos.
- Prioriza los ingredientes que vencen primero. Evita pedir muchos ingredientes que no están en la despensa.
- Puedes asumir que hay sal, pimienta, aceite y agua.
- Cada receta debe ser distinta de las demás.''';

  String _promptUsuario(_Pedido pedido) {
    final buffer = StringBuffer();

    if (pedido.despensa.isNotEmpty) {
      buffer.writeln(
        'Ingredientes en mi despensa (del que vence primero al último): '
        '${pedido.despensa.join(', ')}.',
      );
    }

    if (pedido.principal.isNotEmpty) {
      // Con "deben usar o estar relacionadas" el modelo a veces devolvia una
      // receta sin lo buscado (arepas con carne al buscar "pollo").
      buffer.writeln(
        'OBLIGATORIO: las ${pedido.cantidad} recetas deben ser de '
        '"${pedido.principal}": tiene que ser el protagonista y aparecer en '
        '"ingredientes" (o, si es un plato, ser ese plato). Usa la despensa '
        'solo para acompañarlo.',
      );
    }

    final restricciones = _restriccionesPerfil(pedido.perfil);
    if (restricciones.isNotEmpty) {
      buffer.writeln('Mi perfil alimentario (obligatorio respetarlo):');
      for (final r in restricciones) {
        buffer.writeln('- $r');
      }
    }

    buffer.write(
      pedido.cantidad == 1
          ? 'Dame 1 receta.'
          : 'Dame ${pedido.cantidad} recetas diferentes.',
    );
    return buffer.toString();
  }

  List<String> _restriccionesPerfil(PerfilNutricional? perfil) {
    if (perfil == null) return const [];

    final lineas = <String>[];

    switch (perfil.dietaryType) {
      case 'vegetarian':
        lineas.add('Dieta vegetariana: sin carne, pollo ni pescado.');
      case 'vegan':
        lineas.add(
          'Dieta vegana: ningún producto de origen animal '
          '(ni huevo, lácteos ni miel).',
        );
    }

    if (perfil.allergies.isNotEmpty) {
      lineas.add(
        'Alergias o intolerancias, NUNCA incluir: '
        '${perfil.allergies.join(', ')}.',
      );
    }

    if (perfil.restrictions.isNotEmpty) {
      lineas.add('No como: ${perfil.restrictions.join(', ')}.');
    }

    if (perfil.userType == 'athlete') {
      lineas.add('Soy deportista: recetas altas en proteína.');
    } else if (perfil.userType == 'nutritional_plan') {
      switch (perfil.goal) {
        case 'lose_weight':
          lineas.add('Quiero perder peso: recetas bajas en calorías.');
        case 'gain_weight':
          lineas.add('Quiero ganar peso: recetas con más calorías y proteína.');
        case 'maintain_weight':
          lineas.add('Quiero mantener mi peso: recetas balanceadas.');
      }
    }

    return lineas;
  }
}

/// Parametros normalizados de una busqueda y su clave de memoria.
class _Pedido {
  _Pedido._({
    required this.despensa,
    required this.principal,
    required this.cantidad,
    required this.perfil,
  });

  factory _Pedido.de({
    required List<String> productosDespensa,
    required int number,
    required PerfilNutricional? perfil,
    required String? ingredientePrincipal,
  }) {
    final vistos = <String>{};
    final despensa = <String>[];
    for (final producto in productosDespensa) {
      final limpio = producto.trim();
      if (limpio.isEmpty) continue;
      if (vistos.add(limpio.toLowerCase())) despensa.add(limpio);
      if (despensa.length == RecetasService._maxIngredientesPrompt) break;
    }

    final principal = ingredientePrincipal?.trim() ?? '';
    if (despensa.isEmpty && principal.isEmpty) {
      throw const RecetasRemoteException(
        message: 'No hay ingredientes válidos para buscar recetas',
      );
    }

    return _Pedido._(
      despensa: despensa,
      principal: principal,
      cantidad: number.clamp(1, RecetasService.maxRecetasPorBusqueda).toInt(),
      perfil: perfil,
    );
  }

  final List<String> despensa;
  final String principal;
  final int cantidad;
  final PerfilNutricional? perfil;

  String get clave => [
    principal.toLowerCase(),
    cantidad,
    despensa.join(','),
    perfil?.cacheKey ?? '',
  ].join('|');

  /// Lo buscado cuenta como disponible solo para calcular el match cuando no
  /// hay despensa: si no, toda receta saldria con 0 %.
  List<String> get contexto => despensa.isEmpty ? [principal] : despensa;
}
