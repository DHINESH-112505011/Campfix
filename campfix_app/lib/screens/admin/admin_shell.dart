import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/campfix_bottom_navigation.dart';
import '../common/profile_placeholder_screen.dart';
import 'admin_home_placeholder.dart';

class _PlaceholderTab extends StatelessWidget {
  final String title;
  const _PlaceholderTab(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title coming in a later phase')),
    );
  }
}

/// Navigation shell for ADMIN / SUPER_ADMIN roles:
/// Dashboard, Complaints, Staff, Users, Analytics, Settings.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AdminHomePlaceholder(),
    _PlaceholderTab('Complaints'),
    _PlaceholderTab('Staff'),
    _PlaceholderTab('Users'),
    _PlaceholderTab('Analytics'),
    ProfilePlaceholderScreen(),
  ];

  final List<CampFixNavItem> _navItems = const [
    CampFixNavItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded, label: 'Dashboard'),
    CampFixNavItem(icon: Icons.list_alt_outlined, selectedIcon: Icons.list_alt_rounded, label: 'Complaints'),
    CampFixNavItem(icon: Icons.engineering_outlined, selectedIcon: Icons.engineering_rounded, label: 'Staff'),
    CampFixNavItem(icon: Icons.people_outline_rounded, selectedIcon: Icons.people_rounded, label: 'Users'),
    CampFixNavItem(icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart_rounded, label: 'Analytics'),
    CampFixNavItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // Admin is information-dense; always prefer a rail once space allows (tablet+),
    // and use bottom nav with a condensed set only on small phones.
    if (Responsive.isTabletOrLarger(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              backgroundColor: AppColors.surface,
              labelType: NavigationRailLabelType.all,
              destinations: _navItems
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon, color: AppColors.primary),
                        label: Text(item.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CampFixBottomNavigation(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}