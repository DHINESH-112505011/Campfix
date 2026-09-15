class Complaint {
  final String id;
  final String complaintNumber;
  final String title;
  final String description;
  final String category;
  final String priority; // LOW, MEDIUM, HIGH, CRITICAL
  final String status;   // matches complaint status workflow
  final String building;
  final String room;
  final DateTime createdAt;
  final DateTime updatedAt;

  Complaint({
    required this.id,
    required this.complaintNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.building,
    required this.room,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as String,
      complaintNumber: json['complaint_number'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      building: json['building'] as String? ?? '',
      room: json['room'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  bool get isActive => !['RESOLVED', 'REJECTED', 'CANCELLED'].contains(status);
  bool get isResolved => status == 'RESOLVED';
}