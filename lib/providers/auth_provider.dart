import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setAuth(User? u) {
    _user = u;
    _isAuthenticated = u != null;
    notifyListeners();
  }

  Future<void> initialize() async {
    try {
      _setLoading(true);
      _setError(null);
      final current = await _authService.getCurrentUser();
      _setAuth(current);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      final u = await _authService.login(email: email, password: password);
      _setAuth(u);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      final u = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      _setAuth(u);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      _setAuth(null);
      _setError(null);
    }
  }
}
