import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/repository_provider.dart';
import '../../products/providers/products_provider.dart';
import '../../products/models/product.dart';
import '../../products/screens/product_management_screen.dart';
import '../../products/widgets/app_product_image.dart';
import '../../reports/providers/reports_provider.dart';
import 'payment_settings_screen.dart';
import '../providers/payment_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _cashierController = TextEditingController();
  final TextEditingController _floatController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialSettings();
  }

  Future<void> _loadInitialSettings() async {
    try {
      final repo = ref.read(posRepositoryProvider);
      final cashier = await repo.getCashierName();
      final floatVal = await repo.getOpeningFloat();
      if (mounted) {
        setState(() {
          _cashierController.text = cashier;
          _floatController.text = floatVal.toStringAsFixed(0);
        });
      }
    } catch (e) {
      debugPrint('Warning: Failed to load initial settings: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cashierController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _saveCashierAndFloat() async {
    final repo = ref.read(posRepositoryProvider);
    final floatVal = double.tryParse(_floatController.text.trim()) ?? 1500.0;
    await repo.setCashierName(_cashierController.text.trim());
    await repo.setOpeningFloat(floatVal);
    ref.invalidate(shiftReportProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text('Settings saved successfully.'),
        ),
      );
    }
  }

  void _editProductPriceDialog(BuildContext context, Product product) {
    final sellController = TextEditingController(
      text: product.sellingPrice.toStringAsFixed(0),
    );
    final costController = TextEditingController(
      text: product.costPrice.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.creamCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Pricing: ${product.name}',
          style: AppTypography.headlineMedium.copyWith(fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sellController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Selling Price (₹)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Unit Cost / COGS (₹)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newSell =
                  double.tryParse(sellController.text.trim()) ??
                  product.sellingPrice;
              final newCost =
                  double.tryParse(costController.text.trim()) ??
                  product.costPrice;

              final repo = ref.read(posRepositoryProvider);
              await repo.updateProductPrice(
                id: product.id,
                sellingPrice: newSell,
                costPrice: newCost,
              );

              ref.invalidate(productsProvider);
              ref.invalidate(shiftReportProvider);

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save Price'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        backgroundColor: AppColors.burgundy,
        title: Text(
          'Stall Settings & Management',
          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.burgundy),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stall Identity Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.creamCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
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
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppConstants.appName,
                                  style: AppTypography.headlineMedium.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  AppConstants.appTagline,
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: AppColors.borderSubtle),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PhonePe UPI VPA',
                              style: AppTypography.labelSmall,
                            ),
                            Text(
                              ref.watch(paymentSettingsProvider).value?.upiId ??
                                  AppConstants.merchantUpiVpa,
                              style: AppTypography.keypadDigit.copyWith(
                                fontSize: 13,
                                color: AppColors.burgundy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FSSAI Food License',
                              style: AppTypography.labelSmall,
                            ),
                            Text(
                              AppConstants.defaultFssaiLic,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dedicated Manage Products & Menu Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.creamCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.burgundy.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.burgundy.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            color: AppColors.burgundy,
                            size: 26,
                          ),
                        ),
                        title: Text(
                          'Manage Products & Menu',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Add items, edit names & prices, replace images, activate or deactivate items',
                          style: AppTypography.bodySmall,
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.burgundy,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProductManagementScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dedicated Payment & UPI Settings Tile
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.creamCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.phonePePurple.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.phonePePurpleLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.qr_code_2,
                            color: AppColors.phonePePurple,
                            size: 26,
                          ),
                        ),
                        title: Text(
                          'Payment & UPI Settings',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Configure stall UPI ID, merchant name, and upload custom QR',
                          style: AppTypography.bodySmall,
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.burgundy,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentSettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cashier & Opening Float Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.creamCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Till & Shift Parameters',
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _cashierController,
                          decoration: const InputDecoration(
                            labelText: 'Cashier Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _floatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Opening Cash Float (₹)',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.burgundy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _saveCashierAndFloat,
                            child: const Text('Update Shift Parameters'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Prices & Unit Cost (COGS) Management
                  Text(
                    'PRODUCT PRICING & COGS SETTINGS',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  productsAsync.when(
                    data: (products) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        separatorBuilder: (ctx, idx) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final margin =
                              product.sellingPrice - product.costPrice;
                          final marginPercent =
                              (margin / product.sellingPrice) * 100;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.creamCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderSubtle,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AppProductImage(
                                    imagePath: product.imageAsset,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: AppTypography.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Sell: ${CurrencyFormatter.format(product.sellingPrice)} • Cost: ${CurrencyFormatter.format(product.costPrice)}',
                                        style: AppTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${marginPercent.toStringAsFixed(0)}% margin',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.terracotta,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(50, 24),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => _editProductPriceDialog(
                                        context,
                                        product,
                                      ),
                                      child: const Text('Edit'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.burgundy,
                      ),
                    ),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
