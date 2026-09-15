import 'package:flutter/material.dart';
import '../../models/app_role.dart';
import '../../screens/student/student_shell.dart';
import '../../screens/staff/staff_shell.dart';
import '../../screens/admin/admin_shell.dart';

/// Central place that decides which navigation shell to show for a role.
/// Unauthorized cross-role access is impossible by construction: users
/// are only ever routed to their own shell, never given navigation
/// entry points into another role's screens.
class RoleRouter {
  RoleRouter._();

  static Widget shellFor(AppRole role) {
    switch (role) {
      case AppRole.student:
        return const StudentShell();
      case AppRole.staff:
        return const StaffShell();
      case AppRole.admin:
      case AppRole.superAdmin:
        return const AdminShell();
    }
  }
}