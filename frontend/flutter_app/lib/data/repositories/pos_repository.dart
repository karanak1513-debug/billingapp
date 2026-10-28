import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../local/database/app_database.dart';
import '../local/dao/product_dao.dart';
import '../local/dao/sale_dao.dart';
import '../local/dao/expense_dao.dart';
import '../local/dao/settings_dao.dart';
import '../models/sale_record.dart';
import '../models/expense_record.dart';
import '../../features/products/models/product.dart';
import '../../features/billing/models/cart_item.dart';
import '../../features/settings/models/payment_settings.dart';

class PosRepository {
  final AppDatabase _dbProvider;
  final Uuid _uuid = const Uuid();

  PosRepository({AppDatabase? dbProvider})
    : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<ProductDao> get _productDao async =>
      ProductDao(await _dbProvider.database);
  Future<SaleDao> get _saleDao async => SaleDao(await _dbProvider.database);
  Future<ExpenseDao> get _expenseDao async =>
      ExpenseDao(await _dbProvider.database);
  Future<SettingsDao> get _settingsDao async =>
      SettingsDao(await _dbProvider.database);

  // Products
  Future<List<Product>> getProducts() async {
    final dao = await _productDao;
    final products = await dao.getAllProducts();
    if (products.isEmpty) {
      // Self-healing: if no active products exist, restore initial menu safely
      final db = await _dbProvider.database;
      await _dbProvider.restoreInitialMenu(db);
      return await dao.getAllProducts();
    }
    return products;
  }

  Future<void> restoreDefaultMenu() async {
    final db = await _dbProvider.database;
    await _dbProvider.restoreInitialMenu(db);
  }

  Future<List<Product>> getProductsAdmin({
    bool? isActive,
    String? category,
    String? search,
  }) async {
    final dao = await _productDao;
    return await dao.getAllProductsAdmin(
      isActive: isActive,
      category: category,
      search: search,
    );
  }

  Future<Product?> getProductById(String id) async {
    final dao = await _productDao;
    return await dao.getProductById(id);
  }

  Future<void> saveProduct(Product product) async {
    final dao = await _productDao;
    final existing = await dao.getProductById(product.id);
    if (existing == null) {
      await dao.insertProduct(product);
    } else {
      await dao.updateProduct(product);
    }
  }

  Future<void> setProductActive(String id, bool isActive) async {
    final dao = await _productDao;
    await dao.setProductActive(id, isActive);
  }

  Future<bool> deleteProductSafely(String id) async {
    final dao = await _productDao;
    return await dao.deleteProductSafely(id);
  }

  Future<bool> isProductReferencedInSales(String id) async {
    final dao = await _productDao;
    return await dao.isProductReferencedInSales(id);
  }

  Future<List<String>> getCategories() async {
    final dao = await _productDao;
    return await dao.getDistinctCategories();
  }

  /// Copies chosen product image into persistent application documents storage
  Future<String> saveProductImageFile(File sourceFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imgDir = Directory(p.join(appDir.path, 'product_images'));
    if (!await imgDir.exists()) {
      await imgDir.create(recursive: true);
    }

    final ext = p.extension(sourceFile.path).toLowerCase();
    final safeExt = (ext == '.png' || ext == '.jpg' || ext == '.jpeg' || ext == '.webp')
        ? ext
        : '.png';
    final targetPath = p.join(
      imgDir.path,
      'prod_${_uuid.v4()}$safeExt',
    );

    await sourceFile.copy(targetPath);
    return targetPath;
  }

  Future<void> updateProductPrice({
    required String id,
    required double sellingPrice,
    required double costPrice,
  }) async {
    final dao = await _productDao;
    await dao.updateProductPrice(
      id: id,
      sellingPrice: sellingPrice,
      costPrice: costPrice,
    );
  }

  // Settings
  Future<int> getCurrentToken() async {
    final dao = await _settingsDao;
    return await dao.getCurrentTokenNumber();
  }

  Future<String> getCashierName() async {
    final dao = await _settingsDao;
    return await dao.getCashierName();
  }

  Future<void> setCashierName(String name) async {
    final dao = await _settingsDao;
    await dao.setCashierName(name);
  }

  Future<double> getOpeningFloat() async {
    final dao = await _settingsDao;
    return await dao.getOpeningFloat();
  }

  Future<void> setOpeningFloat(double amount) async {
    final dao = await _settingsDao;
    await dao.setOpeningFloat(amount);
  }

  // Payment Settings (UPI & Custom QR)
  Future<PaymentSettings> getPaymentSettings() async {
    final dao = await _settingsDao;
    return await dao.getPaymentSettings();
  }

  Future<void> savePaymentSettings(PaymentSettings settings) async {
    final dao = await _settingsDao;
    await dao.savePaymentSettings(settings);
  }

