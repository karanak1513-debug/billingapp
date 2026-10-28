import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_app/core/constants/app_constants.dart';
import 'package:flutter_app/features/products/models/product.dart';
import 'package:flutter_app/features/billing/models/cart_item.dart';
import 'package:flutter_app/features/billing/services/billing_calculator_service.dart';
import 'package:flutter_app/data/local/database/app_database.dart';
import 'package:flutter_app/data/local/dao/product_dao.dart';
import 'package:flutter_app/data/local/dao/sale_dao.dart';
import 'package:flutter_app/data/models/sale_record.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Snacks O Clock - 5 New Drinks Menu Comprehensive Validation', () {
    late Database db;
    late ProductDao productDao;
    late SaleDao saleDao;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 4,
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

            await database.execute('''
              CREATE TABLE sales (
                id TEXT PRIMARY KEY,
                bill_number TEXT NOT NULL UNIQUE,
                token_number INTEGER NOT NULL,
                customer_name TEXT,
                phone_number TEXT,
                timestamp TEXT NOT NULL,
                subtotal REAL NOT NULL,
                discount REAL NOT NULL DEFAULT 0.0,
                tax REAL NOT NULL DEFAULT 0.0,
                grand_total REAL NOT NULL,
                total_items_count INTEGER NOT NULL,
                payment_method TEXT NOT NULL,
                payment_status TEXT NOT NULL,
                amount_received REAL,
                change_returned REAL,
                notes TEXT,
                is_synced INTEGER NOT NULL DEFAULT 0
              )
            ''');

            await database.execute('''
              CREATE TABLE sale_items (
                id TEXT PRIMARY KEY,
                sale_id TEXT NOT NULL,
                product_id TEXT NOT NULL,
                product_name TEXT NOT NULL,
                unit_price REAL NOT NULL,
                unit_cost REAL NOT NULL,
                quantity INTEGER NOT NULL,
                line_total REAL NOT NULL,
                FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE
              )
            ''');

            await database.execute('''
              CREATE TABLE app_settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
              )
            ''');

            // Simulate legacy database containing old drinks and old sales
            final pastDate = DateTime.now().subtract(const Duration(days: 3)).toIso8601String();
            for (final oldDrink in [
              {'id': 'coke_fizz', 'name': 'Coke Fizz', 'price': 50.0},
              {'id': 'sprite_masala', 'name': 'Sprite Masala', 'price': 50.0},
              {'id': 'orange_fizz', 'name': 'Orange Fizz', 'price': 50.0},
              {'id': 'thunder_cola', 'name': 'Thunder Cola', 'price': 50.0},
              {'id': 'mango_chill', 'name': 'Mango Chill', 'price': 60.0},
              {'id': 'nimbu_pani', 'name': 'Nimbu Pani', 'price': 40.0},
            ]) {
              await database.insert('products', {
                'id': oldDrink['id'],
                'name': oldDrink['name'],
                'category': 'sips',
                'selling_price': oldDrink['price'],
                'cost_price': 15.0,
                'portion': '/ 350ml',
                'image_asset': 'assets/food/${oldDrink['id']}.png',
                'badge': 'Old Drink',
                'is_active': 1,
                'created_at': pastDate,
                'updated_at': pastDate,
              });
            }

            // Create a historical sale with Coke Fizz and Nimbu Pani
            await database.insert('sales', {
              'id': 'hist_sale_001',
              'bill_number': 'SOC-20261020-0001',
              'token_number': 101,
              'customer_name': 'Aman',
              'phone_number': '9876543210',
              'timestamp': pastDate,
              'subtotal': 90.0,
              'discount': 0.0,
              'tax': 0.0,
              'grand_total': 90.0,
              'total_items_count': 2,
              'payment_method': 'cash',
              'payment_status': 'verified',
              'amount_received': 100.0,
              'change_returned': 10.0,
            });

            await database.insert('sale_items', {
              'id': 'hist_item_001',
              'sale_id': 'hist_sale_001',
              'product_id': 'coke_fizz',
              'product_name': 'Coke Fizz',
              'unit_price': 50.0,
              'unit_cost': 18.0,
              'quantity': 1,
              'line_total': 50.0,
            });

            await database.insert('sale_items', {
              'id': 'hist_item_002',
              'sale_id': 'hist_sale_001',
              'product_id': 'nimbu_pani',
              'product_name': 'Nimbu Pani',
              'unit_price': 40.0,
              'unit_cost': 12.0,
              'quantity': 1,
              'line_total': 40.0,
            });
          },
        ),
      );

      productDao = ProductDao(db);
      saleDao = SaleDao(db);

      // Perform syncMenuProducts
      await AppDatabase.instance.syncMenuProducts(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('1. Verify EXACTLY 5 active drinks exist in the new drinks menu', () async {
      final allActive = await productDao.getAllProducts();
      final activeDrinks = allActive.where((p) => p.category == 'drinks').toList();

      expect(activeDrinks.length, 5, reason: 'Must have exactly 5 active drinks');

      final drinkNames = activeDrinks.map((d) => d.name).toSet();
      expect(drinkNames, equals({
        'Blue Lagoon',
        'Green Apple',
        'Watermelon',
        'Cranberry',
        'Lemon Mojito',
      }));
    });

    test('2. Verify ALL 5 new drinks are priced at exactly ₹50', () async {
      final allActive = await productDao.getAllProducts();
      final activeDrinks = allActive.where((p) => p.category == 'drinks').toList();

      for (final drink in activeDrinks) {
        expect(drink.sellingPrice, 50.0, reason: '${drink.name} must be ₹50');
      }
    });

    test('3. Verify all 5 new drinks have distinct, individual offline image assets', () async {
      final allActive = await productDao.getAllProducts();
      final activeDrinks = allActive.where((p) => p.category == 'drinks').toList();

      final blueLagoon = activeDrinks.firstWhere((p) => p.name == 'Blue Lagoon');
      expect(blueLagoon.imageAsset, AppConstants.imgBlueLagoon);
      expect(blueLagoon.imageAsset, 'assets/images/products/blue_lagoon.png');

      final greenApple = activeDrinks.firstWhere((p) => p.name == 'Green Apple');
      expect(greenApple.imageAsset, AppConstants.imgGreenApple);
      expect(greenApple.imageAsset, 'assets/images/products/green_apple.png');

      final watermelon = activeDrinks.firstWhere((p) => p.name == 'Watermelon');
      expect(watermelon.imageAsset, AppConstants.imgWatermelon);
      expect(watermelon.imageAsset, 'assets/images/products/watermelon.png');

      final cranberry = activeDrinks.firstWhere((p) => p.name == 'Cranberry');
      expect(cranberry.imageAsset, AppConstants.imgCranberry);
      expect(cranberry.imageAsset, 'assets/images/products/cranberry.png');

      final lemonMojito = activeDrinks.firstWhere((p) => p.name == 'Lemon Mojito');
      expect(lemonMojito.imageAsset, AppConstants.imgLemonMojito);
      expect(lemonMojito.imageAsset, 'assets/images/products/lemon_mojito.png');

      // Verify all assets are unique
      final assetPaths = activeDrinks.map((d) => d.imageAsset).toSet();
      expect(assetPaths.length, 5, reason: 'Every drink must have its own distinct image');
    });

    test('4. Verify all old drinks are removed/deactivated from active menu', () async {
      final activeProducts = await productDao.getAllProducts();
      final activeIds = activeProducts.map((p) => p.id).toSet();

      expect(activeIds.contains('coke_fizz'), isFalse);
      expect(activeIds.contains('sprite_masala'), isFalse);
      expect(activeIds.contains('orange_fizz'), isFalse);
      expect(activeIds.contains('thunder_cola'), isFalse);
      expect(activeIds.contains('mango_chill'), isFalse);
      expect(activeIds.contains('nimbu_pani'), isFalse);
    });

    test('5. Verify food products remain intact and unchanged', () async {
      final activeProducts = await productDao.getAllProducts();
      final activeFoods = activeProducts.where((p) => p.category == 'snacks').toList();

      expect(activeFoods.length, 4);

      final classicFries = activeFoods.firstWhere((p) => p.id == 'classic_fries');
      expect(classicFries.name, 'Classic Fries');
      expect(classicFries.sellingPrice, 70.0);

      final springRoll = activeFoods.firstWhere((p) => p.id == 'spring_roll');
      expect(springRoll.name, 'Spring Roll');
      expect(springRoll.sellingPrice, 60.0);

      final cheeseFries = activeFoods.firstWhere((p) => p.id == 'cheese_fries');
      expect(cheeseFries.name, 'Cheese Fries');
      expect(cheeseFries.sellingPrice, 100.0);

      final periPeriFries = activeFoods.firstWhere((p) => p.id == 'peri_peri_fries');
      expect(periPeriFries.name, 'Peri Peri Fries');
      expect(periPeriFries.sellingPrice, 80.0);
    });

    test('6. Verify historical data and receipts with old drinks remain 100% preserved', () async {
      // Historical sale was created before sync with Coke Fizz and Nimbu Pani
      final historicalSale = await saleDao.getSaleById('hist_sale_001');
      expect(historicalSale, isNotNull);
      expect(historicalSale!.billNumber, 'SOC-20261020-0001');
      expect(historicalSale.grandTotal, 90.0);
      expect(historicalSale.items.length, 2);

      final item1 = historicalSale.items.firstWhere((i) => i.productId == 'coke_fizz');
      expect(item1.productName, 'Coke Fizz');
      expect(item1.unitPrice, 50.0);

      final item2 = historicalSale.items.firstWhere((i) => i.productId == 'nimbu_pani');
      expect(item2.productName, 'Nimbu Pani');
      expect(item2.unitPrice, 40.0);

      // Verify old products still exist in products table (marked inactive)
      final oldCoke = await productDao.getProductById('coke_fizz');
      expect(oldCoke, isNotNull);
      expect(oldCoke!.isActive, false);

      final oldNimbu = await productDao.getProductById('nimbu_pani');
      expect(oldNimbu, isNotNull);
      expect(oldNimbu!.isActive, false);
    });

    test('7. Verify product price management allows changing drink prices dynamically', () async {
      // Change Blue Lagoon price from 50 to 55 and Lemon Mojito to 60
      final blueLagoon = await productDao.getProductById('blue_lagoon');
      await productDao.updateProduct(blueLagoon!.copyWith(sellingPrice: 55.0));

      final lemonMojito = await productDao.getProductById('lemon_mojito');
      await productDao.updateProduct(lemonMojito!.copyWith(sellingPrice: 60.0));

      final updatedBL = await productDao.getProductById('blue_lagoon');
      expect(updatedBL!.sellingPrice, 55.0);

      final updatedLM = await productDao.getProductById('lemon_mojito');
      expect(updatedLM!.sellingPrice, 60.0);

      // Verify app restart syncMenuProducts does NOT overwrite user price changes
      await AppDatabase.instance.syncMenuProducts(db);

      final reloadedBL = await productDao.getProductById('blue_lagoon');
      expect(reloadedBL!.sellingPrice, 55.0);

      final reloadedLM = await productDao.getProductById('lemon_mojito');
      expect(reloadedLM!.sellingPrice, 60.0);
    });

    test('8. Test search and category filtering for new drinks', () async {
      // Search for 'water'
      final searchWater = await productDao.getAllProductsAdmin(search: 'water');
      expect(searchWater.length, 1);
      expect(searchWater.first.name, 'Watermelon');

      // Search for 'mojito'
      final searchMojito = await productDao.getAllProductsAdmin(search: 'mojito');
      expect(searchMojito.length, 1);
      expect(searchMojito.first.name, 'Lemon Mojito');

      // Category filter for 'drinks'
      final drinksCategory = await productDao.getAllProductsAdmin(category: 'drinks', isActive: true);
      expect(drinksCategory.length, 5);
    });

    test('9. Test cart calculations with 5 new drinks', () {
      const calculator = BillingCalculatorService();

      final drinks = [
        Product(id: 'blue_lagoon', name: 'Blue Lagoon', category: 'drinks', sellingPrice: 50.0, costPrice: 18.0, portion: '/ 350ml', imageAsset: AppConstants.imgBlueLagoon),
        Product(id: 'green_apple', name: 'Green Apple', category: 'drinks', sellingPrice: 50.0, costPrice: 18.0, portion: '/ 350ml', imageAsset: AppConstants.imgGreenApple),
        Product(id: 'watermelon', name: 'Watermelon', category: 'drinks', sellingPrice: 50.0, costPrice: 18.0, portion: '/ 350ml', imageAsset: AppConstants.imgWatermelon),
        Product(id: 'cranberry', name: 'Cranberry', category: 'drinks', sellingPrice: 50.0, costPrice: 18.0, portion: '/ 350ml', imageAsset: AppConstants.imgCranberry),
        Product(id: 'lemon_mojito', name: 'Lemon Mojito', category: 'drinks', sellingPrice: 50.0, costPrice: 18.0, portion: '/ 350ml', imageAsset: AppConstants.imgLemonMojito),
      ];

      // Add 1 of each drink to cart (5 drinks * ₹50 = ₹250)
      final cartItems = drinks.map((d) => CartItem(product: d, quantity: 1)).toList();

      final totals = calculator.calculateTotals(items: cartItems);
      expect(totals.subtotal, 250.0);
      expect(totals.grandTotal, 250.0);
      expect(totals.totalItemsCount, 5);
      expect(totals.totalCost, 90.0); // 5 * 18
      expect(totals.estimatedProfit, 160.0); // 250 - 90
    });
  });
}
