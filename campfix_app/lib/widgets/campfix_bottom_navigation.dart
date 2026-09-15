import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CampFixNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const CampFixNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class CampFixBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final List<CampFixNavItem> items;
  final ValueChanged<int> onTap;

  const CampFixBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      destinations: items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon, color: AppColors.primary),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}