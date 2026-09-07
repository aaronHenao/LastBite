String mapearCategoria(List<String> categoriasApi) {
  final tags = categoriasApi.map((c) => c.toLowerCase()).toList();

  if (tags.any((t) => t.contains('milk') || t.contains('dairy'))) return 'Leche';
  if (tags.any((t) => t.contains('yogurt') || t.contains('yoghurt'))) return 'Yogur';
  if (tags.any((t) => t.contains('cheese'))) return 'Queso';
  if (tags.any((t) => t.contains('butter'))) return 'Mantequilla';
  if (tags.any((t) => t.contains('chicken') || t.contains('poultry'))) return 'Pollo';
  if (tags.any((t) => t.contains('meat') || t.contains('beef') || t.contains('pork'))) return 'Carne';
  if (tags.any((t) => t.contains('fish') || t.contains('seafood'))) return 'Pescado';
  if (tags.any((t) => t.contains('egg'))) return 'Huevo';
  if (tags.any((t) => t.contains('vegetable') || t.contains('veggie'))) return 'Verdura';
  if (tags.any((t) => t.contains('fruit'))) return 'Fruta';
  if (tags.any((t) => t.contains('bread') || t.contains('bakery'))) return 'Pan';
  if (tags.any((t) => t.contains('cereal') || t.contains('grain') || t.contains('pasta') || t.contains('rice'))) return 'Grano';
  if (tags.any((t) => t.contains('juice') || t.contains('beverage') || t.contains('drink'))) return 'Jugo';
  if (tags.any((t) => t.contains('sausage') || t.contains('deli'))) return 'Embutido';
  if (tags.any((t) => t.contains('canned') || t.contains('preserve'))) return 'Conserva';

  return 'Otro';
}
/// Emoji de cada categoria. Fuente unica: antes vivia duplicado en el
/// formulario manual, en la hoja de confirmacion y en el servicio de Open Food
/// Facts, con listas distintas, asi que el mismo producto quedaba guardado con
/// un emoji u otro segun por donde se agregara.
const Map<String, String> _emojiPorCategoria = {
  'Verdura': '🥬',
  'Fruta': '🍎',
  'Hierba': '🌿',
  'Carne': '🥩',
  'Pollo': '🍗',
  'Pescado': '🐟',
  'Huevo': '🥚',
  'Leche': '🥛',
  'Yogur': '🥣',
  'Queso': '🧀',
  'Mantequilla': '🧈',
  'Pan': '🍞',
  'Embutido': '🌭',
  'Jugo': '🧃',
  'Grano': '🌾',
  'Conserva': '🥫',
  'Cereal': '🥣',
  'Otro': '🥫',
};

String emojiParaCategoria(String categoria) {
  final normalizada = categoria.trim().toLowerCase();
  for (final entry in _emojiPorCategoria.entries) {
    if (entry.key.toLowerCase() == normalizada) return entry.value;
  }
  return '🥫';
}

/// Las categorias reales llevan mayuscula inicial ('Fruta', 'Verdura'). La
/// comparacion se hace normalizada porque compararlas en minuscula contra el
/// valor crudo hacia que todo producto escaneado se guardara como no fresco.
bool esCategoriaFresca(String categoria) {
  final normalizada = categoria.trim().toLowerCase();
  return normalizada == 'fruta' ||
      normalizada == 'verdura' ||
      normalizada == 'hierba';
}
