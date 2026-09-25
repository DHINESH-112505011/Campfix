import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';
import '../core/errors/app_exception.dart';
import '../models/app_role.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  String? _errorMessage;
  AppRole? _fetchedRole;

  AuthProvider() {
    _init();
  }

  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

   /// The real, backend-verified role from the `profiles` table.
  /// Must call refreshProfile() after login before this is reliable;
  /// falls back to STUDENT (never a higher privilege) if not yet fetched.
  AppRole get currentRole => _fetchedRole ?? AppRole.student;

  Future<void> refreshProfile() async {
    try {
      final profile = await _profileRepository.getMyProfile();
      _fetchedRole = AppRoleX.fromString(profile['role'] as String?);
      notifyListeners();
    } on AppException {
      _fetchedRole = AppRole.student; // fail safe, never assume elevated access
      notifyListeners();
    }
  }   


  String? get currentUserEmail => _authRepository.currentUser?.email;
  
  void _init() {
    _status = _authRepository.isLoggedIn
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

    if (_status == AuthStatus.authenticated) {
      refreshProfile();
    }

    _authRepository.authStateChanges.listen((state) {
      _status = state.session != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      if (_status == AuthStatus.authenticated) {
        refreshProfile();
      } else {
        _fetchedRole = null;
      }
      notifyListeners();
    });

    notifyListeners();
  }
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String studentOrStaffId,
    required String department,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authRepository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        studentOrStaffId: studentOrStaffId,
        department: department,
        password: password,
      );
      _errorMessage = null;
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _authRepository.login(email: email, password: password);
      await refreshProfile();
      _errorMessage = null;
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
      _fetchedRole = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authRepository.sendPasswordResetEmail(email);
      _errorMessage = null;
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}