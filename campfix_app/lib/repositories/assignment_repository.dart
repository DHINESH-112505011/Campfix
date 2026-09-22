import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/errors/app_exception.dart';
import '../models/complaint_assignment.dart';

class AssignmentRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<ComplaintAssignment>> getMyAssignments({String? status}) async {
    try {
      final response = await _apiClient.get(
        '/assignments/my',
        query: status != null ? {'status': status} : null,
      );
      final items = response['data'] as List<dynamic>;
      return items.map((json) => ComplaintAssignment.fromJson(json as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<ComplaintAssignment> accept(String assignmentId) async {
    try {
      final response = await _apiClient.patch('/assignments/$assignmentId/accept');
      return ComplaintAssignment.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<ComplaintAssignment> startWork(String assignmentId) async {
    try {
      final response = await _apiClient.patch('/assignments/$assignmentId/start');
      return ComplaintAssignment.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<ComplaintAssignment> markCompleted(String assignmentId, {String? notes}) async {
    try {
      final response = await _apiClient.patch(
        '/assignments/$assignmentId/complete',
        body: {'notes': notes},
      );
      return ComplaintAssignment.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }
}