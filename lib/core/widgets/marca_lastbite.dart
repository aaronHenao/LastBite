import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Firma de la app: icono mas nombre.
///
/// El nombre va como texto y no como imagen. El logotipo en PNG trae la tinta
/// verde oscura horneada y un margen enorme alrededor, asi que sobre fondo
/// oscuro desaparecia y a tamaño de barra las letras quedaban diminutas.
/// Fraunces es practicamente la misma serif, y ademas toma el color del tema.
class MarcaLastBite extends StatelessWidget {
  const MarcaLastBite({super.key, this.tamano = 22, this.conIcono = true});

  final double tamano;
  final bool conIcono;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;

    return Semantics(
      label: 'LastBite',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (conIcono) ...[
            Image.asset(
              'lib/assets/images/logo_icono.png',
              height: tamano * 1.4,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            'LastBite',
            style: TextStyle(
              fontFamily: AppFonts.titulo,
              fontVariations: AppFonts.peso(600),
              fontSize: tamano,
              height: 1.0,
              letterSpacing: -0.5,
              color: paleta.marca,
            ),
          ),
        ],
      ),
    );
  }
}
