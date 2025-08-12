enum CategoryType {
  income,
  expense,
}

class Category {
  final int id;
  final String name;
  final CategoryType type;
  final String icon;
  final String color;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] == 'income'
        ? CategoryType.income
        : CategoryType.expense,
      icon: json['icon'] as String,
      color: json['color'] as String,
      isDefault: json['is_default'] as bool? ?? false,
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
      'name': name,
      'type': type == CategoryType.income ? 'income' : 'expense',
      'icon': icon,
      'color': color,
      'is_default': isDefault,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    CategoryType? type,
    String? icon,
    String? color,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name, type: $type)';
}
