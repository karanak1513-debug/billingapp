import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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

  group('Dynamic Product Management Test Suite', () {
    late Database db;
    late ProductDao productDao;
    late SaleDao saleDao;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: (database, version) async {
            // Products table with description column
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

            // Sales and sale items tables
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

            await database.insert('app_settings', {
              'key': 'next_token_seq',
              'value': '1',
            });
          },
        ),
      );

      productDao = ProductDao(db);
      saleDao = SaleDao(db);

      // Seed initial menu
      await AppDatabase.instance.syncMenuProducts(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('1. Initial seed loads active drinks and retired drinks are inactive', () async {
      final products = await productDao.getAllProducts();
      final productNames = products.map((p) => p.name).toList();

      expect(productNames, contains('Blue Lagoon'));
      expect(productNames, contains('Green Apple'));
      expect(productNames, contains('Watermelon'));
      expect(productNames, contains('Cranberry'));
      expect(productNames, contains('Lemon Mojito'));
      expect(productNames, isNot(contains('Coke Fizz')));
      expect(productNames, isNot(contains('Sprite Masala')));
      expect(productNames, isNot(contains('Orange Fizz')));
      expect(productNames, isNot(contains('Thunder Cola')));
      expect(productNames, isNot(contains('Mango Chill')));
      expect(productNames, isNot(contains('Nimbu Pani')));
    });

    test('2. Add an unlimited new product dynamically and retrieve it', () async {
      final now = DateTime.now();
      final newProduct = Product(
        id: 'chocolate_waffle',
        name: 'Warm Belgian Chocolate Waffle',
        category: 'desserts',
        sellingPrice: 120.0,
        costPrice: 45.0,
        portion: '/ 1 waffle',
        imageAsset: '/data/user/0/com.stitch.snacks_oclock/files/product_images/prod_waffle.png',
        badge: 'New Treat',
        description: 'Crisp hot waffle smothered in melted milk chocolate.',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await productDao.insertProduct(newProduct);

      final active = await productDao.getAllProducts();
      final saved = active.firstWhere((p) => p.id == 'chocolate_waffle');

      expect(saved.name, equals('Warm Belgian Chocolate Waffle'));
      expect(saved.sellingPrice, equals(120.0));
      expect(saved.category, equals('desserts'));
      expect(saved.description, equals('Crisp hot waffle smothered in melted milk chocolate.'));
      expect(saved.isBundledAsset, isFalse);
    });

    test('3. Edit an existing product name and price, and verify updates', () async {
      final product = await productDao.getProductById('lemon_mojito');
      expect(product, isNotNull);
      expect(product!.name, equals('Lemon Mojito'));
      expect(product.sellingPrice, equals(50.0));

      // Rename and reprice
      final updated = product.copyWith(
        name: 'Artisanal Virgin Mojito',
        sellingPrice: 75.0,
        badge: 'Craft Brew',
      );
      await productDao.updateProduct(updated);

      final reloaded = await productDao.getProductById('lemon_mojito');
      expect(reloaded!.name, equals('Artisanal Virgin Mojito'));
      expect(reloaded.sellingPrice, equals(75.0));
      expect(reloaded.badge, equals('Craft Brew'));
    });

    test('4. App restart persistence: syncMenuProducts does NOT overwrite user renames or repricing', () async {
      // User modifies Blue Lagoon
      final product = await productDao.getProductById('blue_lagoon');
      final updated = product!.copyWith(
        name: 'Signature Blue Ocean',
        sellingPrice: 85.0,
      );
      await productDao.updateProduct(updated);

      // Simulate app restart by running syncMenuProducts(db)
      await AppDatabase.instance.syncMenuProducts(db);

      // Verify user changes are intact!
      final reloaded = await productDao.getProductById('blue_lagoon');
      expect(reloaded!.name, equals('Signature Blue Ocean'));
      expect(reloaded.sellingPrice, equals(85.0));
    });

    test('5. Deactivating a product removes it from active billing but keeps it in admin', () async {
      await productDao.setProductActive('watermelon', false);

      final activeProducts = await productDao.getAllProducts();
      final activeIds = activeProducts.map((p) => p.id).toList();
      expect(activeIds, isNot(contains('watermelon')));

      final adminProducts = await productDao.getAllProductsAdmin();
      final adminIds = adminProducts.map((p) => p.id).toList();
      expect(adminIds, contains('watermelon'));

      final tc = adminProducts.firstWhere((p) => p.id == 'watermelon');
      expect(tc.isActive, isFalse);
    });

    test('6. Safe deletion: unreferenced product is deleted permanently', () async {
      final now = DateTime.now();
      final tempProduct = Product(
        id: 'test_temp_drink',
        name: 'Temp Berry Soda',
        category: 'sips',
        sellingPrice: 40.0,
        costPrice: 15.0,
        portion: '/ glass',
        imageAsset: '',
        createdAt: now,
        updatedAt: now,
      );
      await productDao.insertProduct(tempProduct);

      final hasSales = await productDao.isProductReferencedInSales('test_temp_drink');
      expect(hasSales, isFalse);

      final wasDeleted = await productDao.deleteProductSafely('test_temp_drink');
      expect(wasDeleted, isTrue);

      final lookup = await productDao.getProductById('test_temp_drink');
      expect(lookup, isNull);
    });

    test('7. Safe deletion: product with historical sales is soft-deactivated, preserving sales history', () async {
      // 1. Create a sale referencing Cranberry
      final now = DateTime.now();
      final sale = SaleRecord(
        id: 'sale_001',
        billNumber: 'BILL-1001',
        tokenNumber: 1,
        customerName: 'Karan',
        timestamp: now,
        subtotal: 50.0,
        discount: 0.0,
        tax: 0.0,
        grandTotal: 50.0,
        totalItemsCount: 1,
        paymentMethod: 'phonepe_upi',
        paymentStatus: 'verified',
        items: [
          SaleItemRecord(
            id: 'item_001',
            saleId: 'sale_001',
            productId: 'cranberry',
            productName: 'Cranberry',
            unitPrice: 50.0,
            unitCost: 18.0,
            quantity: 1,
            lineTotal: 50.0,
          ),
        ],
      );
      await saleDao.insertSaleTransaction(sale);

      // Verify product is referenced in sales
      final hasSales = await productDao.isProductReferencedInSales('cranberry');
      expect(hasSales, isTrue);

      // Attempt safe deletion
      final wasDeleted = await productDao.deleteProductSafely('cranberry');
      // Returns false indicating soft deletion / deactivation
      expect(wasDeleted, isFalse);

      // Product still exists in DB so foreign keys / sales reports don't break
      final product = await productDao.getProductById('cranberry');
      expect(product, isNotNull);
      expect(product!.isActive, isFalse);

      // Historical sale record remains completely intact
      final retrievedSale = await saleDao.getSaleById('sale_001');
      expect(retrievedSale, isNotNull);
      expect(retrievedSale!.items.first.productName, equals('Cranberry'));
      expect(retrievedSale.items.first.unitPrice, equals(50.0));
    });

    test('8. Distinct categories dynamically reflects new categories', () async {
      final now = DateTime.now();
      await productDao.insertProduct(
        Product(
          id: 'garlic_bread',
          name: 'Cheesy Garlic Bread',
          category: 'appetizers',
          sellingPrice: 90.0,
          costPrice: 30.0,
          portion: '/ 4 pcs',
          imageAsset: '',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final categories = await productDao.getDistinctCategories();
      expect(categories, anyOf(contains('drinks'), contains('sips')));
      expect(categories, contains('appetizers'));
    });

    test('9. Updated product prices are automatically used in new billing calculations', () async {
      // Modify Green Apple price to ₹65
      final apple = await productDao.getProductById('green_apple');
      await productDao.updateProduct(apple!.copyWith(sellingPrice: 65.0));

      final reloadedApple = await productDao.getProductById('green_apple');
      expect(reloadedApple!.sellingPrice, equals(65.0));

      // Calculate cart with updated product
      final cart = [
        CartItem(product: reloadedApple, quantity: 2),
      ];

      const calculator = BillingCalculatorService();
      final result = calculator.calculateTotals(items: cart);

      // 2 * 65 = 130
      expect(result.subtotal, equals(130.0));
      expect(result.grandTotal, equals(130.0));
    });
  });
}
