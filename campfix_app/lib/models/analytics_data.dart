class SatisfactionStats {
  final double averageRating;
  final int totalFeedback;
  final int resolvedSuccessfullyPercent;

  SatisfactionStats({
    required this.averageRating,
    required this.totalFeedback,
    required this.resolvedSuccessfullyPercent,
  });

  factory SatisfactionStats.fromJson(Map<String, dynamic> json) {
    return SatisfactionStats(
      averageRating: (json['averageRating'] as num).toDouble(),
      totalFeedback: json['totalFeedback'] as int,
      resolvedSuccessfullyPercent: json['resolvedSuccessfullyPercent'] as int,
    );
  }
}

class StaffPerformanceEntry {
  final String staffId;
  final String fullName;
  final String? specialization;
  final double averageRating;
  final int totalRatings;

  StaffPerformanceEntry({
    required this.staffId,
    required this.fullName,
    this.specialization,
    required this.averageRating,
    required this.totalRatings,
  });

  factory StaffPerformanceEntry.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return StaffPerformanceEntry(
      staffId: json['staff_id'] as String,
      fullName: profile?['full_name'] as String? ?? 'Unknown',
      specialization: profile?['staff_specialization'] as String?,
      averageRating: (json['average_rating'] as num).toDouble(),
      totalRatings: json['total_ratings'] as int,
    );
  }
}

class AnalyticsData {
  final int total;
  final int active;
  final int resolved;
  final int critical;
  final Map<String, int> byStatus;
  final Map<String, int> byCategory;
  final Map<String, int> byDepartment;
  final double avgResolutionTimeHours;
  final int reopenedCount;
  final SatisfactionStats satisfaction;
  final List<StaffPerformanceEntry> staffPerformance;

  AnalyticsData({
    required this.total,
    required this.active,
    required this.resolved,
    required this.critical,
    required this.byStatus,
    required this.byCategory,
    required this.byDepartment,
    required this.avgResolutionTimeHours,
    required this.reopenedCount,
    required this.satisfaction,
    required this.staffPerformance,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    final overview = json['overview'] as Map<String, dynamic>;
    return AnalyticsData(
      total: overview['total'] as int,
      active: overview['active'] as int,
      resolved: overview['resolved'] as int,
      critical: overview['critical'] as int,
      byStatus: (json['byStatus'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int)),
      byCategory: (json['byCategory'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int)),
      byDepartment: (json['byDepartment'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int)),
      avgResolutionTimeHours: (json['avgResolutionTimeHours'] as num).toDouble(),
      reopenedCount: json['reopenedCount'] as int,
      satisfaction: SatisfactionStats.fromJson(json['satisfaction'] as Map<String, dynamic>),
      staffPerformance: (json['staffPerformance'] as List<dynamic>)
          .map((e) => StaffPerformanceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}