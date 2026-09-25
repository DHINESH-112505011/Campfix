class StaffMember {
  final String id;
  final String fullName;
  final String? specialization;
  final int activeAssignments;

  StaffMember({
    required this.id,
    required this.fullName,
    this.specialization,
    required this.activeAssignments,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      specialization: json['staff_specialization'] as String?,
      activeAssignments: json['active_assignments'] as int? ?? 0,
    );
  }
}