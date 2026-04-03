import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastbite/core/constants/unidades_medida.dart';
import 'package:lastbite/core/constants/vida_util.dart';
import 'package:lastbite/core/theme/app_theme.dart';

enum _EntryMode { scan, manual }

class AgregarScreen extends StatefulWidget {
  final VoidCallback? onBackToPantry;

  const AgregarScreen({super.key, this.onBackToPantry});

  @override
  State<AgregarScreen> createState() => _AgregarScreenState();
}

class _AgregarScreenState extends State<AgregarScreen> {
  _EntryMode _mode = _EntryMode.scan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: widget.onBackToPantry,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  '← Volver',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 11),
            Text(
              'AGREGAR ALIMENTO',
              style: textTheme.titleSmall?.copyWith(
                letterSpacing: 2.4,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Entrada Hibrida',
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 18),
            _HybridModeSwitch(
              mode: _mode,
              onChanged: (value) => setState(() => _mode = value),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _mode == _EntryMode.scan
                  ? const _ScanEntryCard(key: ValueKey('scan'))
                  : const _ManualEntryForm(key: ValueKey('manual')),
            ),
          ],
        ),
      ),
    );
  }
}

class _HybridModeSwitch extends StatelessWidget {
  final _EntryMode mode;
  final ValueChanged<_EntryMode> onChanged;

  const _HybridModeSwitch({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _modeButton(
            textTheme: textTheme,
            label: 'Escanear',
            icon: CupertinoIcons.photo_camera_solid, 
            selected: mode == _EntryMode.scan,
            onTap: () => onChanged(_EntryMode.scan),
          ),
          _modeButton(
            textTheme: textTheme,
            label: 'Manual',
            icon: Icons.eco,
            selected: mode == _EntryMode.manual,
            onTap: () => onChanged(_EntryMode.manual),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required TextTheme textTheme,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? AppColors.accent : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: textTheme.titleMedium?.copyWith(
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanEntryCard extends StatelessWidget {
  const _ScanEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomPaint(
      painter: _DashedRoundedRectPainter(color: AppColors.accent, radius: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.camera_viewfinder,
              size: 56,
              color: AppColors.textMuted.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 18),
            Text(
              'Apunta al codigo de barras',
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.textMain.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Toca para simular escaneo',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 190,
              height: 92,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.danger, width: 1),
                color: AppColors.surface,
              ),
              child: const Center(child: _FakeBarcode()),
            ),
          ],
        ),
      ),
    );
  }
}

class _FakeBarcode extends StatelessWidget {
  const _FakeBarcode();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(20, (index) {
            final bool thick = index % 4 == 0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.2),
              child: Container(
                width: thick ? 3 : 1.5,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }),
        ),
        Container(
          width: 160,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.accent,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.6),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManualEntryForm extends StatefulWidget {
  const _ManualEntryForm({super.key});

  @override
  State<_ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends State<_ManualEntryForm> {
  final _nombreCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  bool _mostrarMensajeRecomendacion = false;
  String? _categoriaSeleccionada;
  UnidadMedida? _unidadSeleccionada;

  Future<void> _seleccionarFecha(BuildContext context) async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: hoy.add(const Duration(days: 7)),
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.surface,
            surface: AppColors.green,
          ),
        ),
        child: child!,
      ),
    );
    if (fecha != null) {
      _fechaCtrl.text =
          '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}';
    }
  }

  void _recomendarFechaParaCategoria(String categoria) {
    final diasVida = vidaUtilRecomendada(categoria);
    final fechaRecomendada = DateTime.now().add(Duration(days: diasVida));
    _fechaCtrl.text =
        '${fechaRecomendada.day.toString().padLeft(2, '0')}/'
        '${fechaRecomendada.month.toString().padLeft(2, '0')}/'
        '${fechaRecomendada.year}';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cantidadCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InputField(
            label: 'Nombre del producto',
            hint: 'Ej: Yogur griego',
            controller: _nombreCtrl,
          ),
          const SizedBox(height: 12),
          _CategoriaDropdown(
            categoriaSeleccionada: _categoriaSeleccionada,
            onCategoriaChanged: (categoria) {
              setState(() {
                _categoriaSeleccionada = categoria;

                if (categoria != null) {
                  _mostrarMensajeRecomendacion = true;
                  _recomendarFechaParaCategoria(categoria);
                }
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _InputField(
                  label: 'Cantidad',
                  hint: 'Ej: 1',
                  controller: _cantidadCtrl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _UnidadDropdown(
                  unidadSeleccionada: _unidadSeleccionada,
                  onUnidadChanged: (unidad) {
                    setState(() {
                      _unidadSeleccionada = unidad;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InputField(
            label: 'Fecha de vencimiento',
            hint: 'Selecciona una fecha',
            controller: _fechaCtrl,
            readOnly: true,
            onTap: () => _seleccionarFecha(context),
          ),
          const SizedBox(height: 8),
          if (_mostrarMensajeRecomendacion) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  'Esta es la fecha de caducidad recomendada para este producto',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.green.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _SaveButton(
            onPressed: () {
              if (_nombreCtrl.text.isEmpty || _fechaCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completa nombre y fecha.')),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${_nombreCtrl.text} agregado (demo).')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.textMain,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.card,
        labelStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
        hintStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.textMuted.withValues(alpha: 0.75),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _CategoriaDropdown extends StatelessWidget {
  final String? categoriaSeleccionada;
  final ValueChanged<String?> onCategoriaChanged;

  const _CategoriaDropdown({
    required this.categoriaSeleccionada,
    required this.onCategoriaChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categorias = vidaUtilPorCategoria.keys.toList();
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(20),
        elevation: 8,

        hint: Text(
          'Selecciona una categoría',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        value: categoriaSeleccionada,
        items: categorias.map((categoria) {
          return DropdownMenuItem<String>(
            value: categoria,
            child: Text(
              categoria,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textMain,
              ),
            ),
          );
        }).toList(),
        onChanged: onCategoriaChanged,
        dropdownColor: AppColors.surface,
        icon: const Icon(CupertinoIcons.chevron_down, size: 16),
        iconEnabledColor: AppColors.textMuted,
      ),
    );
  }
}

class _UnidadDropdown extends StatelessWidget {
  final UnidadMedida? unidadSeleccionada;
  final ValueChanged<UnidadMedida?> onUnidadChanged;

  const _UnidadDropdown({
    required this.unidadSeleccionada,
    required this.onUnidadChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButton<UnidadMedida>(
        isExpanded: true,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(20),
        elevation: 8,
        hint: Text(
          'Unidad',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        value: unidadSeleccionada,
        items: UnidadMedida.values.map((unidad) {
          return DropdownMenuItem<UnidadMedida>(
            value: unidad,
            child: Text(
              unidad.abreviatura,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textMain,
              ),
            ),
          );
        }).toList(),
        onChanged: onUnidadChanged,
        dropdownColor: AppColors.surface,
        icon: const Icon(CupertinoIcons.chevron_down, size: 16),
        iconEnabledColor: AppColors.textMuted,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _SaveButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_task_rounded),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        label: const Text(
          'Guardar producto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRoundedRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 8;
    const double dashSpace = 6;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDistance = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
