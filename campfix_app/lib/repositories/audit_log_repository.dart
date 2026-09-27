import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/errors/app_exception.dart';
import '../models/audit_log_entry.dart';

class AuditLogRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<AuditLogEntry>> getAuditLogs() async {
    try {
      final response = await _apiClient.get('/audit-logs');
      final data = response['data'] as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items.map((json) => AuditLogEntry.fromJson(json as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }
}