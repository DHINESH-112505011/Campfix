class UserProfile {
  final String id;
  final String authUserId;
  final String fullName;
  final String email;
  final String? phone;
  final String role; // STUDENT, STAFF, ADMIN, SUPER_ADMIN
  final String? studentOrStaffId;
  final String? departmentId;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.authUserId,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.studentOrStaffId,
    this.departmentId,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      authUserId: json['auth_user_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      studentOrStaffId: json['student_or_staff_id'] as String?,
      departmentId: json['department_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_user_id': authUserId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'student_or_staff_id': studentOrStaffId,
      'department_id': departmentId,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}