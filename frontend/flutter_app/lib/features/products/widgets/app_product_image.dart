import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Robust product image renderer supporting:
/// - Offline bundled assets (starts with 'assets/')
/// - Persistent local files from image picker
/// - Fallback placeholders for empty or missing image files
class AppProductImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData defaultIcon;

  const AppProductImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.defaultIcon = Icons.fastfood_rounded,
  });

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.creamContainer,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          defaultIcon,
          size: (width != null && width! < 50) ? 20 : 32,
          color: AppColors.burgundy.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = imagePath.trim();
    if (trimmed.isEmpty) {
      return _buildPlaceholder();
    }

    Widget imageWidget;

    if (trimmed.startsWith('assets/')) {
      imageWidget = Image.asset(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      final file = File(trimmed);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } else {
        return _buildPlaceholder();
      }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
