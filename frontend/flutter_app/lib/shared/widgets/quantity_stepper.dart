import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final double buttonSize;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.buttonSize = 34,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return InkWell(
        onTap: onIncrement,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: buttonSize + 4,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.creamContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 18, color: AppColors.burgundy),
              const SizedBox(width: 4),
              Text(
                'Add',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.burgundy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.creamLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            elevation: 1,
            shadowColor: Colors.black12,
            child: InkWell(
              onTap: onDecrement,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: const Icon(
                  Icons.remove,
                  size: 16,
                  color: AppColors.burgundy,
                ),
              ),
            ),
          ),
          // Quantity display
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: AppTypography.keypadDigit.copyWith(
                fontSize: 16,
                color: AppColors.burgundy,
              ),
            ),
          ),
          // Increment button
          Material(
            color: AppColors.burgundy,
            borderRadius: BorderRadius.circular(8),
            elevation: 1,
            shadowColor: AppColors.burgundyDark.withValues(alpha: 0.3),
            child: InkWell(
              onTap: onIncrement,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