  /// Copies chosen QR image into persistent application documents storage
  Future<String> saveQrImageFile(File sourceFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final qrDir = Directory(p.join(appDir.path, 'qr_codes'));
    if (!await qrDir.exists()) {
      await qrDir.create(recursive: true);
    }

    final ext = p.extension(sourceFile.path).toLowerCase();
    final safeExt = (ext == '.png' || ext == '.jpg' || ext == '.jpeg')
        ? ext
        : '.png';
    final fileName =
        'stall_qr_${DateTime.now().millisecondsSinceEpoch}$safeExt';
    final destFile = File(p.join(qrDir.path, fileName));

    await sourceFile.copy(destFile.path);
    return destFile.path;
  }

  /// Safely removes custom stored QR file if it exists
  Future<void> removeCustomQrImage(String? currentPath) async {
    if (currentPath != null && currentPath.isNotEmpty) {
      if (!currentPath.startsWith('assets/')) {
        final file = File(currentPath);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }
      }
    }
  }

  // Complete Sale (Atomic Transaction)
  Future<SaleRecord> completeSale({
    required List<CartItem> cartItems,
    required String customerName,
    String? phoneNumber,
    required String paymentMethod, // 'cash' | 'phonepe_upi'
    required String paymentStatus, // 'verified' | 'pending' | 'unverified'
    double? amountReceived,
    double? changeReturned,
    double discount = 0.0,
    double tax = 0.0,
    String? notes,
  }) async {
    final settingsDao = await _settingsDao;
    final saleDao = await _saleDao;

    // 1. Generate sequential bill number & fetch token
    final billNumber = await settingsDao.generateNextBillNumber();
    final tokenNumber = await settingsDao.getCurrentTokenNumber();

    final saleId = _uuid.v4();

    double subtotal = 0.0;
    int totalCount = 0;
    final List<SaleItemRecord> itemRecords = [];

    for (final item in cartItems) {
      if (item.quantity > 0) {
        subtotal += item.lineTotal;
        totalCount += item.quantity;
        itemRecords.add(
          SaleItemRecord(
            id: _uuid.v4(),
            saleId: saleId,
            productId: item.product.id,
            productName: item.product.name,
            unitPrice: item.unitPrice,
            unitCost: item.unitCost,
            quantity: item.quantity,
            lineTotal: item.lineTotal,
          ),
        );
      }
    }

    final grandTotal = (subtotal - discount) + tax;

    final saleRecord = SaleRecord(
      id: saleId,
      billNumber: billNumber,
      tokenNumber: tokenNumber,
      customerName: customerName.trim().isEmpty
          ? 'Walk-in'
          : customerName.trim(),
      phoneNumber: phoneNumber?.trim(),
      timestamp: DateTime.now(),
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      grandTotal: grandTotal,
      totalItemsCount: totalCount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      amountReceived: amountReceived,
      changeReturned: changeReturned,
      notes: notes,
      items: itemRecords,
    );

    // Save atomically in SQLite
    await saleDao.insertSaleTransaction(saleRecord);

    return saleRecord;
  }

  // History & Queries
  Future<List<SaleRecord>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int? limit,
  }) async {
    final dao = await _saleDao;
    return await dao.getSales(
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
      limit: limit,
    );
  }

  Future<SaleRecord?> getSaleByBillNumber(String billNumber) async {
    final dao = await _saleDao;
    return await dao.getSaleByBillNumber(billNumber);
  }

  // Shift & Margin Reports
  Future<Map<String, dynamic>> getShiftReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final saleDao = await _saleDao;
    final expenseDao = await _expenseDao;
    final settingsDao = await _settingsDao;

    final metrics = await saleDao.getAggregateMetrics(
      startDate: startDate,
      endDate: endDate,
    );

    final totalExpenses = await expenseDao.getTotalExpenses(
      startDate: startDate,
      endDate: endDate,
    );

    final openingFloat = await settingsDao.getOpeningFloat();
    final cashSales = metrics['cash_collection'] as double;
    final expectedCashInBox = openingFloat + cashSales - totalExpenses;

    final netProfit =
        (metrics['gross_sales'] as double) -
        (metrics['total_cogs'] as double) -
        totalExpenses;

    return {
      ...metrics,
      'opening_float': openingFloat,
      'total_expenses': totalExpenses,
      'expected_cash_in_box': expectedCashInBox,
      'net_profit': netProfit,
    };
  }

  // Expenses
  Future<void> addExpense(ExpenseRecord expense) async {
    final dao = await _expenseDao;
    await dao.insertExpense(expense);
  }

  Future<List<ExpenseRecord>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dao = await _expenseDao;
    return await dao.getExpenses(startDate: startDate, endDate: endDate);
  }
}
