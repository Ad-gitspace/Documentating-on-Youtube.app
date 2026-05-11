import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_dimens.dart';
import '../../services/auth_service.dart';

/// The login screen for DocsMe.
///
/// Features:
/// - Ambient glowing background orbs (gold/warm tones).
/// - Brand identity (logo + app name).
/// - **Slide-to-connect** glass slider with a draggable Google logo knob.
/// - On successful slide → triggers Google OAuth → navigates to the main shell.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────────────────
  double _sliderPosition = 0;
  bool _isConnecting = false;
  bool _connected = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const double _trackHeight = 72;
  static const double _knobSize = 56;
  static const double _knobPadding = 8;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  double _maxSlide(double trackWidth) =>
      trackWidth - _knobSize - (_knobPadding * 2);

  double _progress(double trackWidth) {
    final max = _maxSlide(trackWidth);
    return max <= 0 ? 0 : (_sliderPosition / max).clamp(0.0, 1.0);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _onPanUpdate(DragUpdateDetails d, double trackWidth) {
    if (_isConnecting || _connected) return;
    setState(() {
      _sliderPosition = (_sliderPosition + d.delta.dx)
          .clamp(0.0, _maxSlide(trackWidth));
    });
  }

  Future<void> _onPanEnd(double trackWidth) async {
    if (_isConnecting || _connected) return;

    final progress = _progress(trackWidth);
    if (progress > 0.85) {
      setState(() {
        _sliderPosition = _maxSlide(trackWidth);
        _isConnecting = true;
      });

      HapticFeedback.mediumImpact();

      final user = await AuthService().signIn();
      if (user != null && mounted) {
        setState(() => _connected = true);
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      } else {
        if (mounted) {
          setState(() {
            _isConnecting = false;
            _sliderPosition = 0;
          });
        }
      }
    } else {
      setState(() => _sliderPosition = 0);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // ── Ambient glows ───────────────────────────────────────────────
            _AmbientGlow(
              top: -80,
              left: -80,
              size: 420,
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 120,
            ),
            _AmbientGlow(
              bottom: -80,
              right: -80,
              size: 340,
              color: AppColors.secondary.withValues(alpha: 0.06),
              blurRadius: 100,
            ),
            // Horizontal gradient line.
            Positioned(
              top: MediaQuery.of(context).size.height * 0.5,
              left: 0,
              right: 0,
              height: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Main Content ────────────────────────────────────────────────
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.containerPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(flex: 3),
                      // App Logo
                      _BrandLogo(pulseAnimation: _pulseAnimation),
                      const SizedBox(height: AppDimens.lg),
                      // App Name
                      Text(
                        'DocsMe',
                        style: AppTypography.headlineLg.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimens.sm),
                      Text(
                        'Document your life.\nUpload automatically.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(flex: 2),
                      // Slide-to-connect
                      _buildSlider(context),
                      const SizedBox(height: 48),
                      // Footer
                      _buildFooter(),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Slider ────────────────────────────────────────────────────────────────

  Widget _buildSlider(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final trackWidth = constraints.maxWidth;
      final progress = _progress(trackWidth);

      return SizedBox(
        height: _trackHeight,
        child: Stack(
          children: [
            // Track
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _connected
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.surfaceContainer.withValues(alpha: 0.40),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    border: Border.all(
                      color: _connected
                          ? AppColors.secondary.withValues(alpha: 0.4)
                          : progress > 0
                              ? AppColors.primary.withValues(alpha: 0.30)
                              : AppColors.glassWhite10,
                    ),
                  ),
                ),
              ),
            ),

            // Fill track gradient
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: (_sliderPosition + _knobSize + _knobPadding * 2)
                  .clamp(0, trackWidth.toDouble()),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Track label
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _connected
                        ? 0
                        : (1 - (progress * 1.5).clamp(0.0, 1.0)),
                    child: Text(
                      'Slide to Connect YouTube',
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Success text
            if (_connected)
              Positioned.fill(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF6F8F3F), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Connected!',
                        style: AppTypography.buttonText.copyWith(
                          color: const Color(0xFF6F8F3F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Knob
            Positioned(
              left: _knobPadding + _sliderPosition,
              top: _knobPadding,
              child: GestureDetector(
                onPanUpdate: (d) => _onPanUpdate(d, trackWidth),
                onPanEnd: (_) => _onPanEnd(trackWidth),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: _knobSize,
                  height: _knobSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _connected
                        ? AppColors.secondary
                        : _isConnecting
                            ? AppColors.primary.withValues(alpha: 0.7)
                            : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (_connected
                                ? AppColors.secondary
                                : AppColors.primary)
                            .withValues(alpha: 0.40),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: _isConnecting && !_connected
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : _connected
                          ? const Icon(Icons.check, color: Colors.white, size: 26)
                          : const _GoogleLogo(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Text.rich(
      TextSpan(
        text: 'By connecting, you agree to DocsMe\'s\n',
        style: AppTypography.bodySm.copyWith(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.50),
        ),
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.70),
              decoration: TextDecoration.underline,
              decorationColor: AppColors.glassWhite10,
            ),
          ),
          TextSpan(
            text: ' & ',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.50),
            ),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.70),
              decoration: TextDecoration.underline,
              decorationColor: AppColors.glassWhite10,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

// ── Ambient Glow Widget ─────────────────────────────────────────────────────

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    this.top,
    this.left,
    this.bottom,
    this.right,
    required this.size,
    required this.color,
    required this.blurRadius,
  });

  final double? top, left, bottom, right;
  final double size;
  final Color color;
  final double blurRadius;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ── Brand Logo ──────────────────────────────────────────────────────────────

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.pulseAnimation});
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: 0.20 * pulseAnimation.value,
                ),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'lib/assets/logo2.png',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

// ── Google Logo ─────────────────────────────────────────────────────────────

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'G',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
