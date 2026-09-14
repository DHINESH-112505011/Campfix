/// Friendly, user-facing exception. Never expose raw Supabase/Postgres
/// error text directly to the UI (see project rule: no raw technical errors).
class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}