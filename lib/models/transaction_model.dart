enum TransactionType { income, expense }

class Transaction {
  final int? id;
  final String description;
  final double amount;
  final TransactionType type;
  final int categoryId;
  final DateTime date;
  final DateTime createdAt;

  Transaction({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type.index,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      description: map['description'] as String,
      amount: map['amount'] as double,
      type: TransactionType.values[map['type'] as int],
      categoryId: map['category_id'] as int,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
