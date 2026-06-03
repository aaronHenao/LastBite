import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/admin/presentation/admin_screen.dart';
import 'package:lastbite/features/agregar/presentation/agregar_screen.dart';
import 'package:lastbite/features/alertas/presentation/alertas_screen.dart';
import 'package:lastbite/features/auth/presentation/auth_provider.dart';
import 'package:lastbite/features/despensa/presentation/despensa_screen.dart';
import 'package:lastbite/features/recetas/presentation/recetas_screen.dart';
import 'package:lastbite/core/services/permission_service.dart';
import 'package:lastbite/core/notifications/notification_service.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    NotificationService.instance.onNotificationTap = (payload) {
      if (!mounted) return;

      final user = ref.read(authStateProvider).value;

      if (payload == 'alertas' && !(user?.isAdmin ?? false)) {
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
    final user = ref.read(authStateProvider).value;
    if (index == 1 && user != null) {
      final permisos = PermissionService();
      if (!permisos.puedeAgregarProducto(user)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu rol no permite agregar productos.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final permisos = PermissionService();
    final puedeAgregar = user != null && permisos.puedeAgregarProducto(user);
    final esAdmin = user?.isAdmin ?? false;

    // Páginas dinámicas según rol
    final pages = esAdmin
        ? [const AdminScreen()]
        : [
            DespensaScreen(onAgregar: () => _onItemTapped(1)),
            AgregarScreen(onBackToPantry: () => _onItemTapped(0)),
            const RecetasScreen(),
            const AlertasScreen(),
          ];

    // Ajustar índice si es mayor al número de páginas disponibles
    final safeIndex = _selectedIndex < pages.length ? _selectedIndex : 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          IndexedStack(index: safeIndex, children: pages),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FloatingMenuBar(
              selectedIndex: safeIndex,
              onTap: _onItemTapped,
              puedeAgregar: puedeAgregar,
              esAdmin: esAdmin,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingMenuBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool puedeAgregar;
  final bool esAdmin;

  const _FloatingMenuBar({
    required this.selectedIndex,
    required this.onTap,
    required this.puedeAgregar,
    required this.esAdmin,
  });

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
          children: esAdmin
              ? [
                  _MenuItem(
                    icon: Icons.admin_panel_settings_rounded,
                    selected: true,
                    onTap: () => onTap(0),
                  ),
                ]
              : [
                  _MenuItem(
                    icon: HugeIcons.strokeRoundedHome04,
                    selected: selectedIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  if (puedeAgregar)
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
