import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_app/core/constants/app_constants.dart';
import 'package:flutter_app/features/products/models/product.dart';
import 'package:flutter_app/features/billing/models/cart_item.dart';
import 'package:flutter_app/features/billing/services/billing_calculator_service.dart';
import 'package:flutter_app/data/local/database/app_database.dart';
import 'package:flutter_app/data/local/dao/product_dao.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('New Drinks Menu & Safe Product Data Tests', () {
    late Database db;
    late ProductDao productDao;

    setUp(() async {
      // Create an in-memory database using the AppDatabase schema
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: (database, version) async {
            await database.execute('''
              CREATE TABLE products (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                category TEXT NOT NULL,
                selling_price REAL NOT NULL,
                cost_price REAL NOT NULL,
                portion TEXT NOT NULL,
                image_asset TEXT NOT NULL,
                badge TEXT,
                description TEXT,
                is_active INTEGER NOT NULL DEFAULT 1,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              )
            ''');

            // Simulate legacy database with old products (Coke Fizz, Mango Chill, Nimbu Pani, etc.)
            final now = DateTime.now().toIso8601String();
            await database.insert('products', {
              'id': 'classic_fries',
              'name': 'Classic Fries',
              'category': 'snacks',
              'selling_price': 70.0,
              'cost_price': 25.0,
              'portion': '/ portion',
              'image_asset': AppConstants.imgClassicFries,
              'badge': 'Crispy',
              'is_active': 1,
              'created_at': now,
              'updated_at': now,
            });
            await database.insert('products', {
              'id': 'coke_fizz',
              'name': 'Coke Fizz',
              'category': 'sips',
              'selling_price': 50.0,
              'cost_price': 18.0,
              'portion': '/ 350ml',
              'image_asset': 'assets/images/products/coke_fizz.png',
              'badge': 'Chilled Cola',
              'is_active': 1,
              'created_at': now,
              'updated_at': now,
            });
            await database.insert('products', {
              'id': 'mango_chill',
              'name': 'Mango Chill',
              'category': 'sips',
              'selling_price': 60.0,
              'cost_price': 22.0,
              'portion': '/ 350ml',
              'image_asset': 'assets/images/products/mango_chill.png',
              'badge': 'Real Pulp',
              'is_active': 1,
              'created_at': now,
              'updated_at': now,
            });
            await database.insert('products', {
              'id': 'nimbu_pani',
              'name': 'Nimbu Pani',
              'category': 'sips',
              'selling_price': 40.0,
              'cost_price': 12.0,
              'portion': '/ classic',
              'image_asset': AppConstants.imgNimbuPani,
              'badge': 'Fresh Lime',
              'is_active': 1,
              'created_at': now,
              'updated_at': now,
            });
          },
        ),
      );

      productDao = ProductDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('syncMenuProducts deactivates old drinks and activates the 5 new drinks safely', () async {
      // Before sync: Coke Fizz, Mango Chill, and Nimbu Pani are active
      var activeProducts = await productDao.getAllProducts();
      expect(activeProducts.any((p) => p.id == 'coke_fizz'), true);
      expect(activeProducts.any((p) => p.id == 'mango_chill'), true);
      expect(activeProducts.any((p) => p.id == 'nimbu_pani'), true);

      // Perform syncMenuProducts
      await AppDatabase.instance.syncMenuProducts(db);

      // After sync: Old drinks MUST be absent from active menu
      activeProducts = await productDao.getAllProducts();
      final activeIds = activeProducts.map((p) => p.id).toSet();

      expect(activeIds.contains('coke_fizz'), false, reason: 'Coke Fizz must not appear in active menu');
      expect(activeIds.contains('sprite_masala'), false, reason: 'Sprite Masala must not appear in active menu');
      expect(activeIds.contains('orange_fizz'), false, reason: 'Orange Fizz must not appear in active menu');
      expect(activeIds.contains('thunder_cola'), false, reason: 'Thunder Cola must not appear in active menu');
      expect(activeIds.contains('mango_chill'), false, reason: 'Mango Chill must not appear in active menu');
      expect(activeIds.contains('nimbu_pani'), false, reason: 'Nimbu Pani must not appear in active menu');

      // The 5 new drinks must be present with exact names and ₹50 prices
      final blueLagoon = activeProducts.firstWhere((p) => p.id == 'blue_lagoon');
      expect(blueLagoon.name, 'Blue Lagoon');
      expect(blueLagoon.sellingPrice, 50.0);
      expect(blueLagoon.category, 'drinks');
      expect(blueLagoon.imageAsset, AppConstants.imgBlueLagoon);

      final greenApple = activeProducts.firstWhere((p) => p.id == 'green_apple');
      expect(greenApple.name, 'Green Apple');
      expect(greenApple.sellingPrice, 50.0);
      expect(greenApple.category, 'drinks');
      expect(greenApple.imageAsset, AppConstants.imgGreenApple);

      final watermelon = activeProducts.firstWhere((p) => p.id == 'watermelon');
      expect(watermelon.name, 'Watermelon');
      expect(watermelon.sellingPrice, 50.0);
      expect(watermelon.category, 'drinks');
      expect(watermelon.imageAsset, AppConstants.imgWatermelon);

      final cranberry = activeProducts.firstWhere((p) => p.id == 'cranberry');
      expect(cranberry.name, 'Cranberry');
      expect(cranberry.sellingPrice, 50.0);
      expect(cranberry.category, 'drinks');
      expect(cranberry.imageAsset, AppConstants.imgCranberry);

      final lemonMojito = activeProducts.firstWhere((p) => p.id == 'lemon_mojito');
      expect(lemonMojito.name, 'Lemon Mojito');
      expect(lemonMojito.sellingPrice, 50.0);
      expect(lemonMojito.category, 'drinks');
      expect(lemonMojito.imageAsset, AppConstants.imgLemonMojito);

      // Verify old products still exist in database for historical sales reference
      final oldCoke = await productDao.getProductById('coke_fizz');
      expect(oldCoke, isNotNull);
      expect(oldCoke!.isActive, false);

      final oldMango = await productDao.getProductById('mango_chill');
      expect(oldMango, isNotNull);
      expect(oldMango!.isActive, false);

      final oldNimbuPani = await productDao.getProductById('nimbu_pani');
      expect(oldNimbuPani, isNotNull);
      expect(oldNimbuPani!.isActive, false);
    });

    test('Multiple syncMenuProducts calls are idempotent (no duplicates created)', () async {
      await AppDatabase.instance.syncMenuProducts(db);
      await AppDatabase.instance.syncMenuProducts(db);
      await AppDatabase.instance.syncMenuProducts(db);

      final activeProducts = await productDao.getAllProducts();
      final blueLagoonCount = activeProducts.where((p) => p.id == 'blue_lagoon').length;
      expect(blueLagoonCount, 1, reason: 'Duplicate products must not be created upon repeated sync');

      final greenAppleCount = activeProducts.where((p) => p.id == 'green_apple').length;
      expect(greenAppleCount, 1);

      final watermelonCount = activeProducts.where((p) => p.id == 'watermelon').length;
      expect(watermelonCount, 1);

      final cranberryCount = activeProducts.where((p) => p.id == 'cranberry').length;
      expect(cranberryCount, 1);

      final lemonMojitoCount = activeProducts.where((p) => p.id == 'lemon_mojito').length;
      expect(lemonMojitoCount, 1);
    });

    test('Billing calculator calculates totals accurately with new drinks menu', () {
      const service = BillingCalculatorService();

      final blueLagoon = Product(
        id: 'blue_lagoon',
        name: 'Blue Lagoon',
        category: 'drinks',
        sellingPrice: 50.0,
        costPrice: 18.0,
        portion: '/ 350ml',
        imageAsset: AppConstants.imgBlueLagoon,
      );

      final watermelon = Product(
        id: 'watermelon',
        name: 'Watermelon',
        category: 'drinks',
        sellingPrice: 50.0,
        costPrice: 18.0,
        portion: '/ 350ml',
        imageAsset: AppConstants.imgWatermelon,
      );

      final items = [
        CartItem(product: blueLagoon, quantity: 2), // 2 * 50 = ₹100
        CartItem(product: watermelon, quantity: 1), // 1 * 50 = ₹50
      ];

      final totals = service.calculateTotals(items: items);
      expect(totals.subtotal, 150.0);
      expect(totals.grandTotal, 150.0);
      expect(totals.totalItemsCount, 3);
      // Cost: 2*18 + 18 = 54
      expect(totals.totalCost, 54.0);
      // Profit: 150 - 54 = 96
      expect(totals.estimatedProfit, 96.0);
    });
  });
}
