import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/campfix_button.dart';

/// Temporary screen shown after login until Phase 3 (role-based navigation)
/// replaces this with actual Student/Staff/Admin dashboards.
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().status;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
                const SizedBox(height: 16),
                Text('You are logged in', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Status: $email', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                CampFixButton(
                  label: 'Logout',
                  onPressed: () => context.read<AuthProvider>().logout(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}