import 'package:flutter/material.dart';

/// Verso Design System — Shape System
///
/// All values based on 4dp grid. Never use inline BorderRadius.circular().
/// Always reference AppShapes.xxx tokens.
class AppShapes {
  AppShapes._();

  // ─────────────────────────────────────────────────────────────────────────
  // ROUNDED RECTANGLE SHAPES (for ShapeBorder contexts)
  // ─────────────────────────────────────────────────────────────────────────

  /// 4dp - Chips, tags, snackbars, filter chips
  static const xs = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );

  /// 8dp - Text inputs, search bar, OTP boxes, buttons
  static const sm = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  /// 12dp - Cards (PoemCard, ThoughtCard, StoryCard)
  static const md = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  /// 16dp - Bottom sheets, modals, sign-in card
  static const lg = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  /// 28dp - FAB write button
  static const xl = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(28)),
  );

  /// Circle - Avatars, circular icon buttons, live pill
  static const full = CircleBorder();

  /// 16dp top corners only - Bottom sheets
  static const sheet = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // BORDER RADIUS VALUES (for BoxDecoration contexts)
  // ─────────────────────────────────────────────────────────────────────────

  /// 4dp border radius
  static const radiusXs = BorderRadius.all(Radius.circular(4));

  /// 8dp border radius
  static const radiusSm = BorderRadius.all(Radius.circular(8));

  /// 12dp border radius
  static const radiusMd = BorderRadius.all(Radius.circular(12));

  /// 16dp border radius
  static const radiusLg = BorderRadius.all(Radius.circular(16));

  /// 28dp border radius
  static const radiusXl = BorderRadius.all(Radius.circular(28));

  /// Top 16dp border radius for sheets
  static const radiusSheet = BorderRadius.vertical(top: Radius.circular(16));
}

/// Verso Design System — Spacing System
///
/// Base unit: 4dp. All spacing values are multiples of 4dp.
/// Never use arbitrary values like 5, 7, 10, etc.
class AppSpacing {
  AppSpacing._();

  /// 4dp - Icon internal padding, micro gaps
  static const double space1 = 4;

  /// 8dp - Chip padding, icon-to-label gaps
  static const double space2 = 8;

  /// 12dp - Card internal padding (tight)
  static const double space3 = 12;

  /// 16dp - Standard margin, card full padding
  static const double space4 = 16;

  /// 24dp - Between content sections
  static const double space6 = 24;

  /// 32dp - Hero spacing, large gaps, cover margin
  static const double space8 = 32;

  /// 48dp - Screen-safe top/bottom, empty state padding
  static const double space12 = 48;

  /// Standard horizontal screen padding (16dp each side)
  static const screenPadding = EdgeInsets.symmetric(horizontal: 16);

  /// Card padding (16dp all sides)
  static const cardPadding = EdgeInsets.all(16);

  /// Tight card padding (12dp all sides)
  static const cardPaddingTight = EdgeInsets.all(12);
}
