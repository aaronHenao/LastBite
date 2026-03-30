import 'dart:math' as math;

import 'package:flutter/material.dart';
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Text(
                  '← Volver',
                  style: TextStyle(
                    fontSize: 21,
                    color: AppColors.textMuted.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'AGREGAR ALIMENTO',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Entrada Hibrida',
              style: TextStyle(
                fontSize: 42,
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
            label: 'Escanear',
            icon: Icons.camera_alt_rounded,
            selected: mode == _EntryMode.scan,
            onTap: () => onChanged(_EntryMode.scan),
          ),
          _modeButton(
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
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
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
    return CustomPaint(
      painter: _DashedRoundedRectPainter(
        color: AppColors.accent,
        radius: 24,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
        child: Column(
          children: [
            Icon(
              Icons.camera_alt_rounded,
              size: 56,
              color: AppColors.textMuted.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 8),
            const Text(
              'Apunta al codigo de barras',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Toca para simular escaneo',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 190,
              height: 92,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(18, (index) {
        final bool thick = index % 3 == 0;
        final double height = index % 4 == 0 ? 56 : 48;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.2),
          child: Container(
            width: thick ? 3.2 : 1.8,
            height: height,
            color: AppColors.textMuted.withValues(alpha: 0.52),
          ),
        );
      }),
    );
  }
}

class _ManualEntryForm extends StatelessWidget {
  const _ManualEntryForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: const [
          _InputField(label: 'Nombre del producto', hint: 'Ej: Yogur griego'),
          SizedBox(height: 12),
          _InputField(label: 'Categoria', hint: 'Ej: Lacteos'),
          SizedBox(height: 12),
          _InputField(label: 'Cantidad', hint: 'Ej: 1 unidad'),
          SizedBox(height: 12),
          _InputField(label: 'Fecha de vencimiento', hint: 'DD/MM/AAAA'),
          SizedBox(height: 16),
          _SaveButton(),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;

  const _InputField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.card,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.75)),
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

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto agregado (demo visual).'),
            ),
          );
        },
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
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
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
