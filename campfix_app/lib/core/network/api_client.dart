import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../services/supabase_service.dart';
import 'api_exception.dart';

/// Centralized HTTP client (§70). Screens/repositories never call `http`
/// directly - everything routes through here so auth headers, JSON
/// parsing, and error handling stay consistent across the whole app.
class ApiClient {
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, String>> _headers() async {
    final session = SupabaseService.auth.currentSession;
    final token = session?.accessToken;

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(AppConstants.apiBaseUrl);
    return base.replace(
      path: '${base.path}$path',
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await http
          .get(_uri(path, query), headers: await _headers())
          .timeout(_timeout);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Unable to connect. Please check your internet connection.');
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .post(_uri(path), headers: await _headers(), body: jsonEncode(body ?? {}))
          .timeout(_timeout);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Unable to connect. Please check your internet connection.');
    }
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .patch(_uri(path), headers: await _headers(), body: jsonEncode(body ?? {}))
          .timeout(_timeout);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Unable to connect. Please check your internet connection.');
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await http
          .delete(_uri(path), headers: await _headers())
          .timeout(_timeout);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Unable to connect. Please check your internet connection.');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Something went wrong. Please try again.', statusCode: response.statusCode);
    }

    final success = json['success'] == true;

    if (!success || response.statusCode >= 400) {
      final message = json['message'] as String? ?? 'Something went wrong. Please try again.';
      final code = (json['error'] as Map<String, dynamic>?)?['code'] as String?;
      throw ApiException(message, statusCode: response.statusCode, code: code);
    }

    return json;
  }
}