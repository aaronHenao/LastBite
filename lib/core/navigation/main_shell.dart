import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import 'package:lastbite/features/agregar/presentation/agregar_screen.dart';
import 'package:lastbite/features/alertas/presentation/alertas_screen.dart';
import 'package:lastbite/features/despensa/presentation/despensa_screen.dart';
import 'package:lastbite/features/recetas/presentation/recetas_screen.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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

class _ComingSoonScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ComingSoonScreen({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
