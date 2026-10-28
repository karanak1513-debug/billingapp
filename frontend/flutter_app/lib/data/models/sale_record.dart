class SaleItemRecord {
  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final double unitPrice;
  final double unitCost;
  final int quantity;
  final double lineTotal;

  const SaleItemRecord({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.unitCost,
    required this.quantity,
    required this.lineTotal,
  });

  double get lineCost => unitCost * quantity;
  double get lineProfit => lineTotal - lineCost;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'unit_cost': unitCost,
      'quantity': quantity,
      'line_total': lineTotal,
    };
  }

  factory SaleItemRecord.fromMap(Map<String, dynamic> map) {
    return SaleItemRecord(
      id: map['id'] as String,
      saleId: map['sale_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      unitCost: (map['unit_cost'] as num).toDouble(),
      quantity: map['quantity'] as int,
      lineTotal: (map['line_total'] as num).toDouble(),
    );
  }
}

class SaleRecord {
  final String id;
  final String billNumber;
  final int tokenNumber;
  final String customerName;
  final String? phoneNumber;
  final DateTime timestamp;
  final double subtotal;
  final double discount;
  final double tax;
  final double grandTotal;
  final int totalItemsCount;
  final String paymentMethod; // 'cash' | 'phonepe_upi'
  final String paymentStatus; // 'verified' | 'pending' | 'unverified'
  final double? amountReceived;
  final double? changeReturned;
  final String? notes;
  final List<SaleItemRecord> items;

  const SaleRecord({
    required this.id,
    required this.billNumber,
    required this.tokenNumber,
    required this.customerName,
    this.phoneNumber,
    required this.timestamp,
    required this.subtotal,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.grandTotal,
    required this.totalItemsCount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.amountReceived,
    this.changeReturned,
    this.notes,
    this.items = const [],
  });

  double get totalCost =>
      items.fold(0.0, (acc, item) => acc + (item.unitCost * item.quantity));

  double get netProfit => grandTotal - totalCost;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_number': billNumber,
      'token_number': tokenNumber,
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'timestamp': timestamp.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'grand_total': grandTotal,
      'total_items_count': totalItemsCount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'amount_received': amountReceived,
      'change_returned': changeReturned,
      'notes': notes,
      'is_synced': 0,
    };
  }

  factory SaleRecord.fromMap(
    Map<String, dynamic> map, {
    List<SaleItemRecord> items = const [],
  }) {
    return SaleRecord(
      id: map['id'] as String,
      billNumber: map['bill_number'] as String,
      tokenNumber: map['token_number'] as int,
      customerName: map['customer_name'] as String? ?? 'Walk-in',
      phoneNumber: map['phone_number'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      subtotal: (map['subtotal'] as num).toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grand_total'] as num).toDouble(),
      totalItemsCount: map['total_items_count'] as int,
      paymentMethod: map['payment_method'] as String,
      paymentStatus: map['payment_status'] as String,
      amountReceived: (map['amount_received'] as num?)?.toDouble(),
      changeReturned: (map['change_returned'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      items: items,
    );
  }

  SaleRecord copyWithItems(List<SaleItemRecord> newItems) {
    return SaleRecord(
      id: id,
      billNumber: billNumber,
      tokenNumber: tokenNumber,
      customerName: customerName,
      phoneNumber: phoneNumber,
      timestamp: timestamp,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      grandTotal: grandTotal,
      totalItemsCount: totalItemsCount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      amountReceived: amountReceived,
      changeReturned: changeReturned,
      notes: notes,
      items: newItems,
    );
  }
}
