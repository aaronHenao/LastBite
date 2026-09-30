import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lastbite/core/theme/app_theme.dart';
//import 'package:lastbite/features/recetas/data/services/translation_service.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';

/// Bytes de las ilustraciones en data URI, decodificados una sola vez: sin
/// esto cada redibujo decodificaria ~60 KB y la imagen parpadearia.
final Map<String, Uint8List> _bytesPorImagen = {};

/// Imagen de una receta: ilustracion generada por IA (data URI) o URL
/// remota (recetas viejas de Spoonacular). Si falla, [alternativa].
Widget _imagenReceta(String url, {required Widget alternativa}) {
  if (url.startsWith('data:')) {
    var bytes = _bytesPorImagen[url];
    if (bytes == null) {
      try {
        bytes = UriData.parse(url).contentAsBytes();
      } catch (_) {
        return alternativa;
      }
      if (_bytesPorImagen.length >= 40) {
        _bytesPorImagen.remove(_bytesPorImagen.keys.first);
      }
      _bytesPorImagen[url] = bytes;
    }
    return Image.memory(
      bytes,
      width: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, error, stackTrace) => alternativa,
    );
  }

  return Image.network(
    _urlImagenOptimizada(url),
    width: double.infinity,
    fit: BoxFit.cover,
    filterQuality: FilterQuality.high,
    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
    errorBuilder: (_, error, stackTrace) => alternativa,
  );
}

String _urlImagenOptimizada(String originalUrl) {
  if (originalUrl.isEmpty) return originalUrl;

  final highRes = originalUrl.replaceAll('-312x231', '-636x393');
  if (!kIsWeb) return highRes;

  final withoutScheme = highRes.replaceFirst(RegExp(r'^https?://'), '');
  final encoded = Uri.encodeComponent(withoutScheme);
  return 'https://images.weserv.nl/?url=$encoded&w=1200&fit=cover&output=jpg&q=90';
}

class RecetaCard extends StatefulWidget {
  final Receta receta;
  final VoidCallback onTap;

  const RecetaCard({super.key, required this.receta, required this.onTap});

  @override
  State<RecetaCard> createState() => _RecetaCardState();
}

class _RecetaCardState extends State<RecetaCard> {
  //static final TranslationService _translationService = TranslationService();
  static const double _tituloHeight = 42;

  late String _titulo;
  late List<String> _ingredientes;
  bool _traduciendo = false;

  @override
  void initState() {
    super.initState();
    _titulo = widget.receta.titulo;
    _ingredientes = _ingredientesUsados(widget.receta);
    _traducirSiHaceFalta();
  }

