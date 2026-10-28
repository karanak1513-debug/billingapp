import 'package:sqflite/sqflite.dart';

import '../../../features/settings/models/payment_settings.dart';

class SettingsDao {
  final Database db;

  SettingsDao(this.db);

  Future<String?> getSetting(String key) async {
    final maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    await db.insert('app_settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Atomically increments and returns the next bill number string (e.g. "SOC-1048")
  Future<String> generateNextBillNumber() async {
    return await db.transaction((txn) async {
      final maps = await txn.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: ['next_bill_seq'],
        limit: 1,
      );

      int currentSeq = 1001;
      if (maps.isNotEmpty && maps.first['value'] != null) {
        currentSeq = int.tryParse(maps.first['value'] as String) ?? 1001;
      }

      final billNumber = 'SOC-$currentSeq';

      await txn.insert('app_settings', {
        'key': 'next_bill_seq',
        'value': (currentSeq + 1).toString(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return billNumber;
    });
  }

  /// Gets the current token number
  Future<int> getCurrentTokenNumber() async {
    final val = await getSetting('next_token_seq');
    return int.tryParse(val ?? '1') ?? 1;
  }

  /// Gets the opening cash float
  Future<double> getOpeningFloat() async {
    final val = await getSetting('opening_cash_float');
    return double.tryParse(val ?? '1500.0') ?? 1500.0;
  }

  /// Updates opening cash float
  Future<void> setOpeningFloat(double amount) async {
    await setSetting('opening_cash_float', amount.toString());
  }

  /// Gets cashier name
  Future<String> getCashierName() async {
    final val = await getSetting('cashier_name');
    return val ?? 'Rahul';
  }

  /// Sets cashier name
  Future<void> setCashierName(String name) async {
    await setSetting('cashier_name', name);
  }

  /// Fetches the configured PaymentSettings (UPI ID, merchant name, QR path)
  Future<PaymentSettings> getPaymentSettings() async {
    final upi = await getSetting('upi_id') ?? await getSetting('upi_vpa');
    final merchant =
        await getSetting('merchant_name') ?? await getSetting('stall_name');
    final instructions = await getSetting('payment_instructions');
    final qrPath = await getSetting('qr_image_path');
    final updatedAt = await getSetting('payment_settings_updated_at');

    return PaymentSettings.fromMap({
      'upi_id': upi,
      'merchant_name': merchant,
      'payment_instructions': instructions,
      'qr_image_path': qrPath,
      'payment_settings_updated_at': updatedAt,
    });
  }

  /// Persists updated payment settings atomically
  Future<void> savePaymentSettings(PaymentSettings settings) async {
    final map = settings.toMap();
    await db.transaction((txn) async {
      for (final entry in map.entries) {
        await txn.insert('app_settings', {
          'key': entry.key,
          'value': entry.value,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
