import 'package:lastbite/services/translation_service.dart';

import '../datasources/recetas_remote_exception.dart';
import 'spoon_service.dart';

class RecetasService {
  RecetasService({SpoonService? spoon, TranslationService? translation})
    : _spoon = spoon ?? SpoonService(),
      _translation = translation ?? TranslationService();

  static const int maxRecetasPorBusqueda = 3;

  final SpoonService _spoon;
  final TranslationService _translation;

  Future<List<Map<String, dynamic>>> buscarRecetasPorDespensaRaw({
    required List<String> productosDespensa,
    int number = 3,
    bool ignorePantry = false,
  }) async {
    final numberLimitado = number.clamp(1, maxRecetasPorBusqueda).toInt();

    final ingredientesNormalizados = _normalizarIngredientes(productosDespensa);
    final ingredientes = await _translation.translatePantryToEnglish(
      ingredientesNormalizados,
    );

    if (ingredientes.isEmpty) {
      throw const RecetasRemoteException(
        message: 'No hay ingredientes validos en despensa para buscar recetas',
      );
    }

    final raw = await _spoon.findByIngredients(
      ingredients: ingredientes,
      number: numberLimitado,
      ignorePantry: ignorePantry,
      ranking: 1,
    );

    final capped = raw.take(maxRecetasPorBusqueda).toList();
    final pantryEn = ingredientes
        .map((e) => e.toLowerCase().trim())
        .where((e) => e.length >= 2)
        .toList();
    final pantryEs = ingredientesNormalizados
        .map((e) => e.toLowerCase().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final ajustado = pantryEn.isEmpty
        ? capped
        : capped
              .map(
                (r) => _corregirUsadosContraDespensa(
                  pantryEn: pantryEn,
                  pantryEs: pantryEs,
                  recipe: r,
                ),
              )
              .toList();
    return _traducirResultadosBusqueda(ajustado);
  }

  Future<Map<String, dynamic>> obtenerDetalleRecetaRaw({
    required int recetaId,
  }) async {
    final infoData = await _spoon.getRecipeInformation(recipeId: recetaId);
    final translatedInfo = await _traducirInfo(infoData);

    return {
      'information': translatedInfo,
      'equipment': {'equipment': <Map<String, dynamic>>[]},
    };
  }

  Future<List<Map<String, dynamic>>> _traducirResultadosBusqueda(
    List<Map<String, dynamic>> raw,
  ) async {
    if (raw.isEmpty) return raw;

    final titles = raw
        .map((item) => item['title']?.toString() ?? '')
        .where((title) => title.trim().isNotEmpty)
        .toList();

    final ingredientNames = <String>{};

    for (final recipe in raw) {
      for (final key in const ['usedIngredients', 'missedIngredients']) {
        final list = recipe[key];
        if (list is! List) continue;

        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;
          final name = item['name']?.toString() ?? '';
          if (name.trim().isNotEmpty) ingredientNames.add(name);
        }
      }
    }

    final ingredientList = ingredientNames.toList();

    final translatedTitles = titles.isEmpty
        ? <String>[]
        : await Future.wait(
            titles.map(_translation.translateRecipeTitle),
          );

    final translatedIngredients = ingredientList.isEmpty
        ? <String>[]
        : await _translation.translateIngredients(ingredientList);

    final ingredientMap = <String, String>{};
    for (var i = 0; i < ingredientList.length; i++) {
      ingredientMap[ingredientList[i]] = translatedIngredients[i];
    }

    final translated = <Map<String, dynamic>>[];
    var titleIndex = 0;

    for (final recipe in raw) {
      final copy = Map<String, dynamic>.from(recipe);

      final originalTitle = copy['title']?.toString() ?? '';
      if (originalTitle.trim().isNotEmpty &&
          titleIndex < translatedTitles.length) {
        copy['title'] = translatedTitles[titleIndex];
        titleIndex++;
      }

      for (final key in const ['usedIngredients', 'missedIngredients']) {
        final list = copy[key];
        if (list is! List) continue;

        copy[key] = list.map((item) {
          if (item is! Map<String, dynamic>) return item;
          final itemCopy = Map<String, dynamic>.from(item);
          final original = itemCopy['name']?.toString() ?? '';
          final translatedName = ingredientMap[original];
          if (translatedName != null && translatedName.trim().isNotEmpty) {
            itemCopy['name'] = translatedName;
          }
          return itemCopy;
        }).toList();
      }

      translated.add(copy);
    }

    return translated;
  }

