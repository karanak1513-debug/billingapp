import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_app/data/local/dao/sale_dao.dart';
import 'package:flutter_app/data/models/sale_record.dart';
import 'package:flutter_app/features/reports/providers/reports_provider.dart';
import 'package:flutter_app/features/reports/screens/reports_screen.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Reports Provider & Calculation Unit Tests', () {
    late Database db;
    late SaleDao saleDao;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: (database, version) async {
            await database.execute('''
              CREATE TABLE app_settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
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
                FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE
              )
            ''');

            await database.insert('app_settings', {
              'key': 'next_token_seq',
              'value': '1',
            });
          },
        ),
      );
      saleDao = SaleDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('ReportPeriod enum supports today, thisWeek, thisMonth, custom', () {
      expect(ReportPeriod.values.length, 4);
      expect(ReportPeriod.values, contains(ReportPeriod.today));
      expect(ReportPeriod.values, contains(ReportPeriod.thisWeek));
      expect(ReportPeriod.values, contains(ReportPeriod.thisMonth));
      expect(ReportPeriod.values, contains(ReportPeriod.custom));
    });

    test('CustomDateRangeNotifier sets and resets range correctly', () {
      final container = ProviderContainer();
      expect(container.read(customDateRangeProvider), isNull);

      final range = DateTimeRange(
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 20),
      );
      container.read(customDateRangeProvider.notifier).setRange(range);
      expect(container.read(customDateRangeProvider), equals(range));

      container.read(customDateRangeProvider.notifier).setRange(null);
      expect(container.read(customDateRangeProvider), isNull);
    });

    test('SaleDao getAggregateMetrics calculates cash and upi sales accurately', () async {
      final now = DateTime.now();

      // Insert Cash Sale (₹150, cost ₹40)
      final cashSale = SaleRecord(
        id: 'sale_cash_1',
        billNumber: 'SOC-101',
        tokenNumber: 1,
        customerName: 'Karan',
        timestamp: now,
        subtotal: 150.0,
        grandTotal: 150.0,
        totalItemsCount: 2,
        paymentMethod: 'cash',
        paymentStatus: 'verified',
        items: const [
          SaleItemRecord(
            id: 'item_1',
            saleId: 'sale_cash_1',
            productId: 'classic_fries',
            productName: 'Classic Fries',
            unitPrice: 70.0,
            unitCost: 25.0,
            quantity: 1,
            lineTotal: 70.0,
          ),
          SaleItemRecord(
            id: 'item_2',
            saleId: 'sale_cash_1',
            productId: 'sprite_masala',
            productName: 'Sprite Masala',
            unitPrice: 50.0,
            unitCost: 15.0,
            quantity: 1,
            lineTotal: 50.0,
          ),
        ],
      );
      await saleDao.insertSaleTransaction(cashSale);

      // Insert UPI Sale (₹100, cost ₹38)
      final upiSale = SaleRecord(
        id: 'sale_upi_1',
        billNumber: 'SOC-102',
        tokenNumber: 2,
        customerName: 'Rahul',
        timestamp: now,
        subtotal: 100.0,
        grandTotal: 100.0,
        totalItemsCount: 1,
        paymentMethod: 'phonepe_upi',
        paymentStatus: 'verified',
        items: const [
          SaleItemRecord(
            id: 'item_3',
            saleId: 'sale_upi_1',
            productId: 'cheese_fries',
            productName: 'Cheese Fries',
            unitPrice: 100.0,
            unitCost: 38.0,
            quantity: 1,
            lineTotal: 100.0,
          ),
        ],
      );
      await saleDao.insertSaleTransaction(upiSale);

      // Query aggregate metrics for today
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final metrics = await saleDao.getAggregateMetrics(
        startDate: todayStart,
        endDate: todayEnd,
      );

      expect(metrics['total_bills'], 2);
      expect(metrics['gross_sales'], 250.0);
      expect(metrics['cash_collection'], 150.0);
      expect(metrics['upi_collection'], 100.0);

      // Total COGS = 25 + 15 + 38 = 78.0
      expect(metrics['total_cogs'], 78.0);

      // Net profit = 250 - 78 = 172.0
      expect(metrics['net_profit'], 172.0);

      // Leaderboard
      final leaderboard = metrics['leaderboard'] as List;
      expect(leaderboard.length, 3);
    });
  });

  group('Reports Screen Widget & Layout Tests', () {
    final Map<String, dynamic> sampleReportData = {
      'gross_sales': 1250.0,
      'total_bills': 15,
      'total_items': 28,
      'total_cogs': 450.0,
      'net_profit': 680.0,
      'total_expenses': 120.0,
      'cash_collection': 750.0,
      'upi_collection': 500.0,
      'opening_float': 1500.0,
      'expected_cash_in_box': 2130.0,
      'leaderboard': [
        {
          'product_id': 'coke_fizz',
          'product_name': 'Coke Fizz',
          'total_quantity': 10,
          'total_revenue': 500.0,
        },
        {
          'product_id': 'classic_fries',
          'product_name': 'Classic Fries',
          'total_quantity': 8,
          'total_revenue': 560.0,
        },
      ],
      'recent_sales': <SaleRecord>[
        SaleRecord(
          id: 'sale_recent_1',
          billNumber: 'SOC-1048',
          tokenNumber: 48,
          customerName: 'Karan',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          subtotal: 100.0,
          grandTotal: 100.0,
          totalItemsCount: 2,
          paymentMethod: 'phonepe_upi',
          paymentStatus: 'verified',
          items: const [],
        ),
      ],
    };

    testWidgets('ReportsScreen mounts, displays header, filter chips and cards without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shiftReportProvider.overrideWith((ref) => Future.value(sampleReportData)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ReportsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. App Bar header
      expect(find.text('Shift & Margin Reports'), findsOneWidget);
      expect(find.text('Financial Intelligence & Shift Audit'), findsOneWidget);

      // 2. Date filter chips
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Custom Range'), findsOneWidget);
      expect(find.text('TILL #1 • ACTIVE'), findsOneWidget);

      // 3. Summary Cards
      expect(find.text('Cash in Drawer'), findsOneWidget);
      expect(find.text('PhonePe / UPI'), findsOneWidget);

      // 4. Financial Key Metrics
      expect(find.text('Gross Sales'), findsOneWidget);
      expect(find.text('Est. Net Profit'), findsOneWidget);
      expect(find.text('Food Cost (COGS)'), findsOneWidget);
      expect(find.text('Stall Expenses'), findsOneWidget);

      // 5. Scroll down to reveal bottom sections
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Drawer Reconciliation accordion
      expect(find.text('Cash Drawer Balance Audit'), findsOneWidget);
      expect(find.text('Opening Float'), findsOneWidget);

      // Best-Sellers Leaderboard
      expect(find.text('Best-Sellers Leaderboard'), findsOneWidget);
      expect(find.text('Coke Fizz'), findsOneWidget);
      expect(find.text('Classic Fries'), findsOneWidget);

      // Recent Transactions
      expect(find.text('Recent Transactions in Period'), findsOneWidget);
      expect(find.textContaining('SOC-1048'), findsOneWidget);
    });

    testWidgets('ReportsScreen displays properly on wide phone or tablet screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shiftReportProvider.overrideWith((ref) => Future.value(sampleReportData)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ReportsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Shift & Margin Reports'), findsOneWidget);
      expect(find.text('Cash in Drawer'), findsOneWidget);
      expect(find.text('PhonePe / UPI'), findsOneWidget);
      expect(find.text('Gross Sales'), findsOneWidget);
      expect(find.text('Est. Net Profit'), findsOneWidget);
    });

    testWidgets('ReportsScreen displays empty sales banner when total_bills is 0',
        (WidgetTester tester) async {
      final emptyReportData = {
        'gross_sales': 0.0,
        'total_bills': 0,
        'total_items': 0,
        'total_cogs': 0.0,
        'net_profit': 0.0,
        'total_expenses': 0.0,
        'cash_collection': 0.0,
        'upi_collection': 0.0,
        'opening_float': 1500.0,
        'expected_cash_in_box': 1500.0,
        'leaderboard': [],
        'recent_sales': <SaleRecord>[],
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shiftReportProvider.overrideWith((ref) => Future.value(emptyReportData)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ReportsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Sales Recorded For This Period'), findsOneWidget);
      expect(find.text('Go to Billing POS'), findsOneWidget);
    });
  });
}
