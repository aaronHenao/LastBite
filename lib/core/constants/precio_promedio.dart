/// Precio promedio estimado por producto salvado, en COP.
/// Estimación gruesa para la métrica de ahorro — no es un precio real de mercado.
/// Fuente: <completar> · Actualizado: <fecha>
const Map<String, int> precioPromedioPorCategoria = {
  'Verdura':     3000,
  'Fruta':       4000,
  'Hierba':      2000,
  'Carne':      18000,
  'Pollo':      12000,
  'Pescado':    16000,
  'Huevo':       9000,
  'Leche':       4500,
  'Yogur':       5000,
  'Queso':      12000,
  'Mantequilla': 9000,
  'Pan':         4000,
  'Embutido':   10000,
  'Jugo':        5000,
  'Grano':       6000,
  'Conserva':    5000,
  'Cereal':      8000,
  'Otro':        5000,
};

int precioEstimado(String categoria) {
  final categoriaMinuscula = categoria.trim().toLowerCase();
  final match = precioPromedioPorCategoria.entries.firstWhere(
    (entry) => entry.key.toLowerCase() == categoriaMinuscula,
    orElse: () => const MapEntry('Otro', 5000),
  );
  return match.value;
}

/// Suma el ahorro estimado de un mapa `categoría -> unidades salvadas`.
int ahorroEstimado(Map<String, int> conteoPorCategoria) {
  return conteoPorCategoria.entries.fold(
    0,
    (total, e) => total + precioEstimado(e.key) * e.value,
  );
}
