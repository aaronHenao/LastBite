import 'package:shared_preferences/shared_preferences.dart';

/// Guarda en el dispositivo las ultimas busquedas de Consulta rapida.
///
/// La evaluacion marco "reconocimiento en vez de memoria": 4 de 8
/// evaluadores no podian volver a localizar algo que ya habian buscado.
class HistorialBusquedaRepository {
  static const _clave = 'consulta_rapida_historial';
  static const _maximo = 8;

  Future<List<String>> obtener() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_clave) ?? const [];
  }

  Future<List<String>> agregar(String busqueda) async {
    final termino = busqueda.trim();
    if (termino.isEmpty) return obtener();

    final prefs = await SharedPreferences.getInstance();
    final actual = prefs.getStringList(_clave) ?? const [];
    final actualizado = [
      termino,
      ...actual.where((t) => t.toLowerCase() != termino.toLowerCase()),
    ].take(_maximo).toList();

    await prefs.setStringList(_clave, actualizado);
    return actualizado;
  }

  Future<List<String>> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clave);
    return const [];
  }
}
