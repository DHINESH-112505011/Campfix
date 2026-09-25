import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/errors/app_exception.dart';
import '../models/staff_member.dart';

class StaffRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<StaffMember>> getAvailableStaff() async {
    try {
      final response = await _apiClient.get('/staff/available');
      final items = response['data'] as List<dynamic>;
      return items.map((json) => StaffMember.fromJson(json as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }
}