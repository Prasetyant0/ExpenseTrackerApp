import 'category.dart';

enum TransactionType {
  income,
  expense,
}

class Transaction {
  final int id;
  final int userId;
  final int categoryId;
  final TransactionType type;
  final double amount;
  final String? description;
  final DateTime transactionDate;
  final String? attachmentUrl;
  final Category? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.description,
    required this.transactionDate,
    this.attachmentUrl,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      categoryId: json['category_id'] as int,
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['transaction_date']),
      attachmentUrl: json['attachment_url'] as String?,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
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
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate.toIso8601String(),
      'attachment_url': attachmentUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // For create/update request body
  Map<String, dynamic> toRequestJson() {
    return {
      'category_id': categoryId,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
    };
  }

  Transaction copyWith({
    int? id,
    int? userId,
    int? categoryId,
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? transactionDate,
    String? attachmentUrl,
    Category? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Transaction(id: $id, type: $type, amount: $amount)';
}
