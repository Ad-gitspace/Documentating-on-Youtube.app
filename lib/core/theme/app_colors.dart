import 'package:flutter/material.dart';

/// Centralized color tokens for the DOCSME design system.
///
/// Palette: Deep dark-mode with warm maroon undertones.
/// Primary accent: Electric Red (#FF5540).
/// Derived from the Material 3 tonal palette used in the design mockups.
abstract final class AppColors {
  // ── Surface & Background ──────────────────────────────────────────────────
  static const Color background       = Color(0xFF141311); // Deep charcoal with warm tint
  static const Color surface          = Color(0xFF1C1B19);
  static const Color surfaceDim       = Color(0xFF141311);
  static const Color surfaceBright    = Color(0xFF3B3936);
  static const Color surfaceContainer = Color(0xFF23211E);
  static const Color surfaceContainerLow     = Color(0xFF1F1D1B);
  static const Color surfaceContainerHigh    = Color(0xFF2D2B28);
  static const Color surfaceContainerHighest = Color(0xFF383632);
  static const Color surfaceContainerLowest  = Color(0xFF0F0E0D);

  // ── Primary (Gold #D19A03) ────────────────────────────────────────────────
  static const Color primary            = Color(0xFFD19A03);
  static const Color primaryContainer   = Color(0xFFB08200);
  static const Color onPrimary          = Color(0xFF000000);
  static const Color onPrimaryContainer = Color(0xFFFFE08D);

  // ── Secondary (Green #6F8F3F) ─────────────────────────────────────────────
  static const Color secondary            = Color(0xFF6F8F3F);
  static const Color secondaryContainer   = Color(0xFF567031);
  static const Color onSecondary          = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFFD8E7C0);

  // ── Tertiary (Blue #68BBFF) ───────────────────────────────────────────────
  static const Color tertiary            = Color(0xFF68BBFF);
  static const Color tertiaryContainer   = Color(0xFF00497E);
  static const Color onTertiary          = Color(0xFF003355);
  static const Color onTertiaryContainer = Color(0xFFC1E1FF);

  // ── Neutral / Grey (#7E766A) ──────────────────────────────────────────────
  static const Color neutral            = Color(0xFF7E766A);
  static const Color onNeutral          = Color(0xFFFFFFFF);

  // ── Error ─────────────────────────────────────────────────────────────────
  static const Color error            = Color(0xFFFFB4AB);
  static const Color errorContainer   = Color(0xFF93000A);
  static const Color onError          = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // ── Text / On-Surface ─────────────────────────────────────────────────────
  static const Color onBackground     = Color(0xFFE6E2DE);
  static const Color onSurface        = Color(0xFFE6E2DE);
  static const Color onSurfaceVariant = Color(0xFFCEC6BD);
  static const Color surfaceVariant   = Color(0xFF4C463F);

  // ── Outline ───────────────────────────────────────────────────────────────
  static const Color outline        = Color(0xFF989086);
  static const Color outlineVariant = Color(0xFF4C463F);

  // ── Inverse ───────────────────────────────────────────────────────────────
  static const Color inverseSurface   = Color(0xFFE6E2DE);
  static const Color inverseOnSurface = Color(0xFF32302D);
  static const Color inversePrimary   = Color(0xFFD19A03);

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const Color surfaceTint = Color(0xFFD19A03);

  // ── Glass Helpers ─────────────────────────────────────────────────────────
  static const Color glassWhite10 = Color(0x1AFFFFFF);
  static const Color glassWhite15 = Color(0x26FFFFFF);
  static const Color glassWhite05 = Color(0x0DFFFFFF);
}
