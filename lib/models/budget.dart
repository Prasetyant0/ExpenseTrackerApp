import 'category.dart';

enum BudgetPeriod {
  weekly,
  monthly,
  yearly,
}

class Budget {
  final int id;
  final int userId;
  final int categoryId;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final double? alertThreshold;
  final Category? category;
  final double? totalSpent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.alertThreshold,
    this.category,
    this.totalSpent,
    this.createdAt,
    this.updatedAt,
  });

  // Calculated properties
  double get remainingAmount => amount - (totalSpent ?? 0.0);
  double get spentPercentage => totalSpent != null && amount > 0
      ? (totalSpent! / amount).clamp(0.0, 1.0)
      : 0.0;
  bool get isOverBudget => (totalSpent ?? 0.0) > amount;
  bool get isNearThreshold => alertThreshold != null &&
      spentPercentage >= alertThreshold!;

  // From JSON
  factory Budget.fromJson(Map<String, dynamic> json) {
    BudgetPeriod parsePeriod(String period) {
      switch (period) {
        case 'weekly':
          return BudgetPeriod.weekly;
        case 'monthly':
          return BudgetPeriod.monthly;
        case 'yearly':
          return BudgetPeriod.yearly;
        default:
          return BudgetPeriod.monthly;
      }
    }

    return Budget(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      categoryId: json['category_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      period: parsePeriod(json['period'] as String),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] as bool? ?? true,
      alertThreshold: json['alert_threshold'] != null
          ? (json['alert_threshold'] as num).toDouble()
          : null,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      totalSpent: json['total_spent'] != null
          ? (json['total_spent'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    String periodToString(BudgetPeriod period) {
      switch (period) {
        case BudgetPeriod.weekly:
          return 'weekly';
        case BudgetPeriod.monthly:
          return 'monthly';
        case BudgetPeriod.yearly:
          return 'yearly';
      }
    }

    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'period': periodToString(period),
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'is_active': isActive,
      'alert_threshold': alertThreshold,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // For create/update request body
  Map<String, dynamic> toRequestJson() {
    String periodToString(BudgetPeriod period) {
      switch (period) {
        case BudgetPeriod.weekly:
          return 'weekly';
        case BudgetPeriod.monthly:
          return 'monthly';
        case BudgetPeriod.yearly:
          return 'yearly';
      }
    }

    return {
      'category_id': categoryId,
      'amount': amount,
      'period': periodToString(period),
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'is_active': isActive,
      if (alertThreshold != null) 'alert_threshold': alertThreshold,
    };
  }

  Budget copyWith({
    int? id,
    int? userId,
    int? categoryId,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    double? alertThreshold,
    Category? category,
    double? totalSpent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      category: category ?? this.category,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Budget &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Budget(id: $id, amount: $amount, period: $period)';
}
