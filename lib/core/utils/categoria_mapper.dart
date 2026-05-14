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