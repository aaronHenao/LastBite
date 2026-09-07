import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/compartida/presentation/compartida_screen.dart';
import 'package:lastbite/features/consulta_rapida/presentation/consulta_rapida_screen.dart';
import 'package:lastbite/features/perfil/presentation/perfil_screen.dart';

/// Menu de cuenta para pantallas anchas.
///
/// Vive en la barra de navegacion, no en el contenido: es navegacion, no un
/// dato de la despensa.
class MenuCuenta extends ConsumerWidget {
  const MenuCuenta({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paleta = context.paleta;
    final user = ref.watch(authStateProvider).valueOrNull;
    final fotoUrl = user?.fotoUrl;

    void abrir(Widget pantalla) => Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => pantalla),
    );

    return MenuAnchor(
      builder: (context, controller, _) => Semantics(
        button: true,
        label: 'Menú de cuenta',
        child: Tooltip(
          message: user?.nombre ?? 'Mi cuenta',
          child: InkWell(
            onTap: () =>
                controller.isOpen ? controller.close() : controller.open(),
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: paleta.marcaSuave,
                backgroundImage: fotoUrl == null
                    ? null
                    : CachedNetworkImageProvider(fotoUrl),
                child: fotoUrl != null
                    ? null
                    : Icon(Icons.person, size: 20, color: paleta.marca),
              ),
            ),
          ),
        ),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.person_outline_rounded),
          onPressed: () => abrir(const PerfilScreen()),
          child: const Text('Perfil y lista de compras'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.groups_rounded),
          onPressed: () => abrir(const DespensaCompartidaScreen()),
          child: const Text('Despensa compartida'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(CupertinoIcons.search),
          onPressed: () => abrir(const ConsultaRapidaScreen()),
          child: const Text('Consulta rápida'),
        ),
        MenuItemButton(
          leadingIcon: Icon(Icons.logout_rounded, color: paleta.vencido),
          onPressed: () => ref.read(authServiceProvider).cerrarSesion(),
          child: Text('Cerrar sesión', style: TextStyle(color: paleta.vencido)),
        ),
      ],
    );
  }
}
