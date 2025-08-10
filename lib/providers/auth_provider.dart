import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  Future<void> initialize() async {
    _setState(AuthState.loading);

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _user = user;
          _setState(AuthState.authenticated);
          return;
        }
      }
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setState(AuthState.unauthenticated);
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setState(AuthState.loading);
    _clearError();

    try {
      final result = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (result.success && result.user != null) {
        _user = result.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(result.message ?? 'Registration failed');
        _setState(AuthState.unauthenticated);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    _clearError();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        _user = result.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(result.message ?? 'Login failed');
        _setState(AuthState.unauthenticated);
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
  }) async {
    _setState(AuthState.loading);
    _clearError();

    try {
      final result = await _authService.updateProfile(
        fullName: fullName,
        email: email,
      );

      if (result.success && result.user != null) {
        _user = result.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(result.message ?? 'Profile update failed');
        _setState(AuthState.authenticated); // Keep authenticated state
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: $e');
      _setState(AuthState.authenticated); // Keep authenticated state
      return false;
    }
  }

  Future<void> refreshProfile() async {
    if (_state != AuthState.authenticated) return;

    try {
      final result = await _authService.getProfile();
      if (result.success && result.user != null) {
        _user = result.user;
        notifyListeners();
      }
    } catch (e) {
      // Don't change auth state for profile refresh errors
      debugPrint('Profile refresh failed: $e');
    }
  }

  Future<void> logout() async {
    _setState(AuthState.loading);

    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _user = null;
      _clearError();
      _setState(AuthState.unauthenticated);
    }
  }

  void clearError() {
    _clearError();
  }

  void _setState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
