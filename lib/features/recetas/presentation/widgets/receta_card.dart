import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/recetas/domain/receta.dart';

String _urlImagenOptimizada(String originalUrl) {
  if (originalUrl.isEmpty) return originalUrl;

  final highRes = originalUrl.replaceAll('-312x231', '-636x393');
  if (!kIsWeb) return highRes;

  final withoutScheme = highRes.replaceFirst(RegExp(r'^https?://'), '');
  final encoded = Uri.encodeComponent(withoutScheme);
  return 'https://images.weserv.nl/?url=$encoded&w=1200&fit=cover&output=jpg&q=90';
}

class RecetaCard extends StatelessWidget {
  final Receta receta;
  final VoidCallback onTap;

  const RecetaCard({super.key, required this.receta, required this.onTap});

  static const double _tituloHeight = 42;

  static const TextStyle _tituloStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
  );

  List<String> _ingredientesUsados(Receta r) {
    final base = r.ingredientes ?? const <String>[];
    if (base.isEmpty) return const <String>[];
    return base.take(r.ingredientesUsados).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ingredientes = _ingredientesUsados(receta);
    final match = receta.porcentajeMatch;
    final matchColor = match >= 80
        ? AppColors.green
        : match >= 50
        ? AppColors.yellow
        : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: match == 100
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.surface,
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
                      child: Image.network(
                        _urlImagenOptimizada(receta.imagenUrl),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                        errorBuilder: (_, error, stackTrace) => Center(
                          child: Text(
                            _emojiParaReceta(receta.titulo),
                            style: const TextStyle(fontSize: 52),
                          ),
                        ),
                      ),
                    ),
            ),
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
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              receta.titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _tituloStyle,
                            ),
                          ),
                        ),
                      ),
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
                  Row(
                    children: [
                      if (receta.minutosPreparacion != null) ...[
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${receta.minutosPreparacion} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${receta.likes}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...ingredientes.map(
                        (label) => _IngredientTag(
                          label: label,
                          tienes: true,
                        ),
                      ),
                      if (receta.ingredientesFaltantes > 0)
                        _IngredientTag(
                          label: '+${receta.ingredientesFaltantes} más',
                          tienes: false,
                        ),
                    ],
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

class _IngredientTag extends StatelessWidget {
  final String label;
  final bool tienes;

  const _IngredientTag({required this.label, required this.tienes});

  @override
  Widget build(BuildContext context) {
    final color = tienes ? AppColors.green : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class RecetaDetalleSheet extends StatefulWidget {
  final Receta receta;
  final Future<Receta>? detalleFuture;

  const RecetaDetalleSheet({
    super.key,
    required this.receta,
    this.detalleFuture,
  });

  @override
  State<RecetaDetalleSheet> createState() => _RecetaDetalleSheetState();
}

class _RecetaDetalleSheetState extends State<RecetaDetalleSheet> {
  late Receta _receta;
  bool _cargandoDetalle = false;

  static const TextStyle _tituloDetalleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textMain,
  );

  static const TextStyle _instruccionesStyle = TextStyle(
    fontSize: 14,
    color: AppColors.textMain,
    height: 1.6,
  );

  @override
  void initState() {
    super.initState();
    _receta = widget.receta;
    _cargarDetalleSiExiste();
  }

  Future<void> _cargarDetalleSiExiste() async {
    final future = widget.detalleFuture;
    if (future == null) return;

    setState(() => _cargandoDetalle = true);
    try {
      final detalle = await future;
      if (!mounted) return;
      setState(() => _receta = detalle);
    } catch (_) {
      // Keep the base recipe data if full detail loading fails.
    } finally {
      if (mounted) setState(() => _cargandoDetalle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final receta = _receta;
    final instruccionesRaw = receta.instrucciones;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.card,
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
                          child: Image.network(
                            _urlImagenOptimizada(receta.imagenUrl),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.prefer,
                            errorBuilder: (_, error, stackTrace) => Center(
                              child: Text(
                                _emojiParaReceta(receta.titulo),
                                style: const TextStyle(fontSize: 60),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          receta.titulo,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: _tituloDetalleStyle,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${receta.porcentajeMatch}% match',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (receta.minutosPreparacion != null) ...[
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${receta.minutosPreparacion} min',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  const Icon(
                    Icons.favorite_border_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${receta.likes} likes',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (_cargandoDetalle) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(minHeight: 2),
              ],
              const SizedBox(height: 20),
              const Text(
                'INGREDIENTES',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              if (receta.ingredientes != null)
                ...receta.ingredientes!.asMap().entries.map((e) {
                  final tienes = e.key < receta.ingredientesUsados;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: tienes
                              ? AppColors.green.withValues(alpha: 0.4)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              e.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textMain,
                              ),
                            ),
                          ),
                          Text(
                            tienes ? '✓ Tienes' : 'Falta',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: tienes
                                  ? AppColors.green
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 20),
              if (instruccionesRaw != null &&
                  instruccionesRaw.trim().isNotEmpty) ...[
                const Text(
                  'PREPARACIÓN',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(instruccionesRaw, style: _instruccionesStyle),
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.restaurant_menu_rounded),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  label: const Text(
                    '¡Vamos a cocinar!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
