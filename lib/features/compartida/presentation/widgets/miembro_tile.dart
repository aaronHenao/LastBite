import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/widgets/avatar_usuario.dart';

import 'package:lastbite/l10n/traducciones.dart';

import '../../domain/despensa_compartida.dart';
import '../textos_compartida.dart';

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
          AvatarUsuario(fotoUrl: miembro.fotoUrl, radio: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        esYo
                            ? context.t.compartidaTu(
                                miembro.nombreVisible(context.t),
                              )
                            : miembro.nombreVisible(context.t),
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
              tooltip: context.t.compartidaEliminarMiembro,
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
        context.t.compartidaAdmin,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.paleta.marca,
          fontSize: 9,
        ),
      ),
    );
  }
}
