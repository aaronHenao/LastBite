import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/core/responsive/responsive.dart';
import 'package:lastbite/features/agregar/presentation/agregar_screen.dart';
import 'package:lastbite/features/alertas/presentation/alertas_screen.dart';
import 'package:lastbite/features/despensa/presentation/despensa_screen.dart';
import 'package:lastbite/features/recetas/presentation/recetas_screen.dart';
import 'package:lastbite/core/notifications/notification_service.dart';

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

    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Row(
          children: [
            //sidebaar izq
            _Sidebar(selectedIndex: _selectedIndex, onTap: _onItemTapped),
            //contenido principal
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _pages),
            ),
          ],
        ),
      );
    }

    //navbar flotante (mobile)
    return Scaffold(
      backgroundColor: AppColors.bg,
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

//sidebar tablet/web
class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _Sidebar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isWeb = Responsive.isWeb(context);

    return Container(
      width: isWeb ? 220 : 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            //logo letra
            if (isWeb) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Image.asset(
                      'lib/assets/images/letra.png',
                      height: 95,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 5),
                    
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ] else ...[
              Text('🌿', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 32),
            ],

            //items de navegación
            _SidebarItem(
              icon: HugeIcons.strokeRoundedHome04,
              label: 'Despensa',
              selected: selectedIndex == 0,
              showLabel: isWeb,
              onTap: () => onTap(0),
            ),
            _SidebarItem(
              icon: CupertinoIcons.camera,
              label: 'Agregar',
              selected: selectedIndex == 1,
              showLabel: isWeb,
              onTap: () => onTap(1),
            ),
            _SidebarItem(
              icon: HugeIcons.strokeRoundedChefHat,
              label: 'Recetas',
              selected: selectedIndex == 2,
              showLabel: isWeb,
              onTap: () => onTap(2),
            ),
            _SidebarItem(
              icon: CupertinoIcons.bell,
              label: 'Alertas',
              selected: selectedIndex == 3,
              showLabel: isWeb,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textMuted;
    final bg = selected
        ? AppColors.accent.withValues(alpha: 0.12)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: showLabel
              ? Row(
                  children: [
                    Icon(icon, size: 22, color: color),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                )
              : Center(child: Icon(icon, size: 24, color: color)),
        ),
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
