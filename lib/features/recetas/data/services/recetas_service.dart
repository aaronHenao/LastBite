import '../datasources/my_memory_translate_service.dart';
import '../datasources/recetas_remote_exception.dart';
import 'spoon_service.dart';
import 'package:lastbite/features/perfil/domain/perfil_nutricional.dart';

class RecetasService {
  RecetasService({SpoonService? spoon, MyMemoryTranslateService? translator})
    : _spoon = spoon ?? SpoonService(),
      _translator = translator ?? MyMemoryTranslateService();

  static const int maxRecetasPorBusqueda = 3;

  final SpoonService _spoon;
  final MyMemoryTranslateService _translator;

  // Ya no hay warnings de traducción pero mantenemos el getter
  // para no romper código que lo use
  String? get lastTranslationWarning => null;

  Future<List<Map<String, dynamic>>> buscarRecetasPorDespensaRaw({
    required List<String> productosDespensa,
    int number = 3,
    bool ignorePantry = false,
    PerfilNutricional? perfil,
  }) async {
    final numberLimitado = number.clamp(1, maxRecetasPorBusqueda).toInt();
    final normalizados = _normalizarIngredientes(productosDespensa);

    // ES → EN para Spoonacular
    final ingredientesEn = await _translator.ingredientesEsAEn(normalizados);

    if (ingredientesEn.isEmpty) {
      throw const RecetasRemoteException(
        message: 'No hay ingredientes válidos para buscar recetas',
      );
    }

    final raw = perfil?.hasRecipePreferences == true
        ? await _spoon.searchComplex(
            ingredients: ingredientesEn,
            number: numberLimitado,
            diet: _dietFilter(perfil!),
            intolerances: perfil.allergies,
            excludedIngredients: perfil.restrictions,
            sort: _sortFilter(perfil),
            sortDirection: _sortDirection(perfil),
          )
        : await _spoon.findByIngredients(
            ingredients: ingredientesEn,
            number: numberLimitado,
            ignorePantry: ignorePantry,
            ranking: 1,
          );

    final capped = raw.take(maxRecetasPorBusqueda).toList();
    final conTiempos = await _agregarTiemposPreparacion(capped);
    return _traducirResultados(conTiempos);
  }

  Future<Map<String, dynamic>> obtenerDetalleRecetaRaw({
    required int recetaId,
  }) async {
    final info = await _spoon.getRecipeInformation(recipeId: recetaId);
    final traducido = await _traducirDetalle(info);
    return {
      'information': traducido,
      'equipment': {'equipment': <Map<String, dynamic>>[]},
    };
  }

  Future<List<Map<String, dynamic>>> _agregarTiemposPreparacion(
    List<Map<String, dynamic>> raw,
  ) async {
    if (raw.isEmpty) return raw;

    final ids = raw
        .map((r) => (r['id'] as num?)?.toInt())
        .whereType<int>()
        .toList();

    if (ids.isEmpty) return raw;

    try {
      final info = await _spoon.getRecipeInformationBulk(recipeIds: ids);

      final minutosPorId = <int, int>{};
      final tiposPorId = <int, List<String>>{};
      for (final item in info) {
        final id = (item['id'] as num?)?.toInt();
        if (id == null) continue;

        final minutos = (item['readyInMinutes'] as num?)?.toInt();
        if (minutos != null) minutosPorId[id] = minutos;

        final tipos = (item['dishTypes'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
        if (tipos != null && tipos.isNotEmpty) tiposPorId[id] = tipos;
      }

      return raw.map((recipe) {
        final id = (recipe['id'] as num?)?.toInt();
        if (id == null) return recipe;

        final minutos = minutosPorId[id];
        final tipos = tiposPorId[id];
        if (minutos == null && tipos == null) return recipe;

        return {
          ...recipe,
          'readyInMinutes': ?minutos,
          'dishTypes': ?tipos,
        };
      }).toList();
    } on RecetasRemoteException {
      return raw;
    }
  }

  // ── Traducción de resultados de búsqueda ──────────────

  Future<List<Map<String, dynamic>>> _traducirResultados(
    List<Map<String, dynamic>> raw,
  ) async {
    if (raw.isEmpty) return raw;

    // Recolecta títulos e ingredientes únicos
    final titulos = raw
        .map((r) => r['title']?.toString() ?? '')
        .where((t) => t.isNotEmpty)
        .toList();

    final todosIngredientes = <String>{};
    for (final recipe in raw) {
      for (final key in ['usedIngredients', 'missedIngredients']) {
        final list = recipe[key];
        if (list is! List) continue;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final name = item['name']?.toString() ?? '';
            if (name.isNotEmpty) todosIngredientes.add(name);
          }
        }
      }
    }

    // Dos llamadas en paralelo — títulos e ingredientes al mismo tiempo
    final resultados = await Future.wait([
      _translator.traducirLista(
        textos: titulos,
        de: 'en',
        a: 'es',
        contexto: 'recipe title latin american cooking',
      ),
      _translator.ingredientesEnAEs(todosIngredientes.toList()),
    ]);

    final titulosEs = resultados[0];
    final ingredientesEs = resultados[1];

    final tituloMap = Map.fromIterables(titulos, titulosEs);
    final ingredienteMap = Map.fromIterables(
      todosIngredientes.toList(),
      ingredientesEs,
    );

    return raw.map((recipe) {
      final copy = Map<String, dynamic>.from(recipe);

      final titulo = copy['title']?.toString() ?? '';
      if (titulo.isNotEmpty) copy['title'] = tituloMap[titulo] ?? titulo;

      for (final key in ['usedIngredients', 'missedIngredients']) {
        final list = copy[key];
        if (list is! List) continue;
        copy[key] = list.map((item) {
          if (item is! Map<String, dynamic>) return item;
          final itemCopy = Map<String, dynamic>.from(item);
          final name = itemCopy['name']?.toString() ?? '';
          if (name.isNotEmpty) {
            itemCopy['name'] = ingredienteMap[name] ?? name;
          }
          return itemCopy;
        }).toList();
      }

      return copy;
    }).toList();
  }