  @override
  void didUpdateWidget(RecetaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_debeActualizar(oldWidget.receta, widget.receta)) {
      _titulo = widget.receta.titulo;
      _ingredientes = _ingredientesUsados(widget.receta);
      _traduciendo = false;
      _traducirSiHaceFalta();
    }
  }

  bool _debeActualizar(Receta anterior, Receta actual) {
    if (anterior.id != actual.id) return true;
    if (anterior.titulo != actual.titulo) return true;

    final anteriorIngredientes = anterior.ingredientes ?? const <String>[];
    final actualIngredientes = actual.ingredientes ?? const <String>[];
    if (!listEquals(anteriorIngredientes, actualIngredientes)) return true;

    return false;
  }

  void _traducirSiHaceFalta() {
    if (_traduciendo) return;
    _traduciendo = true;

    final ingredientesUsados = _ingredientesUsados(widget.receta);

    Future.wait([
          //_translationService.translateRecipeTitle(widget.receta.titulo),
          //_translationService.translateIngredients(ingredientesUsados),
        ])
        .then((results) {
          if (!mounted) return;
          setState(() {
            _titulo = results[0] as String;
            _ingredientes = results[1] as List<String>;
            _traduciendo = false;
          });
        })
        .catchError((_) {
          _traduciendo = false;
        });
  }

  List<String> _ingredientesUsados(Receta receta) {
    final base = receta.ingredientes ?? const <String>[];
    if (base.isEmpty) return const <String>[];
    return base.take(receta.ingredientesUsados).toList();
  }

  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;
    final match = receta.porcentajeMatch;
    final matchColor = match >= 80
        ? context.paleta.marca
        : match >= 50
        ? context.paleta.urgente
        : context.paleta.apagado;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.paleta.superficie,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: match == 100
                ? context.paleta.marca.withValues(alpha: 0.5)
                : context.paleta.contorno,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen placeholder ──────────────────────────
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: context.paleta.marcaSuave,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: receta.imagenUrl.isEmpty
                  ? Center(
                      child: Text(
                        _emojiParaReceta(receta.titulo),
                        style: const TextStyle(fontSize: 52),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: _imagenReceta(
                        receta.imagenUrl,
                        alternativa: Center(
                          child: Text(
                            _emojiParaReceta(receta.titulo),
                            style: const TextStyle(fontSize: 52),
                          ),
                        ),
                      ),
                    ),
            ),

            // ── Info ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: _tituloHeight,
                          child: Text(
                            _titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.paleta.tinta,
                            ),
                          ),
                        ),
                      ),
                      // Badge match
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: matchColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: matchColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '$match%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: matchColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Metadatos
                  Row(
                    children: [
                      if (receta.minutosPreparacion != null) ...[
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: context.paleta.apagado,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${receta.minutosPreparacion} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.paleta.apagado,
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 14,
                        color: context.paleta.apagado,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${receta.likes}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.paleta.apagado,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Tags de ingredientes
                  Builder(
                    builder: (context) {
                      const visibles = 2;
                      final mostrados = _ingredientes.take(visibles).toList();
                      final ocultos =
                          receta.ingredientesFaltantes +
                          (_ingredientes.length - mostrados.length);

                      return Row(
                        children: [
                          for (final ingrediente in mostrados) ...[
                            Flexible(
                              child: _IngredientTag(
                                label: ingrediente,
                                tienes: true,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (ocultos > 0)
                            _IngredientTag(
                              label: '+$ocultos más',
                              tienes: false,
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _emojiParaReceta(String titulo) {
    final t = titulo.toLowerCase();
    if (t.contains('espinaca')) return '🥗';
    if (t.contains('pollo')) return '🍗';
    if (t.contains('ensalada')) return '🥙';
    if (t.contains('pasta')) return '🍝';
    if (t.contains('sopa') || t.contains('crema')) return '🍲';
    if (t.contains('tomate')) return '🍅';
    return '🍳';
  }
}

// ── Tag de ingrediente ────────────────────────────────────
class _IngredientTag extends StatelessWidget {
  final String label;
  final bool tienes;

  const _IngredientTag({required this.label, required this.tienes});

  @override
  Widget build(BuildContext context) {
    final color = tienes ? context.paleta.marca : context.paleta.apagado;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      // Un ingrediente largo se recorta en vez de empujar la fila.
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Bottom sheet de detalle ───────────────────────────────
class RecetaDetalleSheet extends StatefulWidget {
  final Receta receta;
  final Future<Receta>? detalleFuture;

  /// Nombres de los productos de la despensa, en minusculas. Las marcas
  /// "Tienes / Falta" se calculan contra esto y no por posicion en la lista:
  /// al llegar el detalle, los ingredientes vienen en otro orden y el conteo
  /// del buscador pasaba a señalar ingredientes al azar.
  final Set<String> productosEnDespensa;

  /// Marca la receta como cocinada: consume de la despensa los productos que
  /// se usaron. Antes el boton principal solo cerraba la hoja.
  final Future<void> Function(Receta receta)? onCocinar;
  final bool isDialog;

  const RecetaDetalleSheet({
    super.key,
    required this.receta,
    this.detalleFuture,
    this.productosEnDespensa = const {},
    this.onCocinar,
    this.isDialog = false,
  });

  @override
  State<RecetaDetalleSheet> createState() => _RecetaDetalleSheetState();
}

class _RecetaDetalleSheetState extends State<RecetaDetalleSheet> {
  late Receta _receta;
  bool _cargandoDetalle = false;
  String? _errorDetalle;

  @override
  void initState() {
    super.initState();
    _receta = widget.receta;
    _cargarDetalleSiExiste();
  }

  bool _tieneIngrediente(String ingrediente) {
    final texto = ingrediente.toLowerCase();
    return widget.productosEnDespensa.any(
      (producto) => producto.isNotEmpty && texto.contains(producto),
    );
  }

  Future<void> _cargarDetalleSiExiste() async {
    final future = widget.detalleFuture;
    if (future == null) return;

    setState(() {
      _cargandoDetalle = true;
      _errorDetalle = null;
    });
    try {
      final detalle = await future;
      if (!mounted) return;
      setState(() => _receta = detalle);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorDetalle =
            'No pudimos cargar la preparación. Revisa tu conexión.',
      );
    } finally {
      if (mounted) setState(() => _cargandoDetalle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final receta = _receta;
    final contenido = _buildContenido(receta);

    if (widget.isDialog) {
      return Container(
        decoration: BoxDecoration(
          color: context.paleta.marcaSuave,
          borderRadius: BorderRadius.circular(24),
        ),
        child: contenido,
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: context.paleta.marcaSuave,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          children: _buildChildren(receta),
        ),
      ),
    );
  }

  Widget _buildContenido(Receta receta) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: _buildChildren(receta),
    );
  }

  List<Widget> _buildChildren(Receta receta) {
    return [
      // Handle — solo en mobile
      if (!widget.isDialog)
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.paleta.contorno,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      // Botón cerrar — solo en dialog
      if (widget.isDialog)
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, right: 4),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: context.paleta.apagado),
            ),
          ),
        ),

      // Imagen
      Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: context.paleta.superficie,
          borderRadius: BorderRadius.circular(18),
        ),
        child: receta.imagenUrl.isEmpty
            ? Center(
                child: Text(
                  _emojiParaReceta(receta.titulo),
                  style: const TextStyle(fontSize: 60),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _imagenReceta(
                  receta.imagenUrl,
                  alternativa: Center(
                    child: Text(
                      _emojiParaReceta(receta.titulo),
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
              ),
      ),
      const SizedBox(height: 16),

      // Título y match
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              receta.titulo,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.paleta.tinta,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.paleta.marca.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.paleta.marca.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              '${receta.porcentajeMatch}% match',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: context.paleta.marca,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),

      // Metadatos
      Row(
        children: [
          if (receta.minutosPreparacion != null) ...[
            Icon(
              Icons.timer_outlined,
              size: 16,
              color: context.paleta.apagado,
            ),
            const SizedBox(width: 4),
            Text(
              '${receta.minutosPreparacion} min',
              style: TextStyle(fontSize: 13, color: context.paleta.apagado),
            ),
            const SizedBox(width: 16),
          ],
          Icon(
            Icons.favorite_border_rounded,
            size: 16,
            color: context.paleta.apagado,
          ),
          const SizedBox(width: 4),
          Text(
            '${receta.likes} likes',
            style: TextStyle(fontSize: 13, color: context.paleta.apagado),
          ),
        ],
      ),
      if (_cargandoDetalle) ...[
        const SizedBox(height: 12),
        LinearProgressIndicator(
          minHeight: 2,
          color: context.paleta.marca,
        ),
      ],
      if (_errorDetalle != null) ...[
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: context.paleta.vencido,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorDetalle!,
                style: TextStyle(fontSize: 13, color: context.paleta.vencido),
              ),
            ),
            TextButton(
              onPressed: _cargarDetalleSiExiste,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ],
      const SizedBox(height: 20),

      // Ingredientes
      Text(
        'INGREDIENTES',
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
          color: context.paleta.apagado,
        ),
      ),
      const SizedBox(height: 10),
      if (receta.ingredientes != null)
        ...receta.ingredientes!.asMap().entries.map((e) {
          final tienes = _tieneIngrediente(e.value);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: context.paleta.superficie,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: tienes
                      ? context.paleta.marca.withValues(alpha: 0.4)
                      : context.paleta.contorno,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.paleta.tinta,
                    ),
                  ),
                  Text(
                    tienes ? '✓ Tienes' : 'Falta',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tienes ? context.paleta.marca : context.paleta.apagado,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      const SizedBox(height: 20),

      // Instrucciones
      if (receta.instrucciones != null) ...[
        Text(
          'PREPARACIÓN',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            color: context.paleta.apagado,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.paleta.superficie,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.paleta.contorno),
          ),
          child: Text(
            receta.instrucciones!,
            style: TextStyle(
              fontSize: 14,
              color: context.paleta.tinta,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],

      // Botón cocinar
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: widget.onCocinar == null
              ? () => Navigator.pop(context)
              : () async {
                  final navigator = Navigator.of(context);
                  final cocinar = widget.onCocinar!;
                  navigator.pop();
                  await cocinar(receta);
                },
          icon: const Icon(Icons.restaurant_menu_rounded),
          style: FilledButton.styleFrom(
            backgroundColor: context.paleta.marca,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          label: Text(
            widget.onCocinar == null ? 'Cerrar' : 'Ya la cociné',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ];
  }

  String _emojiParaReceta(String titulo) {
    final t = titulo.toLowerCase();
    if (t.contains('espinaca')) return '🥗';
    if (t.contains('pollo')) return '🍗';
    if (t.contains('ensalada')) return '🥙';
    if (t.contains('pasta')) return '🍝';
    if (t.contains('sopa') || t.contains('crema')) return '🍲';
    if (t.contains('tomate')) return '🍅';
    return '🍳';
  }
}