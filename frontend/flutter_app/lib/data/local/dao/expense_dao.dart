import 'package:sqflite/sqflite.dart';

import '../../models/expense_record.dart';

class ExpenseDao {
  final Database db;

  ExpenseDao(this.db);

  Future<int> insertExpense(ExpenseRecord expense) async {
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<ExpenseRecord>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClauses.add('timestamp >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('timestamp <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final maps = await db.query(
      'expenses',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'timestamp DESC',
    );

    return maps.map((m) => ExpenseRecord.fromMap(m)).toList();
  }

  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClauses.add('timestamp >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('timestamp <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final where = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM expenses
      $where
    ''', whereArgs);

    return (result.first['total'] as num).toDouble();
  }
}
