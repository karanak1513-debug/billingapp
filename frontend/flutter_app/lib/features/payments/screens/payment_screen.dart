import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../billing/providers/cart_provider.dart';
import '../../billing/models/cart_item.dart';
import '../../../data/repositories/repository_provider.dart';
import '../../billing/screens/receipt_screen.dart';
import '../../settings/models/payment_settings.dart';
import '../../settings/providers/payment_settings_provider.dart';
import '../../settings/screens/payment_settings_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final int tokenNumber;
  final String cashierName;
  final String initialPaymentMethod;

  const PaymentScreen({
    super.key,
    required this.tokenNumber,
    required this.cashierName,
    this.initialPaymentMethod = 'phonepe_upi',
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late String _activeTab; // 'phonepe_upi' | 'cash'
  bool _isUpiVerified = false;
  late TextEditingController _cashInputController;
  double _amountReceived = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialPaymentMethod;
    final grandTotal = ref.read(cartTotalsProvider).grandTotal;
    _amountReceived = grandTotal;
    _cashInputController = TextEditingController(
      text: grandTotal.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _cashInputController.dispose();
    super.dispose();
  }

  void _onSelectTenderPill(double amount) {
    setState(() {
      _amountReceived = amount;
      _cashInputController.text = amount.toStringAsFixed(0);
    });
  }

  Future<void> _completeOrder() async {
    final cartState = ref.read(cartProvider);
    final totals = ref.read(cartTotalsProvider);
    final repo = ref.read(posRepositoryProvider);

    if (cartState.items.isEmpty) return;

    final paymentSettings =
        ref.read(paymentSettingsProvider).value ??
        PaymentSettings.defaultSettings();

    if (_activeTab == 'phonepe_upi') {
      if (!paymentSettings.hasQr) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.errorRed,
            content: Text(
              'Cannot complete UPI payment: No QR code is configured in Payment Settings.',
            ),
          ),
        );
        return;
      }
      if (!_isUpiVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.errorRed,
            content: Text(
              'Please verify customer PhonePe payment screen before completing.',
            ),
          ),
        );
        return;
      }
    }

    if (_activeTab == 'cash' && _amountReceived < totals.grandTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.errorRed,
          content: Text('Amount received is less than total payable amount.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final changeReturned = _activeTab == 'cash'
          ? (_amountReceived - totals.grandTotal)
          : 0.0;

      // Add extra peri peri dust as item if checked
      final effectiveItems = List<CartItem>.from(cartState.items);

      final saleRecord = await repo.completeSale(
        cartItems: effectiveItems,
        customerName: cartState.customerName,
        paymentMethod: _activeTab,
        paymentStatus: 'verified',
        amountReceived: _activeTab == 'cash'
            ? _amountReceived
            : totals.grandTotal,
        changeReturned: changeReturned,
        discount: cartState.discount,
        tax: totals.tax,
        notes: cartState.isParcel ? 'Parcel / Takeaway' : 'Dine-in',
      );

      // Clear cart
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        // Navigate directly to Receipt Screen replacing payment screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptScreen(saleRecord: saleRecord),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.errorRed,
            content: Text('Failed to save sale: $e'),
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final totals = ref.watch(cartTotalsProvider);
    final paymentSettings =
        ref.watch(paymentSettingsProvider).value ??
        PaymentSettings.defaultSettings();
    final calculator = ref.watch(billingCalculatorProvider);
    final suggestedPills = calculator.getSuggestedTenderPills(
      totals.grandTotal,
    );
    final changeRes = calculator.calculateChange(
      grandTotal: totals.grandTotal,
      amountReceived: _amountReceived,
    );

    final customerDisplay = cartState.customerName.trim().isEmpty
        ? 'Walk-in'
        : cartState.customerName.trim();
    final customerInitial = customerDisplay.isNotEmpty
        ? customerDisplay[0].toUpperCase()
        : 'W';

    final bool canComplete = _activeTab == 'phonepe_upi'
        ? (paymentSettings.hasQr && _isUpiVerified)
        : !changeRes.isInsufficient;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        backgroundColor: AppColors.burgundy,
        title: Text(
          'Checkout & Payment',
          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Payment & QR Settings',
            icon: const Icon(Icons.qr_code_2, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentSettingsScreen(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.burgundyDark,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Meta & Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.creamHigh,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        size: 15,
                        color: AppColors.burgundy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TOKEN #${widget.tokenNumber}',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.creamContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatRelative(DateTime.now()),
                        style: AppTypography.labelSmall.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer & Order Context Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.creamCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.caramelFixed,
                            child: Text(
                              customerInitial,
                              style: AppTypography.headlineSmall.copyWith(
                                color: AppColors.terracottaDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customerDisplay,
                                style: AppTypography.headlineSmall.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Token #${widget.tokenNumber} • Cashier: ${widget.cashierName}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'TOTAL PAYABLE',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(totals.grandTotal),
                            style: AppTypography.display.copyWith(
                              fontSize: 26,
                              color: AppColors.burgundy,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Mini item chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: cartState.items.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.creamContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.terracotta,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${item.product.name} ',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'x${item.quantity}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Payment Method Switcher Tabs (PhonePe / Cash)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.creamHigh,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeTab = 'phonepe_upi';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: _activeTab == 'phonepe_upi'
                              ? AppColors.burgundy
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTab == 'phonepe_upi'
                              ? [
                                  BoxShadow(
                                    color: AppColors.burgundy.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              size: 18,
                              color: _activeTab == 'phonepe_upi'
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PhonePe / UPI',
                              style: AppTypography.labelMedium.copyWith(
                                color: _activeTab == 'phonepe_upi'
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeTab = 'cash';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: _activeTab == 'cash'
                              ? AppColors.burgundy
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTab == 'cash'
                              ? [
                                  BoxShadow(
                                    color: AppColors.burgundy.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 18,
                              color: _activeTab == 'cash'
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Cash Counter',
                              style: AppTypography.labelMedium.copyWith(
                                color: _activeTab == 'cash'
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab Panels
            if (_activeTab == 'phonepe_upi') ...[
              // PhonePe QR Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.creamCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // PhonePe Merchant Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.phonePePurple,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'पे',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  paymentSettings.merchantName,
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: AppColors.burgundy,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'UPI Scan & Pay',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          tooltip: 'Edit Payment Settings',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.creamContainer,
                            padding: const EdgeInsets.all(6),
                          ),
                          icon: const Icon(
                            Icons.tune,
                            size: 18,
                            color: AppColors.burgundy,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PaymentSettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    if (paymentSettings.paymentInstructions
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.creamHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          paymentSettings.paymentInstructions,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Amount Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.creamLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.currency_rupee,
                                size: 18,
                                color: AppColors.terracotta,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Scan to pay exact',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            CurrencyFormatter.format(
                              totals.grandTotal,
                              showDecimals: true,
                            ),
                            style: AppTypography.priceLarge.copyWith(
                              fontSize: 20,
                              color: AppColors.terracotta,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dynamic QR Frame
                    if (!paymentSettings.hasQr)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorRedLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.errorRed.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.qr_code_scanner,
                              size: 46,
                              color: AppColors.errorRed,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'QR Code Not Configured',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.errorRed,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Upload your stall UPI QR code in Payment Settings to accept PhonePe and UPI payments.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.burgundy,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.settings, size: 18),
                              label: const Text('Open Payment Settings'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PaymentSettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.burgundy.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: paymentSettings.isLocalFile
                                  ? Image.file(
                                      File(paymentSettings.qrImagePath!),
                                      width: 210,
                                      height: 280,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder: (ctx, err, st) => Container(
                                        width: 210,
                                        height: 280,
                                        color: AppColors.creamContainer,
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 60,
                                            color: AppColors.errorRed,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Image.asset(
                                      paymentSettings.qrImagePath!,
                                      width: 210,
                                      height: 280,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder: (ctx, err, st) => Container(
                                        width: 210,
                                        height: 280,
                                        color: AppColors.creamContainer,
                                        child: const Center(
                                          child: Icon(Icons.qr_code, size: 80),
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.successGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  paymentSettings.isLocalFile
                                      ? 'Custom Stall QR • Scan & Pay'
                                      : 'PhonePe QR • Original Scan',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),

                    // UPI ID Copy Strip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.creamContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Merchant VPA',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                paymentSettings.upiId,
                                style: AppTypography.keypadDigit.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: paymentSettings.upiId),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('UPI ID copied to clipboard'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.copy, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Copy',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Cashier Verification Checklist Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.creamHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user,
                          color: AppColors.terracotta,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cashier Check Requirement',
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Do not hand over food tokens without matching transaction state.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isUpiVerified = !_isUpiVerified;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isUpiVerified
                              ? AppColors.successGreenLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isUpiVerified,
                              activeColor: AppColors.burgundy,
                              onChanged: (val) {
                                setState(() {
                                  _isUpiVerified = val ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                'I visually verified customer PhonePe green tick confirmation screen or merchant SMS',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _isUpiVerified
                                      ? AppColors.successGreen
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Cash Tender Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.creamCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cash Calculation',
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.creamContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Tender Mode',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Amount Received & Change Returned Grid
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.creamLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: changeRes.isInsufficient
                                    ? AppColors.errorRed
                                    : AppColors.borderSubtle,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount Received',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '₹',
                                      style: AppTypography.priceMedium.copyWith(
                                        fontSize: 20,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextField(
                                        controller: _cashInputController,
                                        keyboardType: TextInputType.number,
                                        style: AppTypography.priceLarge
                                            .copyWith(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          fillColor: Colors.transparent,
                                          filled: false,
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            _amountReceived =
                                                double.tryParse(val) ?? 0.0;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: changeRes.isInsufficient
                                  ? AppColors.errorRedLight
                                  : AppColors.creamHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  changeRes.isInsufficient
                                      ? 'Shortage Due'
                                      : 'Change to Return',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: changeRes.isInsufficient
                                        ? AppColors.errorRed
                                        : AppColors.terracottaDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  changeRes.isInsufficient
                                      ? CurrencyFormatter.format(
                                          changeRes.shortage,
                                        )
                                      : CurrencyFormatter.format(
                                          changeRes.change,
                                        ),
                                  style: AppTypography.priceLarge.copyWith(
                                    fontSize: 22,
                                    color: changeRes.isInsufficient
                                        ? AppColors.errorRed
                                        : AppColors.terracottaDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Quick Suggested Tender Pills
                    Text(
                      'QUICK TENDER SHORTCUTS',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: suggestedPills.map((amount) {
                        final isExact = amount == totals.grandTotal;
                        return ActionChip(
                          backgroundColor: _amountReceived == amount
                              ? AppColors.burgundy
                              : AppColors.creamContainer,
                          side: BorderSide(
                            color: _amountReceived == amount
                                ? AppColors.burgundy
                                : AppColors.borderSubtle,
                          ),
                          label: Text(
                            isExact
                                ? '${CurrencyFormatter.format(amount)} (Exact)'
                                : CurrencyFormatter.format(amount),
                            style: AppTypography.labelMedium.copyWith(
                              color: _amountReceived == amount
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () => _onSelectTenderPill(amount),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Submit Sale Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canComplete
                      ? AppColors.burgundy
                      : AppColors.burgundy.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: canComplete ? 3 : 0,
                ),
                onPressed: canComplete && !_isSubmitting
                    ? () => _completeOrder()
                    : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                _activeTab == 'phonepe_upi'
                                    ? 'Confirm Verified Payment'
                                    : 'Complete Cash Order',
                                style: AppTypography.headlineSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            CurrencyFormatter.format(totals.grandTotal),
                            style: AppTypography.priceLarge.copyWith(
                              color: AppColors.caramelFixed,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
