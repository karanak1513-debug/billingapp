import 'package:sqflite/sqflite.dart';

import '../../../features/products/models/product.dart';

class ProductDao {
  final Database db;

  ProductDao(this.db);

  /// Retrieves active products for customer billing and quick sales
  Future<List<Product>> getAllProducts() async {
    final maps = await db.query(
      'products',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'category DESC, name ASC',
    );
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  /// Retrieves all products (active and inactive) for management
  Future<List<Product>> getAllProductsAdmin({
    bool? isActive,
    String? category,
    String? search,
  }) async {
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (isActive != null) {
      whereClauses.add('is_active = ?');
      whereArgs.add(isActive ? 1 : 0);
    }

    if (category != null && category.isNotEmpty && category != 'all') {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if (search != null && search.trim().isNotEmpty) {
      whereClauses.add('(LOWER(name) LIKE ? OR LOWER(badge) LIKE ?)');
      final term = '%${search.trim().toLowerCase()}%';
      whereArgs.add(term);
      whereArgs.add(term);
    }

    final whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final maps = await db.query(
      'products',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'is_active DESC, category ASC, name ASC',
    );
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<int> insertProduct(Product product) async {
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateProduct(Product product) async {
    final data = product.toMap();
    data['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'products',
      data,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> updateProductPrice({
    required String id,
    required double sellingPrice,
    required double costPrice,
  }) async {
    return await db.update(
      'products',
      {
        'selling_price': sellingPrice,
        'cost_price': costPrice,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> setProductActive(String id, bool isActive) async {
    return await db.update(
      'products',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Checks if product is referenced in historical sale items
  Future<bool> isProductReferencedInSales(String id) async {
    try {
      final res = await db.rawQuery(
        'SELECT COUNT(*) as count FROM sale_items WHERE product_id = ?',
        [id],
      );
      if (res.isNotEmpty) {
        final count = (res.first['count'] as num?)?.toInt() ?? 0;
        return count > 0;
      }
    } catch (_) {
      // If table doesn't exist yet, return false
    }
    return false;
  }

  /// Deletes product safely:
  /// - If referenced in previous sales, soft-deactivates to preserve financial history.
  /// - If never used in sales, fully deletes the record.
  /// Returns true if permanently deleted, false if soft-deactivated.
  Future<bool> deleteProductSafely(String id) async {
    final isUsed = await isProductReferencedInSales(id);
    if (isUsed) {
      await setProductActive(id, false);
      return false; // Soft-deleted
    } else {
      await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true; // Hard-deleted
    }
  }

  /// Returns list of distinct categories currently present in products table
  Future<List<String>> getDistinctCategories() async {
    final maps = await db.rawQuery(
      'SELECT DISTINCT category FROM products ORDER BY category ASC',
    );
    final categories = maps
        .map((m) => (m['category'] as String?)?.trim())
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toList();

    // Ensure snacks and drinks are present as canonical fallbacks
    if (!categories.contains('snacks')) categories.insert(0, 'snacks');
    if (!categories.contains('drinks')) {
      final sipsIndex = categories.indexOf('sips');
      if (sipsIndex != -1) {
        categories[sipsIndex] = 'drinks';
      } else {
        categories.add('drinks');
      }
    }
    categories.remove('sips');

    return categories;
  }
}
