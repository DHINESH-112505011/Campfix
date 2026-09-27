import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/errors/app_exception.dart';
import '../models/notification_item.dart';

class NotificationRepository {
  final ApiClient _apiClient = ApiClient();

  Future<({List<NotificationItem> items, int unreadCount})> getMyNotifications() async {
    try {
      final response = await _apiClient.get('/notifications');
      final data = response['data'] as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>)
          .map((json) => NotificationItem.fromJson(json as Map<String, dynamic>))
          .toList();
      return (items: items, unreadCount: data['unreadCount'] as int);
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.patch('/notifications/$id/read');
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch('/notifications/read-all');
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }
}