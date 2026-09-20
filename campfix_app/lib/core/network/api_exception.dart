/// Thrown by ApiClient when a request fails. Carries a user-friendly
/// message only - raw backend error details are never surfaced (§95).
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  ApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}