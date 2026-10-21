/// Texto comparable: minusculas, sin tildes y con un solo espacio entre
/// palabras. "  Limón " y "limon" quedan iguales.
String normalizarTexto(String texto) {
  const conTilde = 'áéíóúüñàèìòù';
  const sinTilde = 'aeiouunaeiou';
  final buffer = StringBuffer();
  for (final c in texto.toLowerCase().trim().split('')) {
    final i = conTilde.indexOf(c);
    buffer.write(i == -1 ? c : sinTilde[i]);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// Si [consulta] encuentra [texto] en un buscador.
///
/// La evaluacion heuristica marco que el buscador no perdonaba nada: un
/// espacio de mas, una tilde o "entera leche" en vez de "leche entera" ya no
/// encontraban el producto. Aca da igual el orden de las palabras, las tildes
/// y las mayusculas, y cada palabra de 5 letras o mas admite un error de
/// tipeo ("lehce" encuentra "leche"). En palabras mas cortas un error ya
/// cambia de alimento: "pera" no deberia encontrar "perejil".
bool coincideBusqueda(String texto, String consulta) {
  final buscadas = _palabras(consulta);
  if (buscadas.isEmpty) return true;

  final palabras = _palabras(texto);
  return buscadas.every((b) => palabras.any((p) => _parecida(p, b)));
}

List<String> _palabras(String texto) => normalizarTexto(
  texto,
).split(RegExp(r'[^a-z0-9]+')).where((p) => p.isNotEmpty).toList();

/// [buscada] es el comienzo de [palabra], con a lo sumo un error si es larga.
bool _parecida(String palabra, String buscada) {
  if (palabra.startsWith(buscada)) return true;
  if (buscada.length < 5) return false;

  // Contra prefijos de largo vecino: asi cuenta como un solo error tanto una
  // letra de mas como una de menos.
  for (final largo in [
    buscada.length - 1,
    buscada.length,
    buscada.length + 1,
  ]) {
    if (largo > palabra.length) break;
    if (_distancia(palabra.substring(0, largo), buscada) <= 1) return true;
  }
  return false;
}

/// Distancia de edicion con transposiciones: "lehce" esta a 1 de "leche".
int _distancia(String a, String b) {
  final d = List.generate(
    a.length + 1,
    (i) => List.generate(b.length + 1, (j) => i == 0 ? j : (j == 0 ? i : 0)),
  );

  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final costo = a[i - 1] == b[j - 1] ? 0 : 1;
      var mejor = [
        d[i - 1][j] + 1,
        d[i][j - 1] + 1,
        d[i - 1][j - 1] + costo,
      ].reduce((x, y) => x < y ? x : y);
      if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1]) {
        mejor = mejor < d[i - 2][j - 2] + 1 ? mejor : d[i - 2][j - 2] + 1;
      }
      d[i][j] = mejor;
    }
  }
  return d[a.length][b.length];
}
