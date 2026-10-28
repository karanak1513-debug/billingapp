import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../models/payment_settings.dart';
import '../providers/payment_settings_provider.dart';
import '../widgets/qr_image_card.dart';

class PaymentSettingsScreen extends ConsumerStatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  ConsumerState<PaymentSettingsScreen> createState() =>
      _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends ConsumerState<PaymentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _upiController;
  late TextEditingController _merchantController;
  late TextEditingController _instructionsController;

  bool _isSaving = false;
  bool _initialized = false;
  File? _pendingQrFile;
  bool _pendingClearQr = false;

  @override
  void initState() {
    super.initState();
    _upiController = TextEditingController();
    _merchantController = TextEditingController();
    _instructionsController = TextEditingController();
  }

  @override
  void dispose() {
    _upiController.dispose();
    _merchantController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _syncWithSettings(PaymentSettings settings) {
    if (!_initialized) {
      _upiController.text = settings.upiId;
      _merchantController.text = settings.merchantName;
      _instructionsController.text = settings.paymentInstructions;
      _initialized = true;
    }
  }

  Future<void> _saveChanges(PaymentSettings currentSettings) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(paymentSettingsProvider.notifier);

      String? qrPath = currentSettings.qrImagePath;

      // Handle pending QR changes
      if (_pendingClearQr) {
        await notifier.removeQr();
        qrPath = null;
      } else if (_pendingQrFile != null) {
        qrPath = await notifier.uploadAndPersistQr(_pendingQrFile!);
      }

      await notifier.updateSettings(
        upiId: _upiController.text.trim(),
        merchantName: _merchantController.text.trim(),
        paymentInstructions: _instructionsController.text.trim(),
        qrImagePath: qrPath,
        clearQr: _pendingClearQr,
      );

      setState(() {
        _pendingQrFile = null;
        _pendingClearQr = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Payment & UPI settings saved successfully!'),
              ],
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.errorRed,
            content: Text('Failed to save payment settings: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(paymentSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        title: Text(
          'Payment & UPI Settings',
          style: AppTypography.titleLarge.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.burgundy),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.errorRed,
                ),
                const SizedBox(height: 12),
                Text(
                  'Failed to load payment settings',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '$err',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(paymentSettingsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (settings) {
          _syncWithSettings(settings);

          // Calculate effective preview settings factoring in pending edits
          PaymentSettings effectiveSettings = settings;
          if (_pendingClearQr) {
            effectiveSettings = settings.copyWith(clearQr: true);
          } else if (_pendingQrFile != null) {
            effectiveSettings = settings.copyWith(
              qrImagePath: _pendingQrFile!.path,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Information banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.phonePePurpleLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.phonePePurple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.phonePePurple,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Configure the UPI ID and QR code displayed on the checkout screen. Changes take effect immediately on all subsequent customer bills.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // UPI Configuration Section
                  Text(
                    'UPI CONFIGURATION',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Card(
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
                          // Merchant Name
                          Text(
                            'Merchant / Stall Display Name',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _merchantController,
                            validator: Validators.validateMerchantName,
                            decoration: InputDecoration(
                              hintText: "e.g. Snacks O'Clock Campus Stall",
                              prefixIcon: const Icon(
                                Icons.storefront,
                                color: AppColors.terracotta,
                              ),
                              fillColor: AppColors.creamContainer,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // UPI ID
                          Text(
                            'Merchant UPI ID / VPA',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _upiController,
                            validator: Validators.validateUpiId,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'e.g. karan1513.wallet@phonepe',
                              prefixIcon: const Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.phonePePurple,
                              ),
                              fillColor: AppColors.creamContainer,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Payment Instructions
                          Text(
                            'Customer Instructions (Optional)',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _instructionsController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Scan and verify payment on screen before taking your snack.',
                              prefixIcon: const Icon(
                                Icons.receipt_long,
                                color: AppColors.textSecondary,
                              ),
                              fillColor: AppColors.creamContainer,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // QR Code Management Section
                  Text(
                    'QR CODE SCANNER ASSET',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  QrImageCard(
                    settings: effectiveSettings,
                    onQrSelected: (file) {
                      setState(() {
                        _pendingQrFile = file;
                        _pendingClearQr = false;
                      });
                    },
                    onRemoveQr: () {
                      setState(() {
                        _pendingClearQr = true;
                        _pendingQrFile = null;
                      });
                    },
                    onResetToDefault: () {
                      setState(() {
                        _pendingQrFile = null;
                        _pendingClearQr = false;
                      });
                      ref
                          .read(paymentSettingsProvider.notifier)
                          .resetToDefaultStitchQr();
                    },
                  ),

                  const SizedBox(height: 24),

                  // Save & Cancel Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            side: const BorderSide(
                              color: AppColors.borderMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.burgundy,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _isSaving
                              ? null
                              : () => _saveChanges(settings),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Save Changes',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
