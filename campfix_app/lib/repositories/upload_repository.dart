import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/services/supabase_service.dart';
import '../core/errors/app_exception.dart';

/// Handles multipart image uploads to the backend, which forwards them
/// to Cloudinary (Phase 9). Kept separate from ComplaintRepository since
/// this deals with multipart/form-data, not JSON.
class UploadRepository {
  Future<void> uploadComplaintImage({
    required File imageFile,
    required String complaintId,
    String imageType = 'COMPLAINT',
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/uploads/complaint-image');
      final request = http.MultipartRequest('POST', uri);

      final session = SupabaseService.auth.currentSession;
      final token = session?.accessToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['complaintId'] = complaintId;
      request.fields['imageType'] = imageType;
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 400) {
        throw AppException('Complaint submitted, but the photo could not be uploaded.');
      }
    } on AppException {
      rethrow;
    } catch (_) {
      // Deliberately non-fatal: the complaint itself already succeeded.
      // We surface this as a soft warning rather than blocking the flow.
      throw AppException('Complaint submitted, but the photo could not be uploaded.');
    }
  }
}