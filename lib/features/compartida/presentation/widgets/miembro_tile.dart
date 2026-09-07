import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastbite/core/responsive/responsive.dart';
import 'package:lastbite/core/theme/app_theme.dart';

import '../../domain/despensa_compartida.dart';

class MiembroTile extends StatelessWidget {
  const MiembroTile({
    super.key,
    required this.miembro,
    required this.esAdminDelMiembro,
    required this.esYo,
    this.onExpulsar,
  });

  final MiembroDespensa miembro;
  final bool esAdminDelMiembro;
  final bool esYo;

  /// Null cuando quien mira no puede expulsar a este miembro.
  final VoidCallback? onExpulsar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.paleta.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: esAdminDelMiembro
              ? context.paleta.marca.withValues(alpha: 0.35)
              : context.paleta.contorno,
        ),
      ),
      child: Row(
        children: [
          _Avatar(fotoUrl: miembro.fotoUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        esYo ? '${miembro.nombre} (tú)' : miembro.nombre,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                    ),
                    if (esAdminDelMiembro) ...[
                      const SizedBox(width: 6),
                      const _BadgeAdmin(),
                    ],
                  ],
                ),
                if (miembro.email != null)
                  Text(
                    miembro.email!,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: context.paleta.apagado,
                    ),
                  ),
              ],
            ),
          ),
          if (onExpulsar != null)
            IconButton(
              onPressed: onExpulsar,
              tooltip: 'Eliminar miembro',
              icon: Icon(
                CupertinoIcons.person_badge_minus,
                size: 20,
                color: context.paleta.vencido,
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.fotoUrl});
  final String? fotoUrl;

  @override
  Widget build(BuildContext context) {
    // CachedNetworkImage no se comporta bien en web, igual que en el perfil.
    if (fotoUrl != null && !Responsive.isTabletOrWeb(context)) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: context.paleta.marcaSuave,
        backgroundImage: CachedNetworkImageProvider(fotoUrl!),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: context.paleta.marcaSuave,
      child: Icon(Icons.person, size: 20, color: context.paleta.apagado),
    );
  }
}

class _BadgeAdmin extends StatelessWidget {
  const _BadgeAdmin();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.paleta.marca.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'ADMIN',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.paleta.marca,
          fontSize: 9,
        ),
      ),
    );
  }
}
