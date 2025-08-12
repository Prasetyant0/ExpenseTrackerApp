import 'dart:io';
class ApiConstants {
  // Base URL
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:5000/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/profile';
  static const String logoutEndpoint = '/auth/logout';

  // Transaction endpoints
  static const String transactionsEndpoint = '/transactions';

  // Budget endpoints
  static const String budgetsEndpoint = '/budgets';

  // Category endpoints
  static const String categoriesEndpoint = '/categories';

  // Report endpoints
  static const String reportsEndpoint = '/reports';

  // Notification endpoints
  static const String notificationsEndpoint = '/notifications';

  // Reminder endpoints
  static const String remindersEndpoint = '/reminders';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Storage keys
  static const String authTokenKey = 'auth_token';
}
