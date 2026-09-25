import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/errors/app_exception.dart';
import '../models/complaint_category.dart';

class CategoryRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<ComplaintCategory>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      final items = response['data'] as List<dynamic>;
      return items.map((json) => ComplaintCategory.fromJson(json as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      throw AppException(e.message);
    }
  }
}