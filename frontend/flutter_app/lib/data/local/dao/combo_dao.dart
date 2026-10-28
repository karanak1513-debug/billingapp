import 'package:sqflite/sqflite.dart';
import '../../../features/combos/models/combo.dart';

class ComboDao {
  final Database db;

  ComboDao(this.db);

  /// Retrieves all active combos for POS billing
  Future<List<ComboModel>> getAllActiveCombos() async {
    final comboMaps = await db.query(
      'combos',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'selling_price ASC',
    );

    final results = <ComboModel>[];
    for (final map in comboMaps) {
      final comboId = map['id'] as String;
      final itemMaps = await db.query(
        'combo_items',
        where: 'combo_id = ?',
        whereArgs: [comboId],
      );

      final includedProductIds = itemMaps.map((m) => m['product_id'] as String).toList();
      results.add(ComboModel.fromMap(map, includedProductIds: includedProductIds));
    }

    return results;
  }

  /// Retrieves all combos for admin management
  Future<List<ComboModel>> getAllCombosAdmin() async {
    final comboMaps = await db.query(
      'combos',
      orderBy: 'is_active DESC, selling_price ASC',
    );

    final results = <ComboModel>[];
    for (final map in comboMaps) {
      final comboId = map['id'] as String;
      final itemMaps = await db.query(
        'combo_items',
        where: 'combo_id = ?',
        whereArgs: [comboId],
      );

      final includedProductIds = itemMaps.map((m) => m['product_id'] as String).toList();
      results.add(ComboModel.fromMap(map, includedProductIds: includedProductIds));
    }

    return results;
  }

  /// Updates combo active status
  Future<int> setComboActive(String id, bool isActive) async {
    return await db.update(
      'combos',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Updates combo price
  Future<int> updateComboPrice(String id, double price) async {
    return await db.update(
      'combos',
      {
        'selling_price': price,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
