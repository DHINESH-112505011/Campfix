class TimelineEvent {
  final String id;
  final String complaintId;
  final String? performedBy;
  final String? role;
  final String? oldStatus;
  final String newStatus;
  final String? message;
  final DateTime createdAt;

  TimelineEvent({
    required this.id,
    required this.complaintId,
    this.performedBy,
    this.role,
    this.oldStatus,
    required this.newStatus,
    this.message,
    required this.createdAt,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      id: json['id'] as String,
      complaintId: json['complaint_id'] as String,
      performedBy: json['performed_by'] as String?,
      role: json['role'] as String?,
      oldStatus: json['old_status'] as String?,
      newStatus: json['new_status'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get displayLabel {
    final label = newStatus
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0]}${w.substring(1).toLowerCase()}')
        .join(' ');
    return message ?? label;
  }
} 