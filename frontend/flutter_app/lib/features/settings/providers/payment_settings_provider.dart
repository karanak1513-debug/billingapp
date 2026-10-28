import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_settings.dart';
import '../../../data/repositories/repository_provider.dart';

class PaymentSettingsNotifier extends AsyncNotifier<PaymentSettings> {
  @override
  Future<PaymentSettings> build() async {
    final repo = ref.watch(posRepositoryProvider);
    return await repo.getPaymentSettings();
  }

  Future<void> updateSettings({
    required String upiId,
    required String merchantName,
    required String paymentInstructions,
    String? qrImagePath,
    bool clearQr = false,
  }) async {
    final repo = ref.read(posRepositoryProvider);
    final current = state.value ?? PaymentSettings.defaultSettings();
    final updated = current.copyWith(
      upiId: upiId,
      merchantName: merchantName,
      paymentInstructions: paymentInstructions,
      qrImagePath: qrImagePath,
      clearQr: clearQr,
      updatedAt: DateTime.now(),
    );

    await repo.savePaymentSettings(updated);
    state = AsyncData(updated);
  }

  Future<String> uploadAndPersistQr(File imageFile) async {
    final repo = ref.read(posRepositoryProvider);
    final current = state.value ?? PaymentSettings.defaultSettings();

    // If an existing custom QR exists, remove it
    await repo.removeCustomQrImage(current.qrImagePath);

    // Save newly picked file to persistent storage
    final persistentPath = await repo.saveQrImageFile(imageFile);

    final updated = current.copyWith(
      qrImagePath: persistentPath,
      updatedAt: DateTime.now(),
    );

    await repo.savePaymentSettings(updated);
    state = AsyncData(updated);
    return persistentPath;
  }

  Future<void> removeQr() async {
    final repo = ref.read(posRepositoryProvider);
    final current = state.value ?? PaymentSettings.defaultSettings();

    await repo.removeCustomQrImage(current.qrImagePath);

    final updated = current.copyWith(clearQr: true, updatedAt: DateTime.now());

    await repo.savePaymentSettings(updated);
    state = AsyncData(updated);
  }

  Future<void> resetToDefaultStitchQr() async {
    final repo = ref.read(posRepositoryProvider);
    final current = state.value ?? PaymentSettings.defaultSettings();

    await repo.removeCustomQrImage(current.qrImagePath);

    final defaults = PaymentSettings.defaultSettings();
    await repo.savePaymentSettings(defaults);
    state = AsyncData(defaults);
  }
}

final paymentSettingsProvider =
    AsyncNotifierProvider<PaymentSettingsNotifier, PaymentSettings>(
      PaymentSettingsNotifier.new,
    );
