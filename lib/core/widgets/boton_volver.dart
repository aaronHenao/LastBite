import 'package:flutter/material.dart';
import 'package:lastbite/l10n/traducciones.dart';
import '../theme/app_theme.dart';

/// Vuelve a la pantalla anterior.
///
/// Existia copiado en cuatro pantallas con tres implementaciones distintas:
/// unas con `InkWell` y padding, otra con un `GestureDetector` pelado, y todas
/// con una zona de toque de unos 28px de alto. Aca es una sola, con los 44x44
/// minimos.
class BotonVolver extends StatelessWidget {
  const BotonVolver({super.key, this.texto, this.onTap});

  /// Por defecto, el texto traducido de "volver".
  final String? texto;

  /// Por defecto hace `Navigator.pop`.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;
    final etiqueta = texto ?? context.t.accionVolver;

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Semantics(
          button: true,
          label: etiqueta,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
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
                  etiqueta,
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
