import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/billing/models/cart_item.dart';
import 'package:flutter_app/features/billing/services/billing_calculator_service.dart';
import 'package:flutter_app/features/products/models/product.dart';

void main() {
  group('BillingCalculatorService Tests', () {
    const service = BillingCalculatorService();

    final productA = Product(
      id: 'classic_fries',
      name: 'Classic Fries',
      category: 'snacks',
      sellingPrice: 70.0,
      costPrice: 25.0,
      portion: '/ portion',
      imageAsset: 'assets/food/classic_fries.png',
    );

    final productB = Product(
      id: 'cheese_fries',
      name: 'Cheese Fries',
      category: 'snacks',
      sellingPrice: 100.0,
      costPrice: 38.0,
      portion: '/ loaded',
      imageAsset: 'assets/food/cheese_fries.png',
    );

    final productC = Product(
      id: 'blue_lagoon',
      name: 'Blue Lagoon',
      category: 'sips',
      sellingPrice: 50.0,
      costPrice: 16.0,
      portion: '/ 350ml',
      imageAsset: 'assets/food/blue_lagoon.png',
    );

    test('Empty cart returns zero totals', () {
      final res = service.calculateTotals(items: []);
      expect(res.subtotal, 0.0);
      expect(res.grandTotal, 0.0);
      expect(res.totalItemsCount, 0);
      expect(res.totalCost, 0.0);
      expect(res.estimatedProfit, 0.0);
    });

    test('Stitch sample cart calculation (1 Classic Fries + 1 Cheese Fries + 1 Blue Lagoon = ₹220)', () {
      final items = [
        CartItem(product: productA, quantity: 1),
        CartItem(product: productB, quantity: 1),
        CartItem(product: productC, quantity: 1),
      ];

      final res = service.calculateTotals(items: items);
      expect(res.subtotal, 220.0);
      expect(res.grandTotal, 220.0);
      expect(res.totalItemsCount, 3);
      // Cost: 25 + 38 + 16 = 79
      expect(res.totalCost, 79.0);
      // Profit: 220 - 79 = 141
      expect(res.estimatedProfit, 141.0);
    });

    test('Discount application prevents negative grand total', () {
      final items = [
        CartItem(product: productA, quantity: 1), // ₹70
      ];

      final res = service.calculateTotals(items: items, discount: 100.0);
      expect(res.discount, 70.0);
      expect(res.grandTotal, 0.0);
    });

    test('Cash change calculation handles exact amount', () {
      final changeRes = service.calculateChange(
        grandTotal: 220.0,
        amountReceived: 220.0,
      );
      expect(changeRes.isExact, true);
      expect(changeRes.isInsufficient, false);
      expect(changeRes.change, 0.0);
    });

    test('Cash change calculation handles surplus change', () {
      final changeRes = service.calculateChange(
        grandTotal: 220.0,
        amountReceived: 500.0,
      );
      expect(changeRes.isExact, false);
      expect(changeRes.isInsufficient, false);
      expect(changeRes.change, 280.0);
    });

    test('Cash change calculation flags insufficient tender correctly', () {
      final changeRes = service.calculateChange(
        grandTotal: 220.0,
        amountReceived: 200.0,
      );
      expect(changeRes.isInsufficient, true);
      expect(changeRes.shortage, 20.0);
    });

    test(
      'Suggested cash tender pills include exact and higher denominations',
      () {
        final pills = service.getSuggestedTenderPills(220.0);
        expect(pills.contains(220.0), true);
        expect(pills.contains(300.0), true);
        expect(pills.contains(500.0), true);
      },
    );
  });
}
