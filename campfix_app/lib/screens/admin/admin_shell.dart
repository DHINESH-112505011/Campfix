import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../models/app_role.dart';
import '../../widgets/campfix_bottom_navigation.dart';
import '../common/profile_placeholder_screen.dart';
import '../common/notifications_screen.dart';
import 'admin_home_placeholder.dart';
import 'admin_complaint_list_screen.dart';
import 'admin_analytics_screen.dart';
import 'audit_logs_screen.dart';

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

/// Navigation shell for ADMIN / SUPER_ADMIN roles. Super Admin gets an
/// additional Audit Logs tab per §47 (ordinary admins are excluded).
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = context.watch<AuthProvider>().currentRole == AppRole.superAdmin;

    final pages = <Widget>[
      const AdminHomePlaceholder(),
      const AdminComplaintListScreen(),
      const _PlaceholderTab('Staff'),
      const _PlaceholderTab('Users'),
      const AdminAnalyticsScreen(),
      const NotificationsScreen(),
      if (isSuperAdmin) const AuditLogsScreen(),
      const ProfilePlaceholderScreen(),
    ];

    final navItems = <CampFixNavItem>[
      const CampFixNavItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded, label: 'Dashboard'),
      const CampFixNavItem(icon: Icons.list_alt_outlined, selectedIcon: Icons.list_alt_rounded, label: 'Complaints'),
      const CampFixNavItem(icon: Icons.engineering_outlined, selectedIcon: Icons.engineering_rounded, label: 'Staff'),
      const CampFixNavItem(icon: Icons.people_outline_rounded, selectedIcon: Icons.people_rounded, label: 'Users'),
      const CampFixNavItem(icon: Icons.bar_chart_rounded, selectedIcon: Icons.bar_chart_rounded, label: 'Analytics'),
      const CampFixNavItem(icon: Icons.notifications_outlined, selectedIcon: Icons.notifications_rounded, label: 'Notifications'),
      if (isSuperAdmin)
        const CampFixNavItem(icon: Icons.history_outlined, selectedIcon: Icons.history_rounded, label: 'Audit'),
      const CampFixNavItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Profile'),
    ];

    if (_selectedIndex >= pages.length) _selectedIndex = 0;

    if (Responsive.isTabletOrLarger(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              backgroundColor: AppColors.surface,
              labelType: NavigationRailLabelType.all,
              destinations: navItems
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon, color: AppColors.primary),
                        label: Text(item.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: CampFixBottomNavigation(
        currentIndex: _selectedIndex,
        items: navItems,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}