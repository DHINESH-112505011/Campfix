import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/errors/app_exception.dart';

/// Handles all direct Supabase Auth calls. Screens/providers never call
/// Supabase directly - they go through this repository.
class AuthRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String phone,
    required String studentOrStaffId,
    required String department,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'student_or_staff_id': studentOrStaffId,
          'department': department,
          // Role is intentionally NOT accepted from client input.
          // Default role is STUDENT; ADMIN/SUPER_ADMIN are provisioned
          // separately (see Phase 6 RLS + backend rules).
          'role': 'STUDENT',
        },
      );
      return response;
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e.message));
    } catch (_) {
      throw AppException('Something went wrong while creating your account. Please try again.');
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e.message));
    } catch (_) {
      throw AppException('Unable to log in. Please check your connection and try again.');
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      throw AppException('Something went wrong while logging out.');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e.message));
    } catch (_) {
      throw AppException('Unable to send reset email. Please try again.');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e.message));
    } catch (_) {
      throw AppException('Unable to update password. Please try again.');
    }
  }

  User? get currentUser => _client.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  String _mapAuthError(String rawMessage) {
    final msg = rawMessage.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('password should be at least')) {
      return 'Password must be at least 6 characters long.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please confirm your email before logging in.';
    }
    if (msg.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}