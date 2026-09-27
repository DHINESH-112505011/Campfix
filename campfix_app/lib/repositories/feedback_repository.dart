import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/errors/app_exception.dart';
import '../models/complaint_feedback.dart';

class FeedbackRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> submitFeedback({
    required String complaintId,
    required int rating,
    required bool resolvedSuccessfully,
    String? comment,
  }) async {
    try {
      await _apiClient.post('/complaints/$complaintId/feedback', body: {
        'rating': rating,
        'resolvedSuccessfully': resolvedSuccessfully,
        'comment': comment,
      });
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<ComplaintFeedback?> getFeedback(String complaintId) async {
    try {
      final response = await _apiClient.get('/complaints/$complaintId/feedback');
      final data = response['data'];
      if (data == null) return null;
      return ComplaintFeedback.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }
}