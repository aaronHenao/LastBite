import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Vuelve a la pantalla anterior.
///
/// Existia copiado en cuatro pantallas con tres implementaciones distintas:
/// unas con `InkWell` y padding, otra con un `GestureDetector` pelado, y todas
/// con una zona de toque de unos 28px de alto. Aca es una sola, con los 44x44
/// minimos.
class BotonVolver extends StatelessWidget {
  const BotonVolver({super.key, this.texto = 'Volver', this.onTap});

  final String texto;

  /// Por defecto hace `Navigator.pop`.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Semantics(
          button: true,
          label: texto,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: paleta.apagado,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  texto,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: paleta.apagado),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
