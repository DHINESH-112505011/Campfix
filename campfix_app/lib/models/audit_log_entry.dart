class AuditLogEntry {
  final String id;
  final String? userId;
  final String? performedByName;
  final String? performedByRole;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final DateTime createdAt;

  AuditLogEntry({
    required this.id,
    this.userId,
    this.performedByName,
    this.performedByRole,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return AuditLogEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      performedByName: profile?['full_name'] as String?,
      performedByRole: profile?['role'] as String?,
      action: json['action'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      oldValue: json['old_value'] as Map<String, dynamic>?,
      newValue: json['new_value'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get displayAction {
    return action
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0]}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}