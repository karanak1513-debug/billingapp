class Validators {
  Validators._();

  /// Regex pattern for standard UPI VPA (e.g. `username@bank`, `karan1513.wallet@phonepe`)
  static final RegExp _upiRegex = RegExp(
    r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z0-9]{2,64}$',
  );

  /// Validates a UPI ID
  static String? validateUpiId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UPI ID cannot be empty.';
    }

    final trimmed = value.trim();
    if (!trimmed.contains('@')) {
      return 'UPI ID must contain "@" (e.g. stallname@upi).';
    }

    if (!_upiRegex.hasMatch(trimmed)) {
      return 'Invalid UPI ID format. Example: stallname@phonepe or 9876543210@paytm';
    }

    return null;
  }

  /// Validates merchant or cashier name
  static String? validateMerchantName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Merchant display name cannot be empty.';
    }
    if (value.trim().length < 2) {
      return 'Merchant name must be at least 2 characters long.';
    }
    return null;
  }
}
