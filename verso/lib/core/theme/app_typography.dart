import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Verso Design System — Typography
///
/// Typefaces:
/// - Playfair Display: The literary soul. Poem titles, story titles, display text, English poem body.
/// - DM Sans: Clean modern chrome. All UI labels, buttons, metadata, captions, counts.
/// - System Default (no fontFamily): Bengali/Bangla text ONLY. Android resolves to Noto Serif Bengali.
///
/// RULE: Never set fontFamily on any Bengali-language content. Not even to "system".
/// Simply omit the fontFamily property entirely.
class AppTypography {
  AppTypography._();

  // ─────────────────────────────────────────────────────────────────────────
  // POEM BODY STYLES
  // ─────────────────────────────────────────────────────────────────────────

  /// English poem body - Playfair Display 18sp, line height 32sp, +0.3 letter spacing
  static TextStyle get englishPoem => GoogleFonts.playfairDisplay(
    fontSize: 18,
    height: 32 / 18,
    letterSpacing: 0.3,
    color: AppColors.onSurface,
    fontWeight: FontWeight.w400,
  );

  /// Bengali poem body - System font (no fontFamily), 18sp, line height 38sp
  /// NEVER set fontFamily on Bengali text - system resolves to Noto Serif Bengali
  static const TextStyle banglaPoem = TextStyle(
    fontSize: 18,
    height: 38 / 18,
    color: AppColors.onSurface,
    fontWeight: FontWeight.w400,
    // NO fontFamily - intentionally omitted for Bengali
  );

  /// Get appropriate poem body style based on language
  static TextStyle poemBody(String language) =>
      language == 'en' ? englishPoem : banglaPoem;

  /// Poem title style for cards - Playfair (EN) / System (BN) 22sp
  static TextStyle poemTitle(String language) {
    if (language == 'en') {
      return GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
        color: AppColors.onSurface,
      );
    }
    return const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 28 / 22,
      color: AppColors.onSurface,
    );
  }

  /// Poem title style for reader - Playfair (EN) / System (BN) 28sp
  static TextStyle poemTitleLarge(String language) {
    if (language == 'en') {
      return GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 36 / 28,
        color: AppColors.onSurface,
      );
    }
    return const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 36 / 28,
      color: AppColors.onSurface,
    );
  }

  /// Story title style for parts - Playfair (EN) / System (BN) 24sp
  static TextStyle storyTitle(String language) {
    if (language == 'en') {
      return GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: AppColors.onSurface,
      );
    }
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
      color: AppColors.onSurface,
    );
  }

  /// Poem preview style for cards - Playfair (EN) / System (BN) 16sp
  static TextStyle poemPreview(String language) {
    if (language == 'en') {
      return GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurfaceVariant,
      );
    }
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
      color: AppColors.onSurfaceVariant,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COMPLETE TEXT THEME
  // ─────────────────────────────────────────────────────────────────────────

  static TextTheme get textTheme => TextTheme(
    // Display - Welcome hero title only
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      height: 64 / 57,
      color: AppColors.onSurface,
    ),

    // Headlines - Playfair Display
    headlineLarge: GoogleFonts.playfairDisplay(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 40 / 32,
      color: AppColors.onSurface,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 36 / 28,
      color: AppColors.onSurface,
    ),
    headlineSmall: GoogleFonts.playfairDisplay(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
      color: AppColors.onSurface,
    ),

    // Titles - DM Sans
    titleLarge: GoogleFonts.dmSans(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      height: 28 / 22,
      color: AppColors.onSurface,
    ),
    titleMedium: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 24 / 16,
      color: AppColors.onSurface,
    ),
    titleSmall: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      color: AppColors.onSurface,
    ),

    // Body - DM Sans
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
      color: AppColors.onSurface,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      color: AppColors.onSurface,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w300,
      height: 16 / 12,
      color: AppColors.onSurfaceVariant,
    ),

    // Labels - DM Sans
    labelLarge: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      color: AppColors.onSurface,
    ),
    labelMedium: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 16 / 12,
      color: AppColors.onSurface,
    ),
    labelSmall: GoogleFonts.dmSans(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 16 / 11,
      color: AppColors.onSurfaceVariant,
    ),
  );
}

/// Extension to add custom text styles to TextTheme
extension TextThemeExtension on TextTheme {
  /// Labels - Tiny for badges (9sp)
  TextStyle? get labelExtraSmall => GoogleFonts.dmSans(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        height: 12 / 9,
        color: AppColors.onSurface,
      );
}
