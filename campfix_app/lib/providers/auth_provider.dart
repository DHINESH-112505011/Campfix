import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../core/errors/app_exception.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _init();
  }

  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _init() {
    _status = _authRepository.isLoggedIn
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

    _authRepository.authStateChanges.listen((state) {
      _status = state.session != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
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