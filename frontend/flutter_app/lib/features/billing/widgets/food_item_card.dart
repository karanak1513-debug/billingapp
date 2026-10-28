import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/quantity_stepper.dart';
import '../../products/models/product.dart';
import '../../products/widgets/app_product_image.dart';

class FoodItemCard extends StatelessWidget {
  final Product product;
  final int quantityInCart;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const FoodItemCard({
    super.key,
    required this.product,
    required this.quantityInCart,
    required this.onIncrement,
    required this.onDecrement,
  });

  Color _getBadgeColor(String? badge) {
    if (badge == null) return AppColors.burgundy;
    final lower = badge.toLowerCase();
    if (lower.contains('best')) return AppColors.terracotta;
    if (lower.contains('spicy')) return AppColors.errorRed;
    if (lower.contains('limited')) return AppColors.caramelWarm;
    if (lower.contains('classic')) return AppColors.burgundy;
    if (lower.contains('blue') || lower.contains('lagoon')) return const Color(0xFF0288D1);
    if (lower.contains('apple') || lower.contains('green')) return const Color(0xFF2E7D32);
    if (lower.contains('water') || lower.contains('melon')) return const Color(0xFFE53935);
    if (lower.contains('cranberry')) return const Color(0xFF880E4F);
    if (lower.contains('mojito') || lower.contains('mint')) return const Color(0xFF388E3C);
    if (lower.contains('cola') || lower.contains('coke')) return AppColors.burgundyDark;
    if (lower.contains('lime') || lower.contains('masala') || lower.contains('veg')) {
      return const Color(0xFF1B5E20);
    }
    if (lower.contains('citrus') || lower.contains('orange') || lower.contains('mango') || lower.contains('pulp')) {
      return const Color(0xFFE65100);
    }
    if (lower.contains('thunder') || lower.contains('strong')) {
      return const Color(0xFF0D47A1);
    }
    if (lower.contains('chilled') || lower.contains('sips') || lower.contains('drinks')) {
      return AppColors.caramelWarm;
    }
    return AppColors.burgundy;
  }

  @override
  Widget build(BuildContext context) {
    final hasItem = quantityInCart > 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasItem ? AppColors.burgundy : AppColors.borderSubtle,
          width: hasItem ? 1.5 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: hasItem
                ? AppColors.burgundyDark.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: hasItem ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Thumbnail with Badges
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.creamContainer,
                    child: AppProductImage(
                      imagePath: product.imageAsset,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Category/Characteristic badge
                if (product.badge != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getBadgeColor(product.badge),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        product.badge!.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // In-cart quantity badge
                if (hasItem)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.caramelAccent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '$quantityInCart in cart',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.terracottaDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Dish Name
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineSmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          // Price & Portion
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.format(product.sellingPrice),
                style: AppTypography.priceMedium.copyWith(
                  fontSize: 17,
                  color: AppColors.burgundy,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                product.portion,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Stepper / Quick Add
          SizedBox(
            width: double.infinity,
            child: QuantityStepper(
              quantity: quantityInCart,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ),
        ],
      ),
    );
  }
}
