import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? trailingText;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingText,
    this.backgroundColor = AppColors.burgundy,
    this.foregroundColor = Colors.white,
    this.height = 54,
    this.isLoading = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedScale(
      scale: _isPressed && isEnabled ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: isEnabled
            ? widget.backgroundColor
            : widget.backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        elevation: isEnabled ? (_isPressed ? 1 : 3) : 0,
        shadowColor: AppColors.burgundyDark.withValues(alpha: 0.3),
        child: InkWell(
          onTap: isEnabled ? widget.onPressed : null,
          onHighlightChanged: (highlighted) {
            setState(() {
              _isPressed = highlighted;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: widget.isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.foregroundColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: AppTypography.headlineSmall.copyWith(
                              color: widget.foregroundColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (widget.trailingText != null)
                        Text(
                          widget.trailingText!,
                          style: AppTypography.priceMedium.copyWith(
                            color: AppColors.caramelFixed,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
