import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/errors/app_exception.dart';

/// Fetches the authenticated user's REAL profile (including role) from
/// the backend, which reads it from the `profiles` table - the actual
/// source of truth, not the Supabase Auth session metadata.
class ProfileRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await _apiClient.get('/profile/me');
      return response['data'] as Map<String, dynamic>;
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }
}