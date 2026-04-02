import 'package:flutter/material.dart';

/// Verso Design System — Animation Constants
///
/// Every animation must have a reduced motion fallback — no exceptions.
/// Use reducedMotion(context) to check before applying animations.
class AppDurations {
  AppDurations._();

  /// 100ms - Micro interactions, instant feedback
  static const instant = Duration(milliseconds: 100);

  /// 150ms - Quick feedback, chip activation
  static const quick = Duration(milliseconds: 150);

  /// 250ms - Standard transitions, color changes
  static const standard = Duration(milliseconds: 250);

  /// 350ms - Page transitions, emphasized motion
  static const emphasized = Duration(milliseconds: 350);

  /// 500ms - Expressive animations, celebrations
  static const expressive = Duration(milliseconds: 500);

  /// 800ms - Cursor pulse, slow prose-like motion
  static const prose = Duration(milliseconds: 800);

  /// 1500ms - Skeleton shimmer loop
  static const shimmer = Duration(milliseconds: 1500);

  /// 1200ms - Live indicator pulse
  static const pulse = Duration(milliseconds: 1200);
}

/// Animation curves following Material Design 3 motion principles
class AppCurves {
  AppCurves._();

  /// Emphasized easing - primary page transitions, important state changes
  static const emphasized = Curves.easeInOutCubicEmphasized;

  /// Sheet opening - bottom sheets, modals entering
  static const sheetOpen = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Sheet closing - bottom sheets, modals exiting
  static const sheetClose = Cubic(0.3, 0.0, 0.8, 0.15);

  /// Standard easing - general purpose
  static const standard = Curves.easeInOut;

  /// Decelerate - elements coming to rest
  static const decelerate = Curves.easeOut;

  /// Accelerate - elements leaving
  static const accelerate = Curves.easeIn;

  /// Spring - bouncy, playful motion (like animation)
  static const spring = Curves.elasticOut;
}

/// Helper to check if reduced motion is enabled
///
/// Usage:
/// ```dart
/// final noMotion = reducedMotion(context);
/// if (noMotion) {
///   // Simple fade only
/// } else {
///   // Full animation
/// }
/// ```
bool reducedMotion(BuildContext context) =>
    MediaQuery.of(context).disableAnimations;

/// Animation helper extensions
extension AnimationHelpers on Duration {
  /// Convert to milliseconds for flutter_animate
  int get ms => inMilliseconds;
}
