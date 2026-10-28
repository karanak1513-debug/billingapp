import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Headlines — Epilogue
  static TextStyle display = GoogleFonts.epilogue(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.02,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineLarge = GoogleFonts.epilogue(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = GoogleFonts.epilogue(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineSmall = GoogleFonts.epilogue(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle titleLarge = GoogleFonts.epilogue(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.epilogue(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle titleSmall = GoogleFonts.epilogue(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Text — Plus Jakarta Sans
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Numeric & Currency — Space Grotesk
  static TextStyle priceLarge = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    color: AppColors.burgundy,
  );

  static TextStyle priceMedium = GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.burgundy,
  );

  static TextStyle keypadDigit = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle labelLarge = GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.01,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMedium = GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.02,
    color: AppColors.textPrimary,
  );

  static TextStyle labelSmall = GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.03,
    color: AppColors.textSecondary,
  );
}
