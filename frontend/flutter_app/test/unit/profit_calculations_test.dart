import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/data/models/sale_record.dart';

void main() {
  group('Profit & COGS Snapshot Tests', () {
    test(
      'Historical sale item profit calculation uses saved snapshot cost',
      () {
        // Classic Fries sold when cost was ₹25
        const item1 = SaleItemRecord(
          id: 'item_1',
          saleId: 'sale_1',
          productId: 'classic_fries',
          productName: 'Classic Fries',
          unitPrice: 70.0,
          unitCost: 25.0, // Historical snapshot
          quantity: 2,
          lineTotal: 140.0,
        );

        expect(item1.lineCost, 50.0);
        expect(item1.lineProfit, 90.0);
      },
    );

    test('SaleRecord net profit aggregates all snapshot item costs', () {
      const item1 = SaleItemRecord(
        id: 'item_1',
        saleId: 'sale_1',
        productId: 'classic_fries',
        productName: 'Classic Fries',
        unitPrice: 70.0,
        unitCost: 25.0,
        quantity: 1,
        lineTotal: 70.0,
      );

      const item2 = SaleItemRecord(
        id: 'item_2',
        saleId: 'sale_1',
        productId: 'cheese_fries',
        productName: 'Cheese Fries',
        unitPrice: 100.0,
        unitCost: 38.0,
        quantity: 1,
        lineTotal: 100.0,
      );

      const item3 = SaleItemRecord(
        id: 'item_3',
        saleId: 'sale_1',
        productId: 'blue_lagoon',
        productName: 'Blue Lagoon',
        unitPrice: 50.0,
        unitCost: 16.0,
        quantity: 1,
        lineTotal: 50.0,
      );

      final sale = SaleRecord(
        id: 'sale_1',
        billNumber: 'SOC-1048',
        tokenNumber: 48,
        customerName: 'Karan',
        timestamp: DateTime(2026, 10, 22, 16, 15),
        subtotal: 220.0,
        grandTotal: 220.0,
        totalItemsCount: 3,
        paymentMethod: 'phonepe_upi',
        paymentStatus: 'verified',
        items: [item1, item2, item3],
      );

      // Total Cost = 25 + 38 + 16 = 79.0
      expect(sale.totalCost, 79.0);
      // Net Profit = 220 - 79 = 141.0
      expect(sale.netProfit, 141.0);
      // Yield margin % = 141 / 220 = 64.09%
      final yieldMargin = (sale.netProfit / sale.grandTotal) * 100;
      expect(yieldMargin, closeTo(64.09, 0.01));
    });
  });
}
