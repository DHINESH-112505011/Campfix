import 'complaint.dart';

class ComplaintAssignment {
  final String id;
  final String complaintId;
  final String staffId;
  final String assignedBy;
  final String status; // ASSIGNED, ACCEPTED, REJECTED, IN_PROGRESS, COMPLETED, REASSIGNED
  final String? notes;
  final DateTime assignedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final Complaint? complaint;

  ComplaintAssignment({
    required this.id,
    required this.complaintId,
    required this.staffId,
    required this.assignedBy,
    required this.status,
    this.notes,
    required this.assignedAt,
    this.acceptedAt,
    this.completedAt,
    this.complaint,
  });

  factory ComplaintAssignment.fromJson(Map<String, dynamic> json) {
    return ComplaintAssignment(
      id: json['id'] as String,
      complaintId: json['complaint_id'] as String,
      staffId: json['staff_id'] as String,
      assignedBy: json['assigned_by'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      complaint: json['complaints'] != null
          ? Complaint.fromJson(json['complaints'] as Map<String, dynamic>)
          : null,
    );
  }
}