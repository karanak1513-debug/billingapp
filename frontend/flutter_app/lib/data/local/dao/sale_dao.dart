import 'package:sqflite/sqflite.dart';

import '../../models/sale_record.dart';

class SaleDao {
  final Database db;

  SaleDao(this.db);

  /// Saves a sale and all its line items atomically in a single transaction.
  Future<void> insertSaleTransaction(SaleRecord sale) async {
    await db.transaction((txn) async {
      // 1. Insert master sale record
      await txn.insert(
        'sales',
        sale.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // 2. Insert all line items
      for (final item in sale.items) {
        await txn.insert(
          'sale_items',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }

      // 3. Increment next token number (cycles 1..99)
      int nextToken = sale.tokenNumber + 1;
      if (nextToken > 99) nextToken = 1;
      await txn.rawUpdate('UPDATE app_settings SET value = ? WHERE key = ?', [
        nextToken.toString(),
        'next_token_seq',
      ]);
    });
  }

  /// Retrieves a sale by ID including its line items
  Future<SaleRecord?> getSaleById(String saleId) async {
    final saleMaps = await db.query(
      'sales',
      where: 'id = ?',
      whereArgs: [saleId],
      limit: 1,
    );

    if (saleMaps.isEmpty) return null;

    final itemMaps = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );

    final items = itemMaps.map((m) => SaleItemRecord.fromMap(m)).toList();
    return SaleRecord.fromMap(saleMaps.first, items: items);
  }

  /// Retrieves a sale by Bill Number
  Future<SaleRecord?> getSaleByBillNumber(String billNumber) async {
    final saleMaps = await db.query(
      'sales',
      where: 'bill_number = ?',
      whereArgs: [billNumber],
      limit: 1,
    );

    if (saleMaps.isEmpty) return null;

    final saleId = saleMaps.first['id'] as String;
    final itemMaps = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );

    final items = itemMaps.map((m) => SaleItemRecord.fromMap(m)).toList();
    return SaleRecord.fromMap(saleMaps.first, items: items);
  }

  /// Queries sales with optional date filtering and search
  Future<List<SaleRecord>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int? limit,
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

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = '%${searchQuery.trim()}%';
      whereClauses.add('(bill_number LIKE ? OR customer_name LIKE ?)');
      whereArgs.add(query);
      whereArgs.add(query);
    }

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final saleMaps = await db.query(
      'sales',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    final List<SaleRecord> sales = [];
    for (final map in saleMaps) {
      final saleId = map['id'] as String;
      final itemMaps = await db.query(
        'sale_items',
        where: 'sale_id = ?',
        whereArgs: [saleId],
      );
      final items = itemMaps.map((m) => SaleItemRecord.fromMap(m)).toList();
      sales.add(SaleRecord.fromMap(map, items: items));
    }

    return sales;
  }

  /// Calculates aggregate metrics for a given date window
  Future<Map<String, dynamic>> getAggregateMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<String> whereClauses = ["payment_status = 'verified'"];
    final List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClauses.add('timestamp >= ?');
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereClauses.add('timestamp <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final where = whereClauses.join(' AND ');

    // 1. Sales summary
    final salesSummary = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_bills,
        COALESCE(SUM(grand_total), 0) as gross_sales,
        COALESCE(SUM(total_items_count), 0) as total_items,
        COALESCE(SUM(CASE WHEN payment_method = 'cash' THEN grand_total ELSE 0 END), 0) as cash_collection,
        COALESCE(SUM(CASE WHEN payment_method = 'phonepe_upi' THEN grand_total ELSE 0 END), 0) as upi_collection
      FROM sales
      WHERE $where
    ''', whereArgs);

    // 2. COGS summary using sale_items snapshot costs
    final cogsSummary = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(si.unit_cost * si.quantity), 0) as total_cogs
      FROM sale_items si
      JOIN sales s ON si.sale_id = s.id
      WHERE $where
    ''', whereArgs);

    // 3. Product-wise sales breakdown for Best-Seller Leaderboard
    final productSummary = await db.rawQuery('''
      SELECT 
        si.product_id,
        si.product_name,
        SUM(si.quantity) as total_quantity,
        SUM(si.line_total) as total_revenue
      FROM sale_items si
      JOIN sales s ON si.sale_id = s.id
      WHERE $where
      GROUP BY si.product_id, si.product_name
      ORDER BY total_quantity DESC
    ''', whereArgs);

    final row = salesSummary.first;
    final grossSales = (row['gross_sales'] as num).toDouble();
    final totalCogs = (cogsSummary.first['total_cogs'] as num).toDouble();
    final netProfit = grossSales - totalCogs;

    return {
      'total_bills': row['total_bills'] as int,
      'gross_sales': grossSales,
      'total_items': (row['total_items'] as num).toInt(),
      'cash_collection': (row['cash_collection'] as num).toDouble(),
      'upi_collection': (row['upi_collection'] as num).toDouble(),
      'total_cogs': totalCogs,
      'net_profit': netProfit,
      'leaderboard': productSummary,
    };
  }
}