  Future<Map<String, dynamic>> _traducirInfo(Map<String, dynamic> info) async {
    final copy = Map<String, dynamic>.from(info);

    final title = copy['title']?.toString() ?? '';

    final extendedIngredients = copy['extendedIngredients'];
    final names = extendedIngredients is List
        ? extendedIngredients
              .whereType<Map<String, dynamic>>()
              .map((item) => item['name']?.toString() ?? '')
              .where((name) => name.trim().isNotEmpty)
              .toList()
        : <String>[];

    final translatedTitle = title.trim().isEmpty
        ? ''
        : await _translation.translateRecipeTitle(title.trim());

    final translatedIngredientNames = names.isEmpty
        ? <String>[]
        : await _translation.translateIngredients(names);

    if (translatedTitle.trim().isNotEmpty) {
      copy['title'] = translatedTitle;
    }

    if (extendedIngredients is List && extendedIngredients.isNotEmpty) {
      var idx = 0;
      copy['extendedIngredients'] = extendedIngredients.map((item) {
        if (item is! Map<String, dynamic>) return item;
        final itemCopy = Map<String, dynamic>.from(item);
        final originalName = itemCopy['name']?.toString() ?? '';
        if (originalName.trim().isNotEmpty &&
            idx < translatedIngredientNames.length) {
          itemCopy['name'] = translatedIngredientNames[idx];
          idx++;
        }
        return itemCopy;
      }).toList();
    }

    return copy;
  }

  List<String> _normalizarIngredientes(List<String> productosDespensa) {
    return productosDespensa
        .map(_condensarNombreParaBusqueda)
        .map((producto) => producto.trim().toLowerCase())
        .where((producto) => producto.isNotEmpty)
        .toSet()
        .toList();
  }

  String _condensarNombreParaBusqueda(String raw) {
    var s = raw.split(',').first.trim();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    if (s.length > 72) {
      s = s.substring(0, 72).trim();
    }
    return s;
  }

  Map<String, dynamic> _corregirUsadosContraDespensa({
    required List<String> pantryEn,
    required List<String> pantryEs,
    required Map<String, dynamic> recipe,
  }) {
    final copy = Map<String, dynamic>.from(recipe);
    final used = _asIngredientMapList(copy['usedIngredients']);
    final missed = _asIngredientMapList(copy['missedIngredients']);

    final usedReal = <Map<String, dynamic>>[];
    final falsosPositivos = <Map<String, dynamic>>[];

    for (final item in used) {
      if (_ingredienteCoincideConDespensa(item, pantryEn, pantryEs)) {
        usedReal.add(item);
      } else {
        falsosPositivos.add(item);
      }
    }

    final missedNuevo = [...missed, ...falsosPositivos];
    copy['usedIngredients'] = usedReal;
    copy['missedIngredients'] = missedNuevo;
    copy['usedIngredientCount'] = usedReal.length;
    copy['missedIngredientCount'] = missedNuevo.length;
    return copy;
  }

  List<Map<String, dynamic>> _asIngredientMapList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  bool _ingredienteCoincideConDespensa(
    Map<String, dynamic> item,
    List<String> pantryEn,
    List<String> pantryEs,
  ) {
    final nombres = <String?>[
      item['name']?.toString(),
      item['originalName']?.toString(),
      item['original']?.toString(),
    ];
    for (final n in nombres) {
      if (n == null || n.trim().isEmpty) continue;
      for (final p in pantryEn) {
        if (_coincidenciaFlexibleDespensa(n, p)) return true;
      }
      for (final p in pantryEs) {
        if (_coincidenciaFlexibleDespensa(n, p)) return true;
      }
    }
    return false;
  }

  String _asciiFold(String s) {
    var o = s.toLowerCase();
    const pairs = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n',
      'à': 'a', 'è': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u',
    };
    for (final e in pairs.entries) {
      o = o.replaceAll(e.key, e.value);
    }
    return o;
  }

  bool _coincidenciaFlexibleDespensa(String ingredienteApi, String pantry) {
    final ing = _asciiFold(ingredienteApi.trim());
    final p = _asciiFold(pantry.trim());
    if (ing.isEmpty || p.length < 2) return false;
    if (ing == p) return true;
    try {
      if (RegExp(r'\b' + RegExp.escape(p) + r'\b').hasMatch(ing)) return true;
      if (RegExp(r'\b' + RegExp.escape(ing) + r'\b').hasMatch(p)) return true;
    } catch (_) {}
    if (p.length >= 3) {
      if (ing == '${p}s' || ing == '${p}es') return true;
      if (p == '${ing}s' || p == '${ing}es') return true;
    }
    if (p.length >= 3 && ing.length >= 3) {
      if (ing.contains(p) || p.contains(ing)) return true;
    }
    return false;
  }
}
