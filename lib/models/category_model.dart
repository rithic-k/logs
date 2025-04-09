class Category {
  final int? id;
  final String name;
  final String icon;
  final bool isExpense;
  final DateTime createdAt;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'is_expense': isExpense ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      isExpense: map['is_expense'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
