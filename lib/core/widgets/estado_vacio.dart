import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Estado vacio de una pantalla.
///
/// Un vacio no dice "no hay nada": dice que es esto, por que esta vacio y cual
/// es el siguiente paso. Media app lo resolvia bien y la otra media se quedaba
/// en el "no hay nada".
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.descripcion,
    this.textoAccion,
    this.onAccion,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final String? textoAccion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final paleta = context.paleta;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: paleta.marcaSuave,
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, size: 28, color: paleta.marca),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                descripcion,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: paleta.apagado),
              ),
              if (textoAccion != null && onAccion != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FilledButton(onPressed: onAccion, child: Text(textoAccion!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