  // ── Traducción del detalle ────────────────────────────

  Future<Map<String, dynamic>> _traducirDetalle(
    Map<String, dynamic> info,
  ) async {
    final copy = Map<String, dynamic>.from(info);

    // Recolecta nombres de ingredientes
    final extendedIngredients = copy['extendedIngredients'];
    final nombres = extendedIngredients is List
        ? extendedIngredients
              .whereType<Map<String, dynamic>>()
              .map((item) => item['name']?.toString() ?? '')
              .where((n) => n.isNotEmpty)
              .toList()
        : <String>[];

    // Título e ingredientes en paralelo, instrucciones aparte
    // (instrucciones puede ser texto largo, mejor separado)
    final titulo = copy['title']?.toString() ?? '';
    final instrucciones = copy['instructions']?.toString() ?? '';

    final resultadosParalelos = await Future.wait([
      titulo.isNotEmpty
          ? _translator.tituloEnAEs(titulo)
          : Future.value(titulo),
      nombres.isNotEmpty
          ? _translator.ingredientesEnAEs(nombres)
          : Future.value(<String>[]),
    ]);

    if (titulo.isNotEmpty) copy['title'] = resultadosParalelos[0];

    // Traduce instrucciones separado porque es texto largo
    if (instrucciones.isNotEmpty) {
      copy['instructions'] = await _translator.instruccionesEnAEs(
        instrucciones,
      );
    }

    // Actualiza ingredientes traducidos
    final nombresEs = resultadosParalelos[1] as List<String>;
    if (extendedIngredients is List && nombresEs.isNotEmpty) {
      final nombreMap = Map.fromIterables(nombres, nombresEs);
      copy['extendedIngredients'] = extendedIngredients.map((item) {
        if (item is! Map<String, dynamic>) return item;
        final itemCopy = Map<String, dynamic>.from(item);
        final name = itemCopy['name']?.toString() ?? '';
        if (name.isNotEmpty) {
          itemCopy['name'] = nombreMap[name] ?? name;
        }
        return itemCopy;
      }).toList();
    }

    return copy;
  }

  List<String> _normalizarIngredientes(List<String> productos) {
    return productos
        .map((p) => p.trim().toLowerCase())
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();
  }

  String? _dietFilter(PerfilNutricional perfil) {
    switch (perfil.dietaryType) {
      case 'vegetarian':
        return 'vegetarian';
      case 'vegan':
        return 'vegan';
      default:
        return null;
    }
  }

  String? _sortFilter(PerfilNutricional perfil) {
    if (perfil.userType == 'athlete') return 'protein';
    if (perfil.userType == 'nutritional_plan') {
      switch (perfil.goal) {
        case 'lose_weight':
          return 'calories';
        case 'maintain_weight':
          return 'max-used-ingredients';
        case 'gain_weight':
          return 'calories';
      }
    }
    return 'max-used-ingredients';
  }

  String _sortDirection(PerfilNutricional perfil) {
    if (perfil.userType == 'athlete') return 'desc';
    if (perfil.userType == 'nutritional_plan' && perfil.goal == 'gain_weight') {
      return 'desc';
    }
    return 'asc';
  }
}
