import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../services/billing_calculator_service.dart';
import '../../products/models/product.dart';

class CartState {
  final List<CartItem> items;
  final String customerName;
  final bool hasExtraPeriDust;
  final bool isParcel;
  final double discount;
  final double taxRate;

  const CartState({
    this.items = const [],
    this.customerName = '',
    this.hasExtraPeriDust = false,
    this.isParcel = true,
    this.discount = 0.0,
    this.taxRate = 0.0,
  });

  CartState copyWith({
    List<CartItem>? items,
    String? customerName,
    bool? hasExtraPeriDust,
    bool? isParcel,
    double? discount,
    double? taxRate,
  }) {
    return CartState(
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      hasExtraPeriDust: hasExtraPeriDust ?? this.hasExtraPeriDust,
      isParcel: isParcel ?? this.isParcel,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  int get totalItemCount =>
      items.fold(0, (total, item) => total + item.quantity);

  int getQuantity(String productId) {
    for (final item in items) {
      if (item.product.id == productId) {
        return item.quantity;
      }
    }
    return 0;
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState();
  }

  void addOrIncrement(Product product) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final current = state.items[existingIndex];
      final updatedList = List<CartItem>.from(state.items);
      updatedList[existingIndex] = current.copyWith(
        quantity: current.quantity + 1,
      );
      state = state.copyWith(items: updatedList);
    } else {
      final updatedList = List<CartItem>.from(state.items)
        ..add(CartItem(product: product, quantity: 1));
      state = state.copyWith(items: updatedList);
    }
  }

  void decrement(String productId) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == productId,
    );

    if (existingIndex >= 0) {
      final current = state.items[existingIndex];
      final updatedList = List<CartItem>.from(state.items);

      if (current.quantity > 1) {
        updatedList[existingIndex] = current.copyWith(
          quantity: current.quantity - 1,
        );
      } else {
        updatedList.removeAt(existingIndex);
      }
      state = state.copyWith(items: updatedList);
    }
  }

  void removeItem(String productId) {
    final updatedList = state.items
        .where((item) => item.product.id != productId)
        .toList();
    state = state.copyWith(items: updatedList);
  }

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  void toggleExtraPeriDust(bool value) {
    state = state.copyWith(hasExtraPeriDust: value);
  }

  void toggleParcel(bool value) {
    state = state.copyWith(isParcel: value);
  }

  void setDiscount(double discount) {
    state = state.copyWith(discount: discount);
  }

  void clearCart() {
    state = const CartState();
  }
}

final billingCalculatorProvider = Provider<BillingCalculatorService>((ref) {
  return const BillingCalculatorService();
});

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

final cartTotalsProvider = Provider<BillingCalculationResult>((ref) {
  final cartState = ref.watch(cartProvider);
  final calculator = ref.watch(billingCalculatorProvider);

  // Add extra peri peri dust (+₹10) if checked
  final effectiveItems = List<CartItem>.from(cartState.items);
  if (cartState.hasExtraPeriDust && cartState.items.isNotEmpty) {
    const periAddonProduct = Product(
      id: 'addon_peri_dust',
      name: 'Extra Peri Dust',
      category: 'snacks',
      sellingPrice: 10.0,
      costPrice: 2.0,
      portion: '/ dusting',
      imageAsset: '',
    );
    effectiveItems.add(CartItem(product: periAddonProduct, quantity: 1));
  }

  return calculator.calculateTotals(
    items: effectiveItems,
    discount: cartState.discount,
    taxRate: cartState.taxRate,
  );
});
