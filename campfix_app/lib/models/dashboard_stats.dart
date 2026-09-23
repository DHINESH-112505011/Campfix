import 'complaint.dart';

class StaffWorkloadEntry {
  final String staffId;
  final String fullName;
  final String? specialization;
  final int activeAssignments;

  StaffWorkloadEntry({
    required this.staffId,
    required this.fullName,
    this.specialization,
    required this.activeAssignments,
  });

  factory StaffWorkloadEntry.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return StaffWorkloadEntry(
      staffId: json['staff_id'] as String,
      fullName: profile?['full_name'] as String? ?? 'Unknown',
      specialization: profile?['staff_specialization'] as String?,
      activeAssignments: json['active_assignments'] as int? ?? 0,
    );
  }
}

class DashboardStats {
  final int total;
  final int active;
  final int resolved;
  final int critical;
  final Map<String, int> byStatus;
  final Map<String, int> byCategory;
  final List<Complaint> recentComplaints;
  final List<StaffWorkloadEntry> staffWorkload;

  DashboardStats({
    required this.total,
    required this.active,
    required this.resolved,
    required this.critical,
    required this.byStatus,
    required this.byCategory,
    required this.recentComplaints,
    required this.staffWorkload,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final overview = json['overview'] as Map<String, dynamic>;
    final byStatusRaw = json['byStatus'] as Map<String, dynamic>;
    final byCategoryRaw = json['byCategory'] as Map<String, dynamic>;
    final recentRaw = json['recentComplaints'] as List<dynamic>;
    final workloadRaw = json['staffWorkload'] as List<dynamic>;

    return DashboardStats(
      total: overview['total'] as int,
      active: overview['active'] as int,
      resolved: overview['resolved'] as int,
      critical: overview['critical'] as int,
      byStatus: byStatusRaw.map((k, v) => MapEntry(k, v as int)),
      byCategory: byCategoryRaw.map((k, v) => MapEntry(k, v as int)),
      recentComplaints: recentRaw
          .map((json) => Complaint.fromJson(json as Map<String, dynamic>))
          .toList(),
      staffWorkload: workloadRaw
          .map((json) => StaffWorkloadEntry.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }
}