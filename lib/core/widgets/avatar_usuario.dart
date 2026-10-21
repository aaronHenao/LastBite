import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Foto de una persona, o un icono de usuario cuando no tiene foto, mientras
/// carga o si no se puede cargar.
///
/// Antes habia cuatro copias y ninguna cubria la foto que falla: el circulo
/// quedaba vacio, sin nada que dijera que ahi esta la cuenta.
class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({super.key, required this.fotoUrl, this.radio = 18});

  final String? fotoUrl;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;
    final url = fotoUrl?.trim() ?? '';
    final icono = Icon(
      Icons.person_rounded,
      size: radio * 1.2,
      color: paleta.marca,
    );

    return CircleAvatar(
      radius: radio,
      backgroundColor: paleta.marcaSuave,
      child: url.isEmpty
          ? icono
          : ClipOval(
              child: Image(
                // En web CachedNetworkImage no se comporta bien; NetworkImage
                // si, y si el servidor no permite leer la imagen la muestra
                // igual con un <img>.
                image: kIsWeb
                    ? NetworkImage(
                        url,
                        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                      )
                    : CachedNetworkImageProvider(url),
                width: radio * 2,
                height: radio * 2,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                frameBuilder: (_, imagen, cuadro, sincronica) =>
                    cuadro == null && !sincronica ? icono : imagen,
                errorBuilder: (_, _, _) => icono,
              ),
            ),
    );
  }
}
