import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      await _saveAuthData(token, user);

      return AuthResult.success(user: user, token: token);
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      await _saveAuthData(token, user);

      return AuthResult.success(user: user, token: token);
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  Future<AuthResult> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      final userData = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      // Update stored user data
      await _storage.write(
        key: ApiConstants.userKey,
        value: jsonEncode(user.toJson()),
      );

      return AuthResult.success(user: user);
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  Future<AuthResult> updateProfile({
    required String fullName,
    required String email,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateProfile,
        data: {
          'full_name': fullName,
          'email': email,
        },
      );

      final userData = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      // Update stored user data
      await _storage.write(
        key: ApiConstants.userKey,
        value: jsonEncode(user.toJson()),
      );

      return AuthResult.success(user: user);
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  Future<void> logout() async {
    try {
      // Try to logout from server, but don't throw if it fails
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Ignore server logout errors
    }

    // Always clear local data
    await _clearAuthData();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: ApiConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<User?> getCurrentUser() async {
    try {
      final userJson = await _storage.read(key: ApiConstants.userKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.tokenKey);
  }

  Future<void> _saveAuthData(String token, User user) async {
    await _apiClient.setToken(token);
    await _storage.write(
      key: ApiConstants.userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<void> _clearAuthData() async {
    await _apiClient.clearToken();
    await _storage.delete(key: ApiConstants.userKey);
  }
}

class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? token;

  AuthResult._({
    required this.success,
    this.message,
    this.user,
    this.token,
  });

  factory AuthResult.success({User? user, String? token}) {
    return AuthResult._(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure({required String message}) {
    return AuthResult._(
      success: false,
      message: message,
    );
  }
}
