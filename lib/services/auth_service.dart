import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../core/api/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Login
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = res['data'];
      final userData = data['user'];
      final tokens = data['tokens'];

      await _secureStorage.write(key: 'auth_token', value: tokens['accessToken']);
      await _secureStorage.write(key: 'refresh_token', value: tokens['refreshToken']);

      return User.fromJson(userData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Email atau password salah');
      }
      throw Exception('Login gagal: ${e.message}');
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _apiClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final data = res['data'];
      final userData = data['user'];
      final tokens = data['tokens'];

      await _secureStorage.write(
        key: 'auth_token',
        value: tokens['accessToken'],
      );
      await _secureStorage.write(
        key: 'refresh_token',
        value: tokens['refreshToken'],
      );

      return User.fromJson(userData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Email sudah terdaftar');
      }
      if (e.response?.statusCode == 422) {
        throw Exception('Data tidak valid');
      }
      throw Exception('Registrasi gagal: ${e.message}');
    } catch (e) {
      throw Exception('Registrasi gagal: $e');
    }
  }

  // Current user (init)
  Future<User?> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return null;

      final res = await _apiClient.get('/auth/me');

      final dynamic payload = res['data'] ?? res['user'] ?? res;
      if (payload is Map<String, dynamic>) {
        return User.fromJson(payload);
      }
      return null;
    } catch (e) {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'refresh_token');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Abaikan error server; tetap clear token lokal
    } finally {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'refresh_token');
    }
  }

  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return null;

      final res = await _apiClient.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );

      final newAccessToken = res['data']['accessToken'];
      await _secureStorage.write(key: 'auth_token', value: newAccessToken);

      return newAccessToken;
    } catch (e) {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'refresh_token');
      return null;
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
}
