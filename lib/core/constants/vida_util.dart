const Map<String, int> vidaUtilPorCategoria = {
  'Verdura':     7,
  'Fruta':       7,
  'Hierba':      5,
  'Carne':       3,
  'Pollo':       3,
  'Pescado':     2,
  'Huevo':       21,
  'Leche':       8,
  'Yogur':       14,
  'Queso':       21,
  'Mantequilla': 30,
  'Pan':         5,
  'Embutido':    7,
  'Jugo':        7,
  'Grano':       365,
  'Conserva':    365,
  'Cereal':      180,
  'Otro':        7,
};

int vidaUtilRecomendada(String categoria) {
  final vidaUtilMiniscula = categoria.trim().toLowerCase();
  final match = vidaUtilPorCategoria.entries.firstWhere(
    (entry) => entry.key.toLowerCase() == vidaUtilMiniscula,
    orElse: () => const MapEntry('Otro', 7),
  );
  return match.value;
}
