import 'package:flutter/material.dart';

/// Verso Design System — Sage & Vellum Color Palette
///
/// ABSOLUTE RULE: Never use Color(0xFF...) or Colors.xxx in widgets.
/// Always reference AppColors.xxx tokens.
class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────────────────────────────────
  // PRIMARY FAMILY — Deep Sage Teal
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary brand color - FilledButton bg, FAB bg, active NavBar indicator,
  /// active tab text, links, focused border, cursor
  static const primary = Color(0xFF1F6B5A);

  /// Active filter chip bg, selected card tint, NavBar pill indicator, badge bg
  static const primaryContainer = Color(0xFFA8DACC);

  /// Text/icons placed on Primary bg
  static const onPrimary = Color(0xFFFFFFFF);

  /// Text/icons placed on Primary Container bg
  static const onPrimaryContainer = Color(0xFF00201A);

  // ─────────────────────────────────────────────────────────────────────────
  // SECONDARY FAMILY — Forest Sage
  // ─────────────────────────────────────────────────────────────────────────

  /// Secondary action buttons, story card accents, progress bar fill (challengee side)
  static const secondary = Color(0xFF4A7C59);

  /// Mood chip bg (default), tag chips, highlight backgrounds, "Following" filter active
  static const secondaryContainer = Color(0xFFC1E8C8);

  /// Text/icons on Secondary bg
  static const onSecondary = Color(0xFFFFFFFF);

  /// Text/icons on Secondary Container bg
  static const onSecondaryContainer = Color(0xFF0B2112);

  // ─────────────────────────────────────────────────────────────────────────
  // TERTIARY FAMILY — Muted Sage Grey
  // ─────────────────────────────────────────────────────────────────────────

  /// Timestamps, metadata text, read-count icons, secondary stat numbers on profile
  static const tertiary = Color(0xFF6B7B6E);

  /// Language chips (EN/BN badge), divider bg, disabled chip background
  static const tertiaryContainer = Color(0xFFDDE8DE);

  /// Text/icons on Tertiary bg
  static const onTertiary = Color(0xFFFFFFFF);

  /// Text/icons on Tertiary Container bg
  static const onTertiaryContainer = Color(0xFF1A2B1D);

  // ─────────────────────────────────────────────────────────────────────────
  // SURFACE FAMILY — Vellum White
  // ─────────────────────────────────────────────────────────────────────────

  /// Card backgrounds, bottom sheet bg, NavBar bg, AppBar bg, Scaffold background
  static const surface = Color(0xFFF6FAF8);

  /// ThoughtCard bg, Message thread bg, alternate row bg, input field resting bg
  static const surfaceVariant = Color(0xFFEDF4F0);

  /// All primary body text, titles on surface
  static const onSurface = Color(0xFF1A1C1A);

  /// Secondary text, captions, placeholder text, inactive icons, read-count numbers
  static const onSurfaceVariant = Color(0xFF404944);

  /// Same as Surface - Scaffold background
  static const background = Color(0xFFF6FAF8);

  /// Borders, inactive nav icons
  static const outline = Color(0xFF8FA89A);

  /// Skeleton loaders, subtle separators
  static const outlineVariant = Color(0xFFD8E5DC);

  // ─────────────────────────────────────────────────────────────────────────
  // SEMANTIC COLOURS
  // ─────────────────────────────────────────────────────────────────────────

  /// Error states, validation failures
  static const error = Color(0xFFB3261E);

  /// Error container background
  static const errorContainer = Color(0xFFF9DEDC);

  /// Text on error
  static const onError = Color(0xFFFFFFFF);

  /// Text on error container
  static const onErrorContainer = Color(0xFF410E0B);

  /// Snackbar/toast bg
  static const inverseSurface = Color(0xFF2A312D);

  /// Snackbar/toast text
  static const inverseOnSurface = Color(0xFFEDF4F0);

  /// "Live" pill, verified states (non-M3 semantic)
  static const success = Color(0xFF16A34A);

  // ─────────────────────────────────────────────────────────────────────────
  // MOOD ACCENT PALETTE
  // Used ONLY as: card left-border (3dp, 80% opacity), chip text colour.
  // NEVER as a background fill on any card, sheet, or surface.
  // ─────────────────────────────────────────────────────────────────────────

  /// Introspection, quiet sadness
  static const moodMelancholic = Color(0xFF6366F1);

  /// Love, longing, desire
  static const moodRomantic = Color(0xFFEC4899);

  /// Celebration, lightness, warmth
  static const moodJoyful = Color(0xFFF59E0B);

  /// Protest, urgency, fire
  static const moodAngry = Color(0xFFEF4444);

  /// Calm, nature, stillness (matches Primary)
  static const moodPeaceful = Color(0xFF1F6B5A);

  /// Memory, longing for the past
  static const moodNostalgic = Color(0xFF8B5CF6);

  /// Enigma, dark, unknowing
  static const moodMysterious = Color(0xFF1F2937);

  /// Sacred, transcendent, divine
  static const moodSpiritual = Color(0xFFD97706);

  /// Get mood color by key string
  static Color mood(String m) => switch (m.toLowerCase()) {
    'melancholic' => moodMelancholic,
    'romantic' => moodRomantic,
    'joyful' => moodJoyful,
    'angry' => moodAngry,
    'peaceful' => moodPeaceful,
    'nostalgic' => moodNostalgic,
    'mysterious' => moodMysterious,
    'spiritual' => moodSpiritual,
    _ => primary,
  };

  /// All mood keys for iteration
  static const moodKeys = [
    'melancholic',
    'romantic',
    'joyful',
    'angry',
    'peaceful',
    'nostalgic',
    'mysterious',
    'spiritual',
  ];
}
