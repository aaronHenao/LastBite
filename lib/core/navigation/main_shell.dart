import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/agregar/presentation/agregar_screen.dart';
import 'package:lastbite/features/alertas/domain/alerta.dart';
import 'package:lastbite/features/alertas/presentation/alertas_provider.dart';
import 'package:lastbite/features/alertas/presentation/alertas_screen.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/despensa/presentation/despensa_screen.dart';
import 'package:lastbite/features/recetas/presentation/recetas_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;
  final Set<String> _idsAlertasConocidas = {};
  /// Evita SnackBar al cargar alertas de otro usuario o al re-sincronizar.
  String? _uidUltimaSyncAlertas;

  late final List<Widget> _pages = [
    DespensaScreen(onAgregar: () => _onItemTapped(1)),
    AgregarScreen(onBackToPantry: () => _onItemTapped(0)),
    const RecetasScreen(),
    const AlertasScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Alerta>>>(alertasProvider, (previous, next) {
      next.whenData((alertas) {
        final uid = ref.read(firebaseUserProvider).value?.uid;
        if (uid != _uidUltimaSyncAlertas) {
          _uidUltimaSyncAlertas = uid;
          _idsAlertasConocidas
            ..clear()
            ..addAll(alertas.map((a) => a.id));
          return;
        }

        final recien = alertas
            .where((a) => !_idsAlertasConocidas.contains(a.id))
            .toList();
        _idsAlertasConocidas.addAll(recien.map((a) => a.id));

        if (recien.isEmpty || !mounted) return;

        final caducidad = recien
            .where(
              (a) =>
                  a.tipo == AlertaTipo.aviso5 ||
                  a.tipo == AlertaTipo.aviso4 ||
                  a.tipo == AlertaTipo.aviso3 ||
                  a.tipo == AlertaTipo.aviso2 ||
                  a.tipo == AlertaTipo.aviso1 ||
                  a.tipo == AlertaTipo.vencido,
            )
            .toList();
        if (caducidad.isEmpty) return;

        final texto = caducidad.length == 1
            ? 'Alerta: ${caducidad.first.nombreProducto} — ${caducidad.first.mensaje}'
            : '${caducidad.length} alertas nuevas de caducidad en la campana.';

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(texto, style: const TextStyle(fontSize: 13)),
              action: SnackBarAction(
                label: 'Ver',
                textColor: Colors.white,
                onPressed: () => _onItemTapped(3),
              ),
            ),
          );
        });
      });
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children:[
          IndexedStack(index: _selectedIndex, children: _pages),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FloatingMenuBar(selectedIndex: _selectedIndex, onTap: _onItemTapped),
          )
        ]
      )
    );
  }
}


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
          color: AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
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
            _MenuItem(
              icon: HugeIcons.strokeRoundedHome04,
              selected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            _MenuItem(
              icon: CupertinoIcons.camera,
              selected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            _MenuItem(
              icon: HugeIcons.strokeRoundedChefHat,
              selected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
            _MenuItem(
              icon: CupertinoIcons.bell,
              selected: selectedIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.accent;
    final Color inactiveColor = AppColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: selected ? activeColor : inactiveColor),
            const SizedBox(height: 4),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 26 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
