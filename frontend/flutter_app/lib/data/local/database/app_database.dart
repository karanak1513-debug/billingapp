import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/constants/app_constants.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;
  static Completer<Database>? _initCompleter;

  AppDatabase._internal();

  /// Thread-safe database getter.
  /// Prevents concurrency deadlocks when multiple Riverpod providers/widgets
  /// request the database concurrently during app startup.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    final completer = Completer<Database>();
    _initCompleter = completer;

    try {
      final db = await _initDatabase();
      _database = db;
      completer.complete(db);
      return db;
    } catch (e, stack) {
      debugPrint('CRITICAL: AppDatabase initialization failed: $e\n$stack');
      _initCompleter = null;
      completer.completeError(e, stack);
      rethrow;
    } finally {
      _initCompleter = null;
    }
  }

  /// Resolves the canonical SQLite database path with legacy migration support.
  Future<String> _resolveDatabasePath(String dbName) async {
    if (kIsWeb) return dbName;

    String targetDir;
    try {
      targetDir = await getDatabasesPath();
    } catch (_) {
      final docsDir = await getApplicationDocumentsDirectory();
      targetDir = docsDir.path;
    }

    final targetPath = p.join(targetDir, dbName);

    // Backward-compatibility: if db doesn't exist at canonical path,
    // check if it exists in legacy applicationDocumentsDirectory and copy it.
    try {
      final targetFile = File(targetPath);
      if (!await targetFile.exists()) {
        final docsDir = await getApplicationDocumentsDirectory();
        final legacyPath = p.join(docsDir.path, dbName);
        final legacyFile = File(legacyPath);
        if (await legacyFile.exists()) {
          await targetFile.parent.create(recursive: true);
          await legacyFile.copy(targetPath);
          debugPrint('Copied legacy database from $legacyPath to $targetPath');
        }
      }
    } catch (e) {
      debugPrint('Legacy database migration check error: $e');
    }

    return targetPath;
  }

  Future<Database> _initDatabase({String dbName = 'snacks_oclock.db'}) async {
    // If running on desktop platforms (Windows/Linux/macOS) or in tests without native sqflite
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await _resolveDatabasePath(dbName);

    final db = await openDatabase(
      dbPath,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Always perform idempotent schema & catalogue self-healing check on open
    await _ensureSchemaAndSeed(db);

    return db;
  }

  /// Initial database table creations
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedInitialData(db);
  }

  /// Helper for tests to initialize an in-memory database with schema & default products.
  Future<void> initTestDatabase(Database db) async {
    await _onCreate(db, 4);
  }

  /// Handles schema and data upgrades across versions safely
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _createTables(db);
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE products ADD COLUMN description TEXT;');
      } catch (e) {
        debugPrint('Column description may already exist: $e');
      }
    }
    if (oldVersion < 4) {
      final now = DateTime.now().toIso8601String();
      // Soft-deactivate old retired drinks so they are preserved in historical records but hidden from active menu
      await db.update(
        'products',
        {'is_active': 0, 'updated_at': now},
        where:
            "id IN ('coke_fizz', 'sprite_masala', 'orange_fizz', 'thunder_cola', 'mango_chill', 'nimbu_pani')",
      );
      // Migrate sips category to drinks
      await db.update(
        'products',
        {'category': 'drinks'},
        where: "category = 'sips'",
      );
    }
    await syncMenuProducts(db);
  }

  Future<void> _createTables(Database db) async {
    // Products table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
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

    // Sales table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
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

    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sales_timestamp ON sales(timestamp)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sales_bill_number ON sales(bill_number)',
      );
    } catch (_) {}

    // Sale items table (immutable snapshot of item and cost at sale time)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_items (
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

    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items(sale_id)',
      );
    } catch (_) {}

    // Expenses table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_expenses_timestamp ON expenses(timestamp)',
      );
    } catch (_) {}

    // App settings table
        // Combos table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS combos (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        selling_price REAL NOT NULL,
        cost_price REAL NOT NULL DEFAULT 0.0,
        image_asset TEXT NOT NULL,
        badge TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Combo items table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS combo_items (
        id TEXT PRIMARY KEY,
        combo_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (combo_id) REFERENCES combos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// Idempotently ensures all tables, columns, required products, and settings exist.
  Future<void> _ensureSchemaAndSeed(Database db) async {
    await _createTables(db);

    // Ensure description column exists in products table
    try {
      await db.execute('ALTER TABLE products ADD COLUMN description TEXT;');
    } catch (_) {}

    // Ensure initial settings exist
    await _seedDefaultSettings(db);
    await _seedDefaultCombos(db);

    // Sync menu products (seeds missing items, retires old drinks, preserves user customizations)
    await syncMenuProducts(db);
  }

  /// List of the 9 required default products for Snacks O'Clock:
  /// - 4 Snacks: Classic Fries, Spring Roll, Cheese Fries, Peri Peri Fries
  /// - 5 Drinks: Blue Lagoon, Green Apple, Watermelon, Cranberry, Lemon Mojito
  List<Map<String, dynamic>> _getDefaultProducts(String now) {
    return [
      {
        'id': 'classic_fries',
        'name': 'Classic Fries',
        'category': 'snacks',
        'selling_price': 70.0,
        'cost_price': 25.0,
        'portion': '/ portion',
        'image_asset': AppConstants.imgClassicFries,
        'badge': 'Crispy',
        'description': 'Golden crispy salted potato fries made fresh to order.',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'spring_roll',
        'name': 'Spring Roll',
        'category': 'snacks',
        'selling_price': 60.0,
        'cost_price': 20.0,
        'portion': '/ 2 pcs',
        'image_asset': AppConstants.imgSpringRoll,
        'badge': 'Crispy Veg',
        'description': 'Crunchy golden rolls packed with spiced vegetables.',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'cheese_fries',
        'name': 'Cheese Fries',
        'category': 'snacks',
        'selling_price': 100.0,
        'cost_price': 38.0,
        'portion': '/ loaded',
        'image_asset': AppConstants.imgCheeseFries,
        'badge': 'Bestseller',
        'description': 'Crispy fries smothered in warm molten cheese sauce.',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'peri_peri_fries',
        'name': 'Peri Peri Fries',
        'category': 'snacks',
        'selling_price': 80.0,
        'cost_price': 28.0,
        'portion': '/ shaken',
        'image_asset': AppConstants.imgPeriPeriFries,
        'badge': 'Spicy',
        'description':
            'Hot and zesty fries tossed in fiery African bird eye peri peri seasoning.',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'blue_lagoon',
        'name': 'Blue Lagoon',
        'category': 'drinks',
        'selling_price': 50.0,
        'cost_price': 18.0,
        'portion': '/ 350ml',
        'image_asset': AppConstants.imgBlueLagoon,
        'badge': 'Limited',
        'description':
            'Bright electric blue fizzy drink with ice, lemon and a straw.',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'green_apple',
        'name': 'Green Apple',
        'category': 'drinks',
        'selling_price': 50.0,
        'cost_price': 18.0,
        'portion': '/ 350ml',
        'image_asset': AppConstants.imgGreenApple,
        'badge': 'Limited',
        'description':
            'Vibrant green apple drink with ice and green apple garnish.',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'watermelon',
        'name': 'Watermelon',
        'category': 'drinks',
        'selling_price': 50.0,
        'cost_price': 18.0,
        'portion': '/ 350ml',
        'image_asset': AppConstants.imgWatermelon,
        'badge': 'Limited',
        'description':
            'Refreshing red watermelon drink with ice and watermelon garnish.',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'cranberry',
        'name': 'Cranberry',
        'category': 'drinks',
        'selling_price': 50.0,
        'cost_price': 18.0,
        'portion': '/ 350ml',
        'image_asset': AppConstants.imgCranberry,
        'badge': 'Limited',
        'description':
            'Deep red cranberry drink with ice and cranberry garnish.',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'lemon_mojito',
        'name': 'Lemon Mojito',
        'category': 'drinks',
        'selling_price': 50.0,
        'cost_price': 18.0,
        'portion': '/ 350ml',
        'image_asset': AppConstants.imgLemonMojito,
        'badge': 'Classic',
        'description':
            'Clear lemon-lime drink with mint, lemon slices and ice.',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
    ];
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();
    final defaultProducts = _getDefaultProducts(now);

    for (final product in defaultProducts) {
      await db.insert('products', product, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await _seedDefaultSettings(db);
    await _seedDefaultCombos(db);
  }

  
  Future<void> _seedDefaultCombos(Database db) async {
    final now = DateTime.now().toIso8601String();
    final defaultCombos = [
      {
        'id': 'classic_combo',
        'name': 'Classic Combo',
        'description': 'Classic Salted Fries + Drink',
        'selling_price': 110.0,
        'cost_price': 43.0,
        'image_asset': AppConstants.imgClassicCombo,
        'badge': 'Save ₹10',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'peri_peri_combo',
        'name': 'Peri Peri Combo',
        'description': 'Peri Peri Fries + Drink',
        'selling_price': 120.0,
        'cost_price': 46.0,
        'image_asset': AppConstants.imgPeriPeriCombo,
        'badge': 'Spicy Combo',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'cheese_bomb_combo',
        'name': 'Cheese Bomb Combo',
        'description': 'Loaded Cheese Fries + Drink',
        'selling_price': 140.0,
        'cost_price': 56.0,
        'image_asset': AppConstants.imgCheeseBombCombo,
        'badge': 'Bestseller',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'roll_and_sip',
        'name': 'Roll & Sip',
        'description': 'Veg Spring Rolls + Drink',
        'selling_price': 100.0,
        'cost_price': 38.0,
        'image_asset': AppConstants.imgRollAndSip,
        'badge': 'Value Combo',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final combo in defaultCombos) {
      await db.insert('combos', combo, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _seedDefaultSettings(Database db) async {
    final defaultSettings = {
      'next_bill_seq': '1001',
      'next_token_seq': '1',
      'opening_cash_float': '1500.0',
      'cashier_name': AppConstants.defaultCashier,
      'stall_name': AppConstants.appName,
      'upi_vpa': AppConstants.merchantUpiVpa,
      'upi_id': AppConstants.merchantUpiVpa,
      'merchant_name': AppConstants.appName,
      'qr_image_path': AppConstants.imgPhonePeQr,
      'payment_instructions':
          'Scan with PhonePe, GPay, Paytm or any UPI app & show confirmation.',
    };

    for (final entry in defaultSettings.entries) {
      await db.rawInsert(
        'INSERT OR IGNORE INTO app_settings (key, value) VALUES (?, ?)',
        [entry.key, entry.value],
      );
    }
  }

  /// Safely ensures the active menu matches current Snacks O'Clock offerings:
  /// - Soft-deactivates retired items ('coke_fizz', 'sprite_masala', 'orange_fizz', 'thunder_cola', 'mango_chill', 'nimbu_pani') so they never appear in active menus
  /// - Seeds any missing products among the 9 core offerings IF not already present
  /// - Ensures the 5 new drinks ('blue_lagoon', 'green_apple', 'watermelon', 'cranberry', 'lemon_mojito') are active and configured with their individual images
  /// - Preserves user renames, custom prices, category edits, and custom photos across app restarts
  Future<void> syncMenuProducts(Database db) async {
    await _createTables(db);
    final now = DateTime.now().toIso8601String();

    // 1. Soft-deactivate retired drinks so they are preserved in historical records but hidden from active menu
    await db.update(
      'products',
      {'is_active': 0, 'updated_at': now},
      where:
          "id IN ('coke_fizz', 'sprite_masala', 'orange_fizz', 'thunder_cola', 'mango_chill', 'nimbu_pani') AND is_active = 1",
    );

    // 2. Also ensure any old 'sips' category is migrated to 'drinks'
    await db.update(
      'products',
      {'category': 'drinks'},
      where: "category = 'sips'",
    );

    // 3. Ensure all 9 core products (4 snacks + 5 drinks) exist in the database.
    final defaultProducts = _getDefaultProducts(now);

    for (final item in defaultProducts) {
      final existing = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [item['id']],
      );
      if (existing.isEmpty) {
        await db.insert('products', item);
      } else {
        // If product is one of the 5 active drinks, ensure is_active = 1 and category = 'drinks'
        // and update image_asset to the new bundled asset
        const activeDrinkIds = {
          'blue_lagoon',
          'green_apple',
          'watermelon',
          'cranberry',
          'lemon_mojito',
        };
        if (activeDrinkIds.contains(item['id'])) {
          final current = existing.first;
          final updateFields = <String, dynamic>{
            'is_active': 1,
            'category': 'drinks',
            'updated_at': now,
          };
          final currentAsset = current['image_asset'] as String? ?? '';
          if (currentAsset.isEmpty || currentAsset == 'assets/food/blue_lagoon.png') {
            updateFields['image_asset'] = item['image_asset'];
          }
          await db.update(
            'products',
            updateFields,
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      }
    }
  }

  /// Restores initial menu if catalogue is empty or if user triggers manual recovery.
  /// Re-inserts any missing products and ensures active status for the 9 core items,
  /// while keeping retired items inactive and preserving existing sales.
  Future<void> restoreInitialMenu(Database db) async {
    await _createTables(db);
    final now = DateTime.now().toIso8601String();
    final defaultProducts = _getDefaultProducts(now);

    for (final item in defaultProducts) {
      final existing = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [item['id']],
      );
      if (existing.isEmpty) {
        await db.insert('products', item);
      } else {
        // Reactivate if it was deactivated, but preserve custom price/name
        final current = existing.first;
        final updateMap = <String, dynamic>{
          'is_active': 1,
          'category': item['category'],
          'updated_at': now,
        };
        if ((current['is_active'] as int?) != 1) {
          updateMap['selling_price'] = item['selling_price'];
          updateMap['image_asset'] = item['image_asset'];
        }
        await db.update(
          'products',
          updateMap,
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }

    // Keep retired items inactive
    await db.update(
      'products',
      {'is_active': 0, 'updated_at': now},
      where:
          "id IN ('coke_fizz', 'sprite_masala', 'orange_fizz', 'thunder_cola', 'mango_chill', 'nimbu_pani')",
    );
  }

  /// Closes database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
    _initCompleter = null;
  }
}
