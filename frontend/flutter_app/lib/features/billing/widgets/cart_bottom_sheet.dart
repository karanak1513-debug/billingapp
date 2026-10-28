import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/quantity_stepper.dart';
import '../providers/cart_provider.dart';
import '../../payments/screens/payment_screen.dart';
import '../../products/widgets/app_product_image.dart';

class CartBottomSheet extends ConsumerStatefulWidget {
  final int tokenNumber;
  final String cashierName;

  const CartBottomSheet({
    super.key,
    required this.tokenNumber,
    required this.cashierName,
  });

  static Future<void> show(
    BuildContext context, {
    required int tokenNumber,
    required String cashierName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CartBottomSheet(tokenNumber: tokenNumber, cashierName: cashierName),
    );
  }

  @override
  ConsumerState<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends ConsumerState<CartBottomSheet> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(cartProvider).customerName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _proceedToPayment(
    BuildContext context, {
    required String initialMethod,
  }) {
    Navigator.pop(context); // close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          tokenNumber: widget.tokenNumber,
          cashierName: widget.cashierName,
          initialPaymentMethod: initialMethod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final totals = ref.watch(cartTotalsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          Padding(
            padding: const EdgeInsets.only(
              top: 12,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.caramelAccent.withValues(
                              alpha: 0.25,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: AppColors.terracottaDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Breakdown',
                              style: AppTypography.headlineMedium.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Token #${widget.tokenNumber} • Cashier: ${widget.cashierName}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.expand_more, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.creamContainer,
                        padding: EdgeInsets.zero,
                        fixedSize: const Size(34, 34),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderSubtle),

          // Scrollable Cart Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Optional Customer Identifier
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.creamLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        color: AppColors.terracotta,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Optional: Student Name / Token note',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            fillColor: Colors.transparent,
                            filled: false,
                          ),
                          style: AppTypography.bodyMedium,
                          onChanged: (val) {
                            ref
                                .read(cartProvider.notifier)
                                .setCustomerName(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Live Cart Items List
                Text(
                  'ITEMS ORDERED (${totals.totalItemsCount})',
                  style: AppTypography.labelSmall.copyWith(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                if (cartState.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Cart is empty',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                else
                  ...cartState.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.creamContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AppProductImage(
                              imagePath: item.product.imageAsset,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(item.unitPrice),
                                  style: AppTypography.priceMedium.copyWith(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          QuantityStepper(
                            quantity: item.quantity,
                            buttonSize: 30,
                            onIncrement: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addOrIncrement(item.product);
                            },
                            onDecrement: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .decrement(item.product.id);
                            },
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 50,
                            child: Text(
                              CurrencyFormatter.format(item.lineTotal),
                              textAlign: TextAlign.right,
                              style: AppTypography.priceMedium.copyWith(
                                fontSize: 14,
                                color: AppColors.burgundy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 8),

                // Quick Toggles / Modifiers
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.creamContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: AppColors.errorRed,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Extra Peri Dust (+₹10)',
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                          Checkbox(
                            value: cartState.hasExtraPeriDust,
                            activeColor: AppColors.burgundy,
                            onChanged: (val) {
                              ref
                                  .read(cartProvider.notifier)
                                  .toggleExtraPeriDust(val ?? false);
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.takeout_dining,
                                color: AppColors.terracotta,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Parcel / Takeaway Packaging',
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                          Checkbox(
                            value: cartState.isParcel,
                            activeColor: AppColors.burgundy,
                            onChanged: (val) {
                              ref
                                  .read(cartProvider.notifier)
                                  .toggleParcel(val ?? true);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Billing Totals Breakdown
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.creamLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: AppTypography.bodySmall),
                          Text(
                            CurrencyFormatter.format(totals.subtotal),
                            style: AppTypography.priceMedium.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Taxes / Stall Levies (0%)',
                            style: AppTypography.bodySmall,
                          ),
                          Text('₹0', style: AppTypography.bodySmall),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          height: 1,
                          color: AppColors.borderSubtle,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(totals.grandTotal),
                            style: AppTypography.priceLarge.copyWith(
                              fontSize: 22,
                              color: AppColors.burgundy,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Settlement Actions in Drawer Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.creamCard,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.borderMedium,
                            ),
                            foregroundColor: AppColors.textPrimary,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: cartState.items.isEmpty
                              ? null
                              : () => _proceedToPayment(
                                  context,
                                  initialMethod: 'cash',
                                ),
                          icon: const Icon(
                            Icons.payments_outlined,
                            color: AppColors.terracotta,
                          ),
                          label: Text(
                            'Cash Counter',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.caramelFixed,
                            foregroundColor: AppColors.terracottaDark,
                            elevation: 1,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: cartState.items.isEmpty
                              ? null
                              : () => _proceedToPayment(
                                  context,
                                  initialMethod: 'phonepe_upi',
                                ),
                          icon: const Icon(Icons.qr_code_2),
                          label: Text(
                            'Scan PhonePe',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.terracottaDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.burgundy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: cartState.items.isEmpty
                          ? null
                          : () => _proceedToPayment(
                              context,
                              initialMethod: 'phonepe_upi',
                            ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Proceed to Checkout',
                                style: AppTypography.headlineSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${CurrencyFormatter.format(totals.grandTotal)} →',
                            style: AppTypography.priceMedium.copyWith(
                              color: AppColors.caramelFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
