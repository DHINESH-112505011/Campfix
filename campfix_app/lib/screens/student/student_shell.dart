import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/campfix_bottom_navigation.dart';
import '../common/profile_placeholder_screen.dart';
import 'student_home_placeholder.dart';
import 'complaints_list_screen.dart';
import 'report/report_wizard_screen.dart';

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

/// Navigation shell for STUDENT role: Home, Complaints, Report, Notifications, Profile.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    StudentHomePlaceholder(),
    ComplaintsListScreen(),
    ReportWizardScreen(),
    _PlaceholderTab('Notifications'),
    ProfilePlaceholderScreen(),
  ];

  final List<CampFixNavItem> _navItems = const [
    CampFixNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
    CampFixNavItem(icon: Icons.list_alt_outlined, selectedIcon: Icons.list_alt_rounded, label: 'Complaints'),
    CampFixNavItem(icon: Icons.add_circle_outline_rounded, selectedIcon: Icons.add_circle_rounded, label: 'Report'),
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