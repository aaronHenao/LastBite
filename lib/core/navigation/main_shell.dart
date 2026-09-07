import 'package:flutter/material.dart';
import 'package:lastbite/l10n/app_localizations.dart';
import 'package:lastbite/l10n/traducciones.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/responsive/responsive.dart';
import 'package:lastbite/features/agregar/presentation/agregar_screen.dart';
import 'package:lastbite/features/alertas/presentation/alertas_screen.dart';
import 'package:lastbite/features/despensa/presentation/despensa_screen.dart';
import 'package:lastbite/features/recetas/presentation/recetas_screen.dart';
import 'package:lastbite/core/notifications/notification_service.dart';
import 'package:lastbite/core/theme/interruptor_tema.dart';
import 'package:lastbite/core/widgets/marca_lastbite.dart';
import 'package:lastbite/core/widgets/menu_cuenta.dart';

/// Destinos de la navegacion principal. Antes los iconos viajaban sueltos y
/// sin etiqueta: la barra movil no anunciaba nada a un lector de pantalla, y
/// una camara para "Agregar" o un gorro de chef para "Recetas" no son iconos
/// que se entiendan solos.
typedef _EtiquetaDestino = String Function(L10n);

const List<({IconData icono, _EtiquetaDestino etiqueta})> _destinos = [
  (icono: HugeIcons.strokeRoundedHome04, etiqueta: _despensa),
  (icono: CupertinoIcons.camera, etiqueta: _agregar),
  (icono: HugeIcons.strokeRoundedChefHat, etiqueta: _recetas),
  (icono: CupertinoIcons.bell, etiqueta: _alertas),
];

String _despensa(L10n t) => t.navDespensa;
String _agregar(L10n t) => t.navAgregar;
String _recetas(L10n t) => t.navRecetas;
String _alertas(L10n t) => t.navAlertas;

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    DespensaScreen(onAgregar: () => _onItemTapped(1)),
    AgregarScreen(onBackToPantry: () => _onItemTapped(0)),
    const RecetasScreen(),
    const AlertasScreen(),
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.instance.onNotificationTap = (payload) {
      if (!mounted) return;
      if (payload == 'alertas') {
        setState(() => _selectedIndex = 3);
      }
    };
  }

  @override
  void dispose() {
    NotificationService.instance.onNotificationTap = null;
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isTabletOrWeb(context);

    // En ancho la navegacion va arriba y en horizontal: el menu lateral se
    // llevaba 220px permanentes para mostrar cuatro iconos.
    if (isWide) {
      return Scaffold(
        backgroundColor: context.paleta.papel,
        body: SafeArea(
          child: Column(
            children: [
              _BarraNavegacion(
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
              Expanded(
                child: IndexedStack(index: _selectedIndex, children: _pages),
              ),
            ],
          ),
        ),
      );
    }

    //navbar flotante (mobile)
    return Scaffold(
      backgroundColor: context.paleta.papel,
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _pages),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FloatingMenuBar(
              selectedIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}


//navbar mobile
class _FloatingMenuBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _FloatingMenuBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: context.paleta.marcaSuave.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: context.paleta.contorno),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            for (final (indice, destino) in _destinos.indexed)
              _MenuItem(
                icon: destino.icono,
                label: destino.etiqueta(context.t),
                selected: selectedIndex == indice,
                onTap: () => onTap(indice),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;
    final color = selected ? paleta.marca : paleta.apagado;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Tooltip(
          message: label,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: AppSpacing.xs),
                AnimatedContainer(
                  duration: AppMotion.duracion(context, AppMotion.pulsa),
                  curve: AppMotion.curvaPulsa,
                  width: selected ? 22 : 0,
                  height: 2,
                  decoration: BoxDecoration(
                    color: paleta.marca,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navegacion horizontal para tablet y web.
class _BarraNavegacion extends StatelessWidget {
  const _BarraNavegacion({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: paleta.contorno)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: const MarcaLastBite(tamano: 24),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (indice, destino) in _destinos.indexed) ...[
                _ItemBarra(
                  icono: destino.icono,
                  etiqueta: destino.etiqueta(context.t),
                  seleccionado: selectedIndex == indice,
                  onTap: () => onTap(indice),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                InterruptorTema(),
                SizedBox(width: AppSpacing.xs),
                MenuCuenta(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemBarra extends StatelessWidget {
  const _ItemBarra({
    required this.icono,
    required this.etiqueta,
    required this.seleccionado,
    required this.onTap,
  });

  final IconData icono;
  final String etiqueta;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final paleta = context.paleta;
    final textTheme = Theme.of(context).textTheme;
    final color = seleccionado ? paleta.marca : paleta.apagado;

    return Semantics(
      button: true,
      selected: seleccionado,
      label: etiqueta,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AnimatedContainer(
          duration: AppMotion.duracion(context, AppMotion.pulsa),
          curve: AppMotion.curvaPulsa,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: seleccionado ? paleta.marcaSuave : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 20, color: color),
              const SizedBox(width: AppSpacing.sm),
              Text(
                etiqueta,
                style: textTheme.labelLarge?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
