import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}

class ApiClient {
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: ApiConstants.defaultHeaders,
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor - add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        _logger.d('Request: ${options.method} ${options.uri}');
        _logger.d('Headers: ${options.headers}');
        if (options.data != null) {
          _logger.d('Data: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('Response: ${response.statusCode} ${response.statusMessage}');
        _logger.d('Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('Error: ${error.message}');
        _logger.e('Response: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }

  Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.authTokenKey); // FIX: was tokenKey
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: ApiConstants.authTokenKey, value: token); // FIX
  }

  Future<void> clearToken() async {
    await _storage.delete(key: ApiConstants.authTokenKey); // FIX
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data as Map<String, dynamic>;
    } else {
      throw ApiException(
        'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  ApiException _handleError(DioException error) {
    String message = 'Something went wrong';
    int? statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        if (responseData != null && responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? responseData['error'] ?? message;
        } else {
          message = 'Server error: ${error.response?.statusMessage}';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection';
        break;
      case DioExceptionType.unknown:
        message = 'An unexpected error occurred';
        break;
      default:
        message = error.message ?? 'An unexpected error occurred';
    }

    return ApiException(message, statusCode: statusCode);
  }
}
