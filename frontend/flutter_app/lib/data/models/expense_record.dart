class ExpenseRecord {
  final String id;
  final String category; // 'raw_food' | 'packaging' | 'gas_fuel' | 'misc'
  final String description;
  final double amount;
  final DateTime timestamp;

  const ExpenseRecord({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ExpenseRecord.fromMap(Map<String, dynamic> map) {
    return ExpenseRecord(
      id: map['id'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
