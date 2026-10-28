import '../../../core/constants/app_constants.dart';

class PaymentSettings {
  final String upiId;
  final String merchantName;
  final String paymentInstructions;
  final String? qrImagePath;
  final DateTime updatedAt;

  const PaymentSettings({
    required this.upiId,
    required this.merchantName,
    this.paymentInstructions =
        'Scan with PhonePe, GPay, Paytm or any UPI app & show confirmation.',
    this.qrImagePath,
    required this.updatedAt,
  });

  /// Default fallback settings using authentic Stitch initial credentials
  factory PaymentSettings.defaultSettings() {
    return PaymentSettings(
      upiId: AppConstants.merchantUpiVpa,
      merchantName: AppConstants.appName,
      paymentInstructions:
          'Scan with PhonePe, GPay, Paytm or any UPI app & show confirmation.',
      qrImagePath: AppConstants.imgPhonePeQr,
      updatedAt: DateTime.now(),
    );
  }

  bool get hasQr => qrImagePath != null && qrImagePath!.trim().isNotEmpty;

  bool get isLocalFile =>
      hasQr &&
      !qrImagePath!.startsWith('assets/') &&
      !qrImagePath!.startsWith('package:');

  PaymentSettings copyWith({
    String? upiId,
    String? merchantName,
    String? paymentInstructions,
    String? qrImagePath,
    bool clearQr = false,
    DateTime? updatedAt,
  }) {
    return PaymentSettings(
      upiId: upiId ?? this.upiId,
      merchantName: merchantName ?? this.merchantName,
      paymentInstructions: paymentInstructions ?? this.paymentInstructions,
      qrImagePath: clearQr ? null : (qrImagePath ?? this.qrImagePath),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, String> toMap() {
    return {
      'upi_id': upiId,
      'merchant_name': merchantName,
      'payment_instructions': paymentInstructions,
      'qr_image_path': qrImagePath ?? '',
      'payment_settings_updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PaymentSettings.fromMap(Map<String, String?> map) {
    final upi = map['upi_id']?.trim();
    final merchant = map['merchant_name']?.trim();
    final instructions = map['payment_instructions']?.trim();
    final qrPath = map['qr_image_path']?.trim();
    final updatedStr = map['payment_settings_updated_at'];

    DateTime updated;
    if (updatedStr != null && updatedStr.isNotEmpty) {
      updated = DateTime.tryParse(updatedStr) ?? DateTime.now();
    } else {
      updated = DateTime.now();
    }

    // If qr_image_path was never set in settings, fallback to Stitch default.
    // If it was explicitly set to empty, it means the user removed it.
    final String? resolvedQr;
    if (!map.containsKey('qr_image_path') || map['qr_image_path'] == null) {
      resolvedQr = AppConstants.imgPhonePeQr;
    } else if (qrPath != null && qrPath.isNotEmpty) {
      resolvedQr = qrPath;
    } else {
      resolvedQr = null;
    }

    return PaymentSettings(
      upiId: (upi != null && upi.isNotEmpty)
          ? upi
          : AppConstants.merchantUpiVpa,
      merchantName: (merchant != null && merchant.isNotEmpty)
          ? merchant
          : AppConstants.appName,
      paymentInstructions: (instructions != null && instructions.isNotEmpty)
          ? instructions
          : 'Scan with PhonePe, GPay, Paytm or any UPI app & show confirmation.',
      qrImagePath: resolvedQr,
      updatedAt: updated,
    );
  }
}
