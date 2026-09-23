import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/errors/app_exception.dart';
import '../models/dashboard_stats.dart';

class DashboardRepository {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardStats> getAdminDashboard() async {
    try {
      final response = await _apiClient.get('/dashboard/admin');
      return DashboardStats.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }
}