import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// Telegram-style floating glass bottom navigation bar.
///
/// Renders a pill-shaped glass container with three tabs
/// (Home, Videos, Account). The active tab displays a highlighted
/// circular chip with a filled icon.
///
/// When [compact] is true (landscape mode), the bar shrinks and hugs
/// the bottom edge so it doesn't eat into the already-limited vertical space.
class DocsNavBar extends StatelessWidget {
  const DocsNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.compact = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool compact;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(icon: Icons.video_library_outlined, activeIcon: Icons.video_library, label: 'Videos'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = compact ? 8.0 : AppDimens.navBarBottomY;
    final iconSize = compact ? 20.0 : 24.0;
    final buttonPadding = compact ? 10.0 : 14.0;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomInset,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              width: compact
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width * 0.88,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.md,
                vertical: compact ? 4 : AppDimens.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                border: Border.all(color: AppColors.glassWhite15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_items.length, (i) {
                  final item = _items[i];
                  final isActive = i == currentIndex;
                  return _NavButton(
                    item: item,
                    isActive: isActive,
                    onTap: () => onTap(i),
                    iconSize: iconSize,
                    padding: buttonPadding,
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Internal data class ─────────────────────────────────────────────────────
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ── Single nav button widget ────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.iconSize,
    required this.padding,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final double iconSize;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppColors.primaryContainer : Colors.transparent,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                    blurRadius: 12,
                  )
                ]
              : null,
        ),
        child: AnimatedScale(
          scale: isActive ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Icon(
            isActive ? item.activeIcon : item.icon,
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
