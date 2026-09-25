import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/errors/app_exception.dart';
import '../models/complaint.dart';
import '../models/complaint_draft.dart';
import '../models/timeline_event.dart';   

/// Provides complaint data to the UI via the real backend API (Phase 8).
/// Method signatures deliberately match the earlier mock implementation
/// so no screen built in Phase 4/5 needed to change.
class ComplaintRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<Complaint>> getMyComplaints() async {
    try {
      final response = await _apiClient.get('/complaints');
      final items = (response['data']['items'] as List<dynamic>);
      return items.map((json) => Complaint.fromJson(json as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }

    Future<Complaint> getComplaintById(String id) async {
    try {
      final response = await _apiClient.get('/complaints/$id');
      return Complaint.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<Complaint> updateStatus(String complaintId, String newStatus) async {
    try {
      final response = await _apiClient.patch(
        '/complaints/$complaintId/status',
        body: {'status': newStatus},
      );
      return Complaint.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<List<TimelineEvent>> getTimeline(String complaintId) async {
    try {
      final response = await _apiClient.get('/complaints/$complaintId/timeline');
      final items = response['data'] as List<dynamic>;
      return items.map((json) => TimelineEvent.fromJson(json as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<({int total, int active, int resolved})> getMyStats() async {
    final complaints = await getMyComplaints();
    final total = complaints.length;
    final resolved = complaints.where((c) => c.isResolved).length;
    final active = complaints.where((c) => c.isActive).length;
    return (total: total, active: active, resolved: resolved);
  }

  Future<({String id, String complaintNumber})> submitComplaint(ComplaintDraft draft) async {
    try {
      final response = await _apiClient.post('/complaints', body: {
        'categoryId': draft.categoryId,
        'title': draft.title,
        'description': draft.description,
        'priority': draft.aiPriority,
        'aiCategory': draft.aiCategory,
        'aiPriority': draft.aiPriority,
        'aiConfidence': draft.aiConfidence,
        'campus': draft.campus,
        'building': draft.building,
        'block': draft.block.isEmpty ? null : draft.block,
        'floor': draft.floor.isEmpty ? null : draft.floor,
        'room': draft.room,
        'specificLocation': draft.specificLocation.isEmpty ? null : draft.specificLocation,
      });
      final data = response['data'] as Map<String, dynamic>;
      return (id: data['id'] as String, complaintNumber: data['complaint_number'] as String);
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }
}