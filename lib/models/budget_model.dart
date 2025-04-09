class Budget {
  final int? id;
  final int categoryId;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  Budget({
    this.id,
    required this.categoryId,
    required this.amount,
    required this.startDate,
    required this.endDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      amount: map['amount'] as double,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
