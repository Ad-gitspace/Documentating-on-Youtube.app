import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// A frosted-glass card matching the DOCSME glassmorphism language.
///
/// Uses a semi-transparent white background, a 15% white border, and
/// [BackdropFilter] for the blur effect.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurSigma = 10,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppDimens.radiusDefault);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: AppColors.glassWhite05,
            borderRadius: radius,
            border: Border.all(color: AppColors.glassWhite15),
          ),
          child: child,
        ),
      ),
    );
  }
}
