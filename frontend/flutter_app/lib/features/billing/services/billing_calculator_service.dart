import '../models/cart_item.dart';

class BillingCalculationResult {
  final double subtotal;
  final double discount;
  final double tax;
  final double grandTotal;
  final int totalItemsCount;
  final double totalCost;
  final double estimatedProfit;

  const BillingCalculationResult({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.grandTotal,
    required this.totalItemsCount,
    required this.totalCost,
    required this.estimatedProfit,
  });
}

class ChangeCalculationResult {
  final double change;
  final bool isExact;
  final bool isInsufficient;
  final double shortage;

  const ChangeCalculationResult({
    required this.change,
    required this.isExact,
    required this.isInsufficient,
    required this.shortage,
  });
}

class BillingCalculatorService {
  const BillingCalculatorService();

  /// Calculates bill totals atomically from cart items.
  BillingCalculationResult calculateTotals({
    required List<CartItem> items,
    double discount = 0.0,
    double taxRate = 0.0,
  }) {
    if (items.isEmpty) {
      return const BillingCalculationResult(
        subtotal: 0.0,
        discount: 0.0,
        tax: 0.0,
        grandTotal: 0.0,
        totalItemsCount: 0,
        totalCost: 0.0,
        estimatedProfit: 0.0,
      );
    }

    double subtotal = 0.0;
    double totalCost = 0.0;
    int totalCount = 0;

    for (final item in items) {
      if (item.quantity > 0) {
        subtotal += item.lineTotal;
        totalCost += item.lineCostTotal;
        totalCount += item.quantity;
      }
    }

    final effectiveDiscount = discount > subtotal ? subtotal : discount;
    final taxableAmount = subtotal - effectiveDiscount;
    final tax = taxableAmount * taxRate;
    final grandTotal = taxableAmount + tax;
    final estimatedProfit = grandTotal - totalCost;

    return BillingCalculationResult(
      subtotal: subtotal,
      discount: effectiveDiscount,
      tax: tax,
      grandTotal: grandTotal,
      totalItemsCount: totalCount,
      totalCost: totalCost,
      estimatedProfit: estimatedProfit,
    );
  }

  /// Calculates cash change and flags insufficient tender.
  ChangeCalculationResult calculateChange({
    required double grandTotal,
    required double amountReceived,
  }) {
    if (amountReceived < grandTotal) {
      return ChangeCalculationResult(
        change: 0.0,
        isExact: false,
        isInsufficient: true,
        shortage: grandTotal - amountReceived,
      );
    }

    final change = amountReceived - grandTotal;
    return ChangeCalculationResult(
      change: change,
      isExact: change == 0.0,
      isInsufficient: false,
      shortage: 0.0,
    );
  }

  /// Generates quick cash tender button suggestions based on grand total.
  List<double> getSuggestedTenderPills(double grandTotal) {
    if (grandTotal <= 0) return [100, 200, 500];

    final Set<double> suggestions = {grandTotal};

    // Common Indian currency notes
    const List<double> notes = [50, 100, 200, 500, 1000];
    for (final note in notes) {
      if (note > grandTotal) {
        suggestions.add(note);
      }
    }

    // Add next round hundred if not present
    final nextHundred = (grandTotal / 100).ceil() * 100.0;
    if (nextHundred > grandTotal) {
      suggestions.add(nextHundred);
    }

    final sorted = suggestions.toList()..sort();
    return sorted.take(4).toList();
  }
}
