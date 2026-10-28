import '../../products/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final double unitPrice;
  final double unitCost;

  CartItem({
    required this.product,
    required this.quantity,
    double? unitPrice,
    double? unitCost,
  }) : unitPrice = unitPrice ?? product.sellingPrice,
       unitCost = unitCost ?? product.costPrice;

  double get lineTotal => unitPrice * quantity;
  double get lineCostTotal => unitCost * quantity;
  double get lineProfit => lineTotal - lineCostTotal;

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? unitPrice,
    double? unitCost,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unitCost: unitCost ?? this.unitCost,
    );
  }
}
