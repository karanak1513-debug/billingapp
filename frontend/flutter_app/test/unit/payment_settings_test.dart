import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_app/core/constants/app_constants.dart';
import 'package:flutter_app/core/utils/validators.dart';
import 'package:flutter_app/data/local/dao/settings_dao.dart';
import 'package:flutter_app/features/settings/models/payment_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('Validators Unit Tests', () {
    test('Valid UPI IDs pass validation', () {
      expect(Validators.validateUpiId('karan1513.wallet@phonepe'), isNull);
      expect(Validators.validateUpiId('stallname@upi'), isNull);
      expect(Validators.validateUpiId('9876543210@paytm'), isNull);
      expect(Validators.validateUpiId('my-shop_123@okaxis'), isNull);
      expect(Validators.validateUpiId('snacks.stall@icici'), isNull);
    });

    test('Invalid UPI IDs fail validation with descriptive errors', () {
      expect(Validators.validateUpiId(null), contains('cannot be empty'));
      expect(Validators.validateUpiId(''), contains('cannot be empty'));
      expect(Validators.validateUpiId('   '), contains('cannot be empty'));
      expect(Validators.validateUpiId('karan1513phonepe'), contains('@'));
      expect(Validators.validateUpiId('@phonepe'), contains('Invalid UPI ID'));
      expect(Validators.validateUpiId('karan@'), contains('Invalid UPI ID'));
      expect(
        Validators.validateUpiId('karan user@upi'),
        contains('Invalid UPI ID'),
      );
      expect(
        Validators.validateUpiId('karan!#\$@upi'),
        contains('Invalid UPI ID'),
      );
    });

    test('Merchant name validation rules', () {
      expect(Validators.validateMerchantName("Snacks O'Clock"), isNull);
      expect(Validators.validateMerchantName('Hot & Crispy Stall'), isNull);
      expect(
        Validators.validateMerchantName(null),
        contains('cannot be empty'),
      );
      expect(Validators.validateMerchantName(''), contains('cannot be empty'));
      expect(
        Validators.validateMerchantName('   '),
        contains('cannot be empty'),
      );
      expect(
        Validators.validateMerchantName('A'),
        contains('at least 2 characters'),
      );
    });
  });

  group('PaymentSettings Model Unit Tests', () {
    test('Default settings use authentic Stitch defaults', () {
      final defaults = PaymentSettings.defaultSettings();
      expect(defaults.upiId, AppConstants.merchantUpiVpa);
      expect(defaults.merchantName, AppConstants.appName);
      expect(defaults.qrImagePath, AppConstants.imgPhonePeQr);
      expect(defaults.hasQr, isTrue);
      expect(defaults.isLocalFile, isFalse);
    });

    test('isLocalFile returns true only for local filesystem paths', () {
      final assetSettings = PaymentSettings(
        upiId: 'test@upi',
        merchantName: 'Test',
        qrImagePath: 'assets/payments/phonepe_qr.png',
        updatedAt: DateTime.now(),
      );
      expect(assetSettings.isLocalFile, isFalse);

      final localSettings = PaymentSettings(
        upiId: 'test@upi',
        merchantName: 'Test',
        qrImagePath: '/data/user/0/com.snacksoclock.pos/app_flutter/qr_codes/stall_qr.png',
        updatedAt: DateTime.now(),
      );
      expect(localSettings.isLocalFile, isTrue);

      final noQrSettings = PaymentSettings(
        upiId: 'test@upi',
        merchantName: 'Test',
        qrImagePath: null,
        updatedAt: DateTime.now(),
      );
      expect(noQrSettings.hasQr, isFalse);
      expect(noQrSettings.isLocalFile, isFalse);
    });

    test('toMap and fromMap round-trip serialization', () {
      final original = PaymentSettings(
        upiId: 'customstall@upi',
        merchantName: 'Fresh Bites Corner',
        paymentInstructions: 'Please show success checkmark to cashier.',
        qrImagePath: '/storage/emulated/0/Download/my_qr.png',
        updatedAt: DateTime.parse('2026-10-23T12:00:00.000Z'),
      );

      final map = original.toMap();
      final restored = PaymentSettings.fromMap(map);

      expect(restored.upiId, 'customstall@upi');
      expect(restored.merchantName, 'Fresh Bites Corner');
      expect(
        restored.paymentInstructions,
        'Please show success checkmark to cashier.',
      );
      expect(restored.qrImagePath, '/storage/emulated/0/Download/my_qr.png');
      expect(
        restored.updatedAt.toIso8601String(),
        original.updatedAt.toIso8601String(),
      );
      expect(restored.hasQr, isTrue);
      expect(restored.isLocalFile, isTrue);
    });

    test(
      'fromMap with empty string qr_image_path resolves to null (removed QR)',
      () {
        final map = {
          'upi_id': 'karan@upi',
          'merchant_name': 'Snacks Corner',
          'payment_instructions': 'Pay here',
          'qr_image_path': '', // Explicitly removed
          'payment_settings_updated_at': DateTime.now().toIso8601String(),
        };

        final settings = PaymentSettings.fromMap(map);
        expect(settings.qrImagePath, isNull);
        expect(settings.hasQr, isFalse);
      },
    );

    test('copyWith updates specified fields and clearQr resets QR path', () {
      final original = PaymentSettings.defaultSettings();
      final updated = original.copyWith(
        upiId: 'new_stall@upi',
        merchantName: 'New Stall Name',
      );

      expect(updated.upiId, 'new_stall@upi');
      expect(updated.merchantName, 'New Stall Name');
      expect(updated.qrImagePath, original.qrImagePath);

      final cleared = updated.copyWith(clearQr: true);
      expect(cleared.qrImagePath, isNull);
      expect(cleared.hasQr, isFalse);
    });
  });

  group('SettingsDao Database Persistence Tests', () {
    late Database db;
    late SettingsDao dao;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, version) async {
            await database.execute('''
              CREATE TABLE app_settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
              )
            ''');
            // Seed initial settings
            await database.insert('app_settings', {
              'key': 'next_bill_seq',
              'value': '1001',
            });
            await database.insert('app_settings', {
              'key': 'cashier_name',
              'value': 'Rahul',
            });
            await database.insert('app_settings', {
              'key': 'upi_vpa',
              'value': AppConstants.merchantUpiVpa,
            });
            await database.insert('app_settings', {
              'key': 'stall_name',
              'value': AppConstants.appName,
            });
          },
        ),
      );
      dao = SettingsDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Initial getPaymentSettings uses backward-compatible fallbacks and default QR', () async {
      final settings = await dao.getPaymentSettings();
      expect(settings.upiId, AppConstants.merchantUpiVpa);
      expect(settings.merchantName, AppConstants.appName);
      expect(settings.hasQr, isTrue);
      expect(settings.qrImagePath, AppConstants.imgPhonePeQr);
    });

    test(
      'savePaymentSettings persists custom UPI and custom QR path',
      () async {
        final custom = PaymentSettings(
          upiId: 'custom_merchant@okhdfcbank',
          merchantName: 'Snacks Stall Phase 2',
          paymentInstructions: 'Show green screen to token counter.',
          qrImagePath: '/app/documents/qr_codes/stall_qr_12345.png',
          updatedAt: DateTime.now(),
        );

        await dao.savePaymentSettings(custom);

        final loaded = await dao.getPaymentSettings();
        expect(loaded.upiId, 'custom_merchant@okhdfcbank');
        expect(loaded.merchantName, 'Snacks Stall Phase 2');
        expect(
          loaded.paymentInstructions,
          'Show green screen to token counter.',
        );
        expect(
          loaded.qrImagePath,
          '/app/documents/qr_codes/stall_qr_12345.png',
        );
        expect(loaded.hasQr, isTrue);
        expect(loaded.isLocalFile, isTrue);
      },
    );

    test(
      'Removing QR persists empty string and resolves hasQr to false',
      () async {
        final custom = PaymentSettings(
          upiId: 'custom_merchant@okhdfcbank',
          merchantName: 'Snacks Stall Phase 2',
          paymentInstructions: 'Show green screen to token counter.',
          qrImagePath: null,
          updatedAt: DateTime.now(),
        );

        await dao.savePaymentSettings(custom);

        final loaded = await dao.getPaymentSettings();
        expect(loaded.qrImagePath, isNull);
        expect(loaded.hasQr, isFalse);
      },
    );

    test(
      'Saving payment settings does NOT mutate bill sequence or cashier name',
      () async {
        final custom = PaymentSettings(
          upiId: 'new_stall@upi',
          merchantName: 'New Merchant',
          updatedAt: DateTime.now(),
        );

        await dao.savePaymentSettings(custom);

        // Verify billing sequence and cashier are untouched
        final billNum = await dao.generateNextBillNumber();
        expect(billNum, 'SOC-1001');

        final cashier = await dao.getCashierName();
        expect(cashier, 'Rahul');
      },
    );
  });
}
