import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography tokens for the DOCSME design system.
///
/// Headlines & buttons → **Sora** (geometric, technical)
/// Body & labels → **Inter** (high legibility)
abstract final class AppTypography {
  // ── Headline ──────────────────────────────────────────────────────────────
  static TextStyle headlineLg = GoogleFonts.sora(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.64, // -0.02em
    color: AppColors.onBackground,
  );

  static TextStyle headlineMd = GoogleFonts.sora(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.onBackground,
  );

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.onSurface,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.onSurfaceVariant,
  );

  // ── Label ─────────────────────────────────────────────────────────────────
  static TextStyle labelCaps = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: 0.6, // 0.05em
    color: AppColors.onSurfaceVariant,
  );

  // ── Button ────────────────────────────────────────────────────────────────
  static TextStyle buttonText = GoogleFonts.sora(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1,
    color: AppColors.onSurface,
  );
}
