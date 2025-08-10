class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://localhost:5000/api';

  // Authentication endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile';

  // Transaction endpoints
  static const String transactions = '/transactions';
  static const String transactionsDashboard = '/transactions/dashboard';

  // Budget endpoints
  static const String budgets = '/budgets';
  static const String budgetSpending = '/budgets/spending';

  // Category endpoints
  static const String categories = '/categories';

  // Reports endpoints
  static const String reportsSummary = '/reports/summary';
  static const String reportsTrends = '/reports/trends';
  static const String reportsInsights = '/reports/insights';

  // Notification endpoints
  static const String notifications = '/notifications';

  // Reminder endpoints
  static const String reminders = '/reminders';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
