import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter_app/data/local/database/app_database.dart';
import 'package:flutter_app/data/local/dao/product_dao.dart';
import 'package:flutter_app/data/models/sale_record.dart';
import 'package:flutter_app/data/repositories/pos_repository.dart';
import 'package:flutter_app/data/repositories/repository_provider.dart';
import 'package:flutter_app/features/products/models/product.dart';
import 'package:flutter_app/features/dashboard/screens/dashboard_shell_screen.dart';

class _FakePosRepository extends PosRepository {
  @override
  Future<int> getCurrentToken() async => 1;

  @override
  Future<String> getCashierName() async => 'Rahul';

  @override
  Future<double> getOpeningFloat() async => 1500.0;

  @override
  Future<List<Product>> getProducts() async => [];

  @override
  Future<List<Product>> getProductsAdmin({
    bool? isActive,
    String? category,
    String? search,
  }) async => [];

  @override
  Future<List<String>> getCategories() async => ['snacks', 'sips'];

  @override
  Future<List<SaleRecord>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int? limit,
  }) async => [];

  @override
  Future<Map<String, dynamic>> getShiftReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async => {
    'total_bills': 0,
    'gross_sales': 0.0,
    'total_items': 0,
    'cash_collection': 0.0,
    'upi_collection': 0.0,
    'total_cogs': 0.0,
    'net_profit': 0.0,
    'leaderboard': <Map<String, dynamic>>[],
    'opening_float': 1500.0,
    'total_expenses': 0.0,
    'expected_cash_in_box': 1500.0,
  };
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late PosRepository repository;

  setUp(() async {
    // In-memory SQLite for tests
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, version) async {
          await AppDatabase.instance.initTestDatabase(db);
        },
      ),
    );
    repository = PosRepository();
  });

  tearDown(() async {
    await db.close();
  });

  group('Startup Concurrency & Database Mutex Tests', () {
    test('Parallel calls to AppDatabase.database complete safely without deadlock', () async {
      // Simulate 10 simultaneous calls on startup
      final futures = List.generate(10, (_) => AppDatabase.instance.database);
      final results = await Future.wait(futures);

      expect(results.length, 10);
      for (final d in results) {
        expect(d.isOpen, isTrue);
      }
    });

    test('All 9 required initial products are seeded in database', () async {
      final productDao = ProductDao(db);
      final products = await productDao.getAllProducts();

      // Verify the 9 active items exist
      final ids = products.map((p) => p.id).toSet();
      expect(ids.contains('classic_fries'), isTrue);
      expect(ids.contains('spring_roll'), isTrue);
      expect(ids.contains('cheese_fries'), isTrue);
      expect(ids.contains('peri_peri_fries'), isTrue);
      expect(ids.contains('blue_lagoon'), isTrue);
      expect(ids.contains('green_apple'), isTrue);
      expect(ids.contains('watermelon'), isTrue);
      expect(ids.contains('cranberry'), isTrue);
      expect(ids.contains('lemon_mojito'), isTrue);

      // Verify prices match requirement
      final classicFries = products.firstWhere((p) => p.id == 'classic_fries');
      expect(classicFries.sellingPrice, 70.0);

      final springRoll = products.firstWhere((p) => p.id == 'spring_roll');
      expect(springRoll.sellingPrice, 60.0);

      final cheeseFries = products.firstWhere((p) => p.id == 'cheese_fries');
      expect(cheeseFries.sellingPrice, 100.0);

      final periPeriFries = products.firstWhere((p) => p.id == 'peri_peri_fries');
      expect(periPeriFries.sellingPrice, 80.0);

      final blueLagoon = products.firstWhere((p) => p.id == 'blue_lagoon');
      expect(blueLagoon.sellingPrice, 50.0);

      final greenApple = products.firstWhere((p) => p.id == 'green_apple');
      expect(greenApple.sellingPrice, 50.0);

      final watermelon = products.firstWhere((p) => p.id == 'watermelon');
      expect(watermelon.sellingPrice, 50.0);

      final cranberry = products.firstWhere((p) => p.id == 'cranberry');
      expect(cranberry.sellingPrice, 50.0);

      final lemonMojito = products.firstWhere((p) => p.id == 'lemon_mojito');
      expect(lemonMojito.sellingPrice, 50.0);
    });

    test('Retired drinks (Coke Fizz, Nimbu Pani, etc.) remain inactive', () async {
      // Insert old active drinks
      final now = DateTime.now().toIso8601String();
      await db.insert('products', {
        'id': 'coke_fizz',
        'name': 'Coke Fizz',
        'category': 'drinks',
        'selling_price': 50.0,
        'cost_price': 15.0,
        'portion': '/ 350ml',
        'image_asset': 'assets/images/products/coke_fizz.png',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });

      // Run syncMenuProducts
      await AppDatabase.instance.syncMenuProducts(db);

      final productDao = ProductDao(db);
      final activeProducts = await productDao.getAllProducts();
      final activeIds = activeProducts.map((p) => p.id).toSet();
      expect(activeIds.contains('coke_fizz'), isFalse);

      final allAdmin = await productDao.getAllProductsAdmin();
      final retired = allAdmin.firstWhere((p) => p.id == 'coke_fizz');
      expect(retired.isActive, isFalse);
    });

    test('User price customizations and renames are preserved across syncs', () async {
      final productDao = ProductDao(db);
      final mojito = await productDao.getProductById('lemon_mojito');
      expect(mojito, isNotNull);

      // User changes price from 50 to 55 and customizes name
      final updatedMojito = mojito!.copyWith(
        name: 'Lemon Mojito Extra Mint',
        sellingPrice: 55.0,
      );
      await productDao.updateProduct(updatedMojito);

      // Re-run syncMenuProducts (simulating app restart)
      await AppDatabase.instance.syncMenuProducts(db);

      final retrieved = await productDao.getProductById('lemon_mojito');
      expect(retrieved!.name, 'Lemon Mojito Extra Mint');
      expect(retrieved.sellingPrice, 55.0);
    });

    test('Empty catalogue self-healing restores all 9 products', () async {
      // Deactivate or clear all products
      await db.delete('products');

      // Call restoreInitialMenu
      await AppDatabase.instance.restoreInitialMenu(db);

      final productDao = ProductDao(db);
      final activeProducts = await productDao.getAllProducts();
      expect(activeProducts.length >= 9, isTrue);
    });

    test('PosRepository restores default menu and loads products', () async {
      await repository.restoreDefaultMenu();
      final products = await repository.getProducts();
      expect(products.isNotEmpty, isTrue);
    });
  });

  group('Navigation & Dashboard Shell Widget Tests', () {
    testWidgets('DashboardShell renders bottom navigation with all 4 destinations', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            posRepositoryProvider.overrideWithValue(_FakePosRepository()),
          ],
          child: const MaterialApp(
            home: DashboardShellScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify all 4 bottom navigation items are present
      expect(find.text('Billing POS'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Initially selected index is 0 (BillingScreen is active)
      expect(find.byType(IndexedStack), findsOneWidget);
      final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 0);
    });

    testWidgets('Tapping bottom navigation tabs changes selected screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            posRepositoryProvider.overrideWithValue(_FakePosRepository()),
          ],
          child: const MaterialApp(
            home: DashboardShellScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tap on History tab
      await tester.tap(find.text('History'));
      await tester.pump();

      var stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 1);

      // Tap on Reports tab
      await tester.tap(find.text('Reports'));
      await tester.pump();

      stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 2);

      // Tap on Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pump();

      stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 3);

      // Tap back on Billing POS tab
      await tester.tap(find.text('Billing POS'));
      await tester.pump();

      stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 0);
    });
  });
}
