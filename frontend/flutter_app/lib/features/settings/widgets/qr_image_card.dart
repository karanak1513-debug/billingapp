import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/payment_settings.dart';

class QrImageCard extends StatelessWidget {
  final PaymentSettings settings;
  final Function(File file) onQrSelected;
  final VoidCallback onRemoveQr;
  final VoidCallback onResetToDefault;

  const QrImageCard({
    super.key,
    required this.settings,
    required this.onQrSelected,
    required this.onRemoveQr,
    required this.onResetToDefault,
  });

  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality:
            100, // Never compress excessively - maintain QR scanability
      );

      if (picked != null) {
        final path = picked.path.toLowerCase();
        if (!path.endsWith('.png') &&
            !path.endsWith('.jpg') &&
            !path.endsWith('.jpeg')) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.errorRed,
                content: Text(
                  'Unsupported format! Please select a PNG or JPG/JPEG image.',
                ),
              ),
            );
          }
          return;
        }

        final file = File(picked.path);
        if (!await file.exists()) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.errorRed,
                content: Text('Selected file could not be read.'),
              ),
            );
          }
          return;
        }

        // If replacing an existing QR, ask for confirmation
        if (settings.hasQr && context.mounted) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.creamCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Replace QR Code?', style: AppTypography.titleMedium),
              content: Text(
                'Are you sure you want to replace the current QR code with this new image?',
                style: AppTypography.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.burgundy,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Replace'),
                ),
              ],
            ),
          );

          if (confirm != true) return;
        }

        onQrSelected(file);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.errorRed,
            content: Text('Error selecting QR image: $e'),
          ),
        );
      }
    }
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.creamCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove QR Code?', style: AppTypography.titleMedium),
        content: Text(
          'Removing the QR code will prevent customers from scanning to pay via UPI until a new QR is configured. Cash billing will continue to work normally.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove QR'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      onRemoveQr();
    }
  }

  Widget _buildPreview(BuildContext context) {
    if (!settings.hasQr) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.creamContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderMedium.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.creamWarm,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 36,
                color: AppColors.terracotta,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No QR Code Configured',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Upload your stall PhonePe or UPI merchant QR image to enable scan-and-pay on bills.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final qrPath = settings.qrImagePath!;
    Widget imageWidget;

    if (settings.isLocalFile) {
      final file = File(qrPath);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildCorruptFallback(),
        );
      } else {
        imageWidget = _buildMissingFallback();
      }
    } else {
      imageWidget = Image.asset(
        qrPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildCorruptFallback(),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildCorruptFallback() {
    return Container(
      height: 160,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image, size: 36, color: AppColors.errorRed),
          const SizedBox(height: 8),
          Text(
            'Failed to render QR image file',
            style: AppTypography.bodySmall.copyWith(color: AppColors.errorRed),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingFallback() {
    return Container(
      height: 160,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.file_copy, size: 36, color: AppColors.terracotta),
          const SizedBox(height: 8),
          Text(
            'QR file missing from disk. Please re-upload.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.terracotta,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.creamCard,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.phonePePurpleLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    color: AppColors.phonePePurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merchant QR Code',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        settings.hasQr
                            ? (settings.isLocalFile
                                  ? 'Custom Uploaded QR'
                                  : 'Default PhonePe Asset')
                            : 'Not configured',
                        style: AppTypography.labelSmall.copyWith(
                          color: settings.hasQr
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Preview
            _buildPreview(context),
            const SizedBox(height: 14),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.burgundy,
                      side: const BorderSide(color: AppColors.burgundy),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(
                      settings.hasQr ? Icons.change_circle : Icons.upload_file,
                      size: 18,
                    ),
                    label: Text(
                      settings.hasQr ? 'Change QR' : 'Upload QR Code',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () => _pickImage(context),
                  ),
                ),
                if (settings.hasQr) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Remove QR',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.errorRedLight,
                      foregroundColor: AppColors.errorRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _confirmRemove(context),
                  ),
                ],
              ],
            ),

            if (settings.isLocalFile) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  icon: const Icon(Icons.restore, size: 16),
                  label: Text(
                    'Reset to Default PhonePe QR (${AppConstants.merchantUpiVpa})',
                    style: AppTypography.labelSmall.copyWith(fontSize: 11),
                  ),
                  onPressed: onResetToDefault,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
