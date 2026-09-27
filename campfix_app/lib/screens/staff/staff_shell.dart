import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/campfix_bottom_navigation.dart';
import '../common/profile_placeholder_screen.dart';
import '../common/notifications_screen.dart';
import 'staff_home_placeholder.dart';

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

/// Navigation shell for STAFF role: Dashboard, Tasks, History, Notifications, Profile.
class StaffShell extends StatefulWidget {
  const StaffShell({super.key});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    StaffHomePlaceholder(),
    _PlaceholderTab('Tasks'),
    _PlaceholderTab('History'),
    NotificationsScreen(),
    ProfilePlaceholderScreen(),
  ];

  final List<CampFixNavItem> _navItems = const [
    CampFixNavItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded, label: 'Dashboard'),
    CampFixNavItem(icon: Icons.build_outlined, selectedIcon: Icons.build_rounded, label: 'Tasks'),
    CampFixNavItem(icon: Icons.history_outlined, selectedIcon: Icons.history_rounded, label: 'History'),
    CampFixNavItem(icon: Icons.notifications_outlined, selectedIcon: Icons.notifications_rounded, label: 'Notifications'),
    CampFixNavItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
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