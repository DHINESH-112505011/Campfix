enum AppRole { student, staff, admin, superAdmin }

extension AppRoleX on AppRole {
  static AppRole fromString(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'STAFF':
        return AppRole.staff;
      case 'ADMIN':
        return AppRole.admin;
      case 'SUPER_ADMIN':
        return AppRole.superAdmin;
      case 'STUDENT':
      default:
        // Defaults to student - never silently escalate privileges.
        return AppRole.student;
    }
  }

  String get label {
    switch (this) {
      case AppRole.student:
        return 'Student';
      case AppRole.staff:
        return 'Staff';
      case AppRole.admin:
        return 'Admin';
      case AppRole.superAdmin:
        return 'Super Admin';
    }
  }
}