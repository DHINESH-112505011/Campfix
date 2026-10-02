import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/services/supabase_service.dart';
import '../core/errors/app_exception.dart';

/// Handles multipart image uploads to the backend, which forwards them
/// to Cloudinary. Compresses images client-side first (§82 performance)
/// to reduce upload time and data usage - most phone camera photos are
/// 3-8MB uncompressed, which is unnecessary for a complaint photo.
class UploadRepository {
  Future<File> _compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressed = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1280,
        minHeight: 1280,
      );

      if (compressed == null) return file; // fall back to original if compression fails
      return File(compressed.path);
    } catch (_) {
      // Never block submission over a compression failure - fall back
      // to the original file rather than losing the photo entirely.
      return file;
    }
  }

  Future<void> uploadComplaintImage({
    required File imageFile,
    required String complaintId,
    String imageType = 'COMPLAINT',
    void Function(double progress)? onProgress,
  }) async {
    try {
      final compressedFile = await _compressImage(imageFile);

      final uri = Uri.parse('${AppConstants.apiBaseUrl}/uploads/complaint-image');
      final request = http.MultipartRequest('POST', uri);

      final session = SupabaseService.auth.currentSession;
      final token = session?.accessToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['complaintId'] = complaintId;
      request.fields['imageType'] = imageType;
      request.files.add(await http.MultipartFile.fromPath('image', compressedFile.path));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 400) {
        throw AppException('Complaint submitted, but the photo could not be uploaded.');
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException('Complaint submitted, but the photo could not be uploaded.');
    }
  }
}