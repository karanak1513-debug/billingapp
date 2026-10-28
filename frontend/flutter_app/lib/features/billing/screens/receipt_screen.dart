import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/sale_record.dart';
import '../services/receipt_pdf_service.dart';

class ReceiptScreen extends StatelessWidget {
  final SaleRecord saleRecord;

  const ReceiptScreen({super.key, required this.saleRecord});

  @override
  Widget build(BuildContext context) {
    final isUpi = saleRecord.paymentMethod == 'phonepe_upi';

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        backgroundColor: AppColors.burgundy,
        title: Text(
          'Digital Receipt & Token',
          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Return to POS home
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.creamCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.caramelFixed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.terracotta,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PAYMENT VERIFIED',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.terracotta,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            isUpi
                                ? 'PhonePe UPI • ${AppConstants.merchantUpiVpa}'
                                : 'Cash Counter Verified',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.creamContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'TILL #1',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.burgundy,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Token Spotlight Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.burgundy,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.burgundyDark.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.restaurant,
                        color: AppColors.caramelAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'STALL COLLECTION TOKEN',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.caramelFixed,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '#${saleRecord.tokenNumber}',
                    style: AppTypography.display.copyWith(
                      color: AppColors.caramelAccent,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                      children: [
                        const TextSpan(text: 'Order sent to '),
                        TextSpan(
                          text: 'Fryer & Beverage Station',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.caramelAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Estimated Prep: 3-5 mins',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.caramelFixed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Thermal Receipt Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.creamCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Decorative paper tear top strip
                  Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.creamLow,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        // Brand Header
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.caramelAccent,
                              width: 1.5,
                            ),
                            image: const DecorationImage(
                              image: AssetImage(AppConstants.imgLogo),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConstants.appName.toUpperCase(),
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.burgundy,
                          ),
                        ),
                        Text(
                          AppConstants.appSecondaryTagline,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.terracotta,
                            letterSpacing: 1.0,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${DateFormatter.formatReceipt(saleRecord.timestamp)} • ${saleRecord.notes ?? "Takeaway"}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Receipt Meta
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.creamLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bill No',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '#${saleRecord.billNumber}',
                                    style: AppTypography.priceMedium.copyWith(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Customer',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    saleRecord.customerName,
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Itemized Order Table
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ITEM & QUANTITY',
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'AMOUNT',
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        ...saleRecord.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.creamHigh,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${item.quantity}x',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.burgundy,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.productName,
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(item.lineTotal),
                                  style: AppTypography.priceMedium.copyWith(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            color: AppColors.borderSubtle,
                          ),
                        ),

                        // Bill Calculations
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.creamLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Item Subtotal',
                                    style: AppTypography.bodySmall,
                                  ),
                                  Text(
                                    CurrencyFormatter.format(
                                      saleRecord.subtotal,
                                    ),
                                    style: AppTypography.priceMedium.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Stall Tax / GST',
                                    style: AppTypography.bodySmall,
                                  ),
                                  Text(
                                    'Included (₹0)',
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                              if (saleRecord.discount > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Special Discount',
                                      style: AppTypography.bodySmall,
                                    ),
                                    Text(
                                      '-${CurrencyFormatter.format(saleRecord.discount)}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.errorRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'GRAND TOTAL',
                                          style: AppTypography.labelSmall
                                              .copyWith(
                                                letterSpacing: 0.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Text(
                                          isUpi
                                              ? 'Paid via PhonePe QR'
                                              : 'Paid in Cash',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.terracotta,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      CurrencyFormatter.format(
                                        saleRecord.grandTotal,
                                        showDecimals: true,
                                      ),
                                      style: AppTypography.priceLarge.copyWith(
                                        fontSize: 22,
                                        color: AppColors.burgundy,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Receipt Micro Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 14,
                              color: AppColors.terracotta,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Thank you for snacking with us!',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.terracotta,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'FSSAI Lic: ${AppConstants.defaultFssaiLic}',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.terracotta),
                      foregroundColor: AppColors.terracottaDark,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () =>
                        ReceiptPdfService.shareReceiptPdf(saleRecord),
                    icon: const Icon(Icons.share, size: 18),
                    label: Text(
                      'Share PDF',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.burgundy),
                      foregroundColor: AppColors.burgundy,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => ReceiptPdfService.printReceipt(saleRecord),
                    icon: const Icon(Icons.print, size: 18),
                    label: Text(
                      'Print',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Start Next Bill Primary Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.add_shopping_cart, size: 20),
                label: Text(
                  'Start Next Bill',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
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
