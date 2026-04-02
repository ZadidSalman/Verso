import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_shapes.dart';

/// Verso Design System — Complete ThemeData
///
/// Material You 3 principles:
/// - Fixed sage colour seed — no system dynamic colour override
/// - Tonal elevation instead of drop shadows
/// - Expressive rounded shapes that feel warm, not corporate
/// - Filled and outlined button pair — filled for primary action, outlined for secondary
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // ─────────────────────────────────────────────────────────────────────
    // COLOR SCHEME
    // ─────────────────────────────────────────────────────────────────────
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      onPrimary: AppColors.onPrimary,
      onPrimaryContainer: AppColors.onPrimaryContainer,

      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondary: AppColors.onSecondary,
      onSecondaryContainer: AppColors.onSecondaryContainer,

      tertiary: AppColors.tertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiary: AppColors.onTertiary,
      onTertiaryContainer: AppColors.onTertiaryContainer,

      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,

      error: AppColors.error,
      errorContainer: AppColors.errorContainer,
      onError: AppColors.onError,
      onErrorContainer: AppColors.onErrorContainer,

      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,

      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
    ),

    // ─────────────────────────────────────────────────────────────────────
    // TYPOGRAPHY
    // ─────────────────────────────────────────────────────────────────────
    textTheme: AppTypography.textTheme,

    // ─────────────────────────────────────────────────────────────────────
    // SCAFFOLD & BACKGROUND
    // ─────────────────────────────────────────────────────────────────────
    scaffoldBackgroundColor: AppColors.background,

    // ─────────────────────────────────────────────────────────────────────
    // APP BAR
    // ─────────────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: AppTypography.textTheme.titleLarge,
    ),

    // ─────────────────────────────────────────────────────────────────────
    // BOTTOM NAVIGATION BAR
    // ─────────────────────────────────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 80,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return const IconThemeData(color: AppColors.outline, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          );
        }
        return AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.outline,
        );
      }),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // CARDS
    // ─────────────────────────────────────────────────────────────────────
    cardTheme: const CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: AppShapes.md,
      margin: EdgeInsets.zero,
    ),

    // ─────────────────────────────────────────────────────────────────────
    // BUTTONS
    // ─────────────────────────────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.outlineVariant,
        disabledForegroundColor: AppColors.onSurfaceVariant,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: AppShapes.sm,
        textStyle: AppTypography.textTheme.labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.outline),
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: AppShapes.sm,
        textStyle: AppTypography.textTheme.labelLarge,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: AppTypography.textTheme.labelLarge,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 1,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: AppShapes.sm,
        textStyle: AppTypography.textTheme.labelLarge,
      ),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // FLOATING ACTION BUTTON
    // ─────────────────────────────────────────────────────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 3,
      shape: AppShapes.xl,
    ),

    // ─────────────────────────────────────────────────────────────────────
    // INPUT DECORATION (TextFields)
    // ─────────────────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: AppShapes.radiusSm,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppShapes.radiusSm,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppShapes.radiusSm,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppShapes.radiusSm,
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppShapes.radiusSm,
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      labelStyle: AppTypography.textTheme.bodyLarge?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.error,
      ),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // CHIPS
    // ─────────────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.secondaryContainer,
      disabledColor: AppColors.tertiaryContainer,
      labelStyle: AppTypography.textTheme.labelMedium,
      side: BorderSide.none,
      shape: AppShapes.xs,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // BOTTOM SHEET
    // ─────────────────────────────────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: AppShapes.sheet,
      showDragHandle: true,
      dragHandleColor: AppColors.outlineVariant,
      dragHandleSize: Size(32, 4),
    ),

    // ─────────────────────────────────────────────────────────────────────
    // DIALOG
    // ─────────────────────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: AppShapes.lg,
      titleTextStyle: AppTypography.textTheme.headlineSmall,
      contentTextStyle: AppTypography.textTheme.bodyMedium,
    ),

    // ─────────────────────────────────────────────────────────────────────
    // SNACKBAR
    // ─────────────────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.inverseSurface,
      contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.inverseOnSurface,
      ),
      shape: AppShapes.sm,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),

    // ─────────────────────────────────────────────────────────────────────
    // DIVIDER
    // ─────────────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.outlineVariant,
      thickness: 1,
      space: 1,
    ),

    // ─────────────────────────────────────────────────────────────────────
    // ICON
    // ─────────────────────────────────────────────────────────────────────
    iconTheme: const IconThemeData(color: AppColors.onSurfaceVariant, size: 24),

    // ─────────────────────────────────────────────────────────────────────
    // PROGRESS INDICATOR
    // ─────────────────────────────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.outlineVariant,
      circularTrackColor: AppColors.outlineVariant,
    ),

    // ─────────────────────────────────────────────────────────────────────
    // TAB BAR
    // ─────────────────────────────────────────────────────────────────────
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.onSurfaceVariant,
      labelStyle: AppTypography.textTheme.titleSmall,
      unselectedLabelStyle: AppTypography.textTheme.titleSmall,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    ),

    // ─────────────────────────────────────────────────────────────────────
    // LIST TILE
    // ─────────────────────────────────────────────────────────────────────
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      titleTextStyle: AppTypography.textTheme.bodyLarge,
      subtitleTextStyle: AppTypography.textTheme.bodySmall,
      leadingAndTrailingTextStyle: AppTypography.textTheme.labelSmall,
      iconColor: AppColors.onSurfaceVariant,
    ),
  );
}
