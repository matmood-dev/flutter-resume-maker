import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home/dashboard')) return 0;
    if (location.startsWith('/home/resumes')) return 1;
    if (location.startsWith('/home/ai')) return 2;
    if (location.startsWith('/home/templates')) return 3;
    if (location.startsWith('/home/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home/dashboard');
      case 1:
        context.go('/home/resumes');
      case 2:
        context.go('/home/ai');
      case 3:
        context.go('/home/templates');
      case 4:
        context.go('/home/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          child,
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.card.withAlpha(204),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border.withAlpha(77),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Home',
                        isSelected: selectedIndex == 0,
                        onTap: () => _onTap(context, 0),
                      ),
                      _NavItem(
                        icon: Icons.description_outlined,
                        activeIcon: Icons.description,
                        label: 'Resumes',
                        isSelected: selectedIndex == 1,
                        onTap: () => _onTap(context, 1),
                      ),
                      _NavItem(
                        icon: Icons.auto_awesome_outlined,
                        activeIcon: Icons.auto_awesome,
                        label: 'AI',
                        isSelected: selectedIndex == 2,
                        onTap: () => _onTap(context, 2),
                      ),
                      _NavItem(
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard,
                        label: 'Templates',
                        isSelected: selectedIndex == 3,
                        onTap: () => _onTap(context, 3),
                      ),
                      _NavItem(
                        icon: Icons.person_outlined,
                        activeIcon: Icons.person,
                        label: 'Profile',
                        isSelected: selectedIndex == 4,
                        onTap: () => _onTap(context, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textGrey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textGrey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
