import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../widgets/glass_card.dart';
import '../../../services/auth_service.dart';

/// Account Tab — user profile and app settings.
class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> with AutomaticKeepAliveClientMixin {
  final _authService = AuthService();
  bool _appendDate = true;
  bool _autoUpload = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _handleSignOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = _authService.currentUser;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: isLandscape ? 60 : 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App Bar ─────────────────────────────────────────────────
              _buildAppBar(),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.containerPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimens.lg),
                    Text(
                      'Settings',
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimens.xs),
                    Text(
                      'Manage your account and preferences.',
                      style: AppTypography.bodySm,
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Account Info
                    _accountInfoCard(user),
                    const SizedBox(height: AppDimens.lg),

                    // Upload Preferences
                    _uploadPrefsCard(),
                    const SizedBox(height: AppDimens.lg),

                    // Default Description
                    _descriptionCard(),
                    const SizedBox(height: AppDimens.lg),

                    // Sign Out
                    _signOutButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.containerPadding,
        vertical: AppDimens.md,
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'lib/assets/logo2.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          Text(
            'DocsMe',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Account Info ──────────────────────────────────────────────────────────

  Widget _accountInfoCard(dynamic user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.manage_accounts, color: AppColors.primary, size: 22),
              const SizedBox(width: AppDimens.sm),
              Text('Account Info',
                  style: AppTypography.headlineMd.copyWith(fontSize: 20)),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          Row(
            children: [
              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                  color: AppColors.surfaceContainerHigh,
                ),
                child: user?.photoUrl != null
                    ? ClipOval(
                        child:
                            Image.network(user!.photoUrl!, fit: BoxFit.cover))
                    : const Icon(Icons.person, color: AppColors.primary, size: 36),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Creator',
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'Not signed in',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Upload Preferences ────────────────────────────────────────────────────

  Widget _uploadPrefsCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: AppColors.primary, size: 22),
              const SizedBox(width: AppDimens.sm),
              Text('Upload Preferences',
                  style: AppTypography.headlineMd.copyWith(fontSize: 20)),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            'Configure how DocsMe handles your uploads.',
            style: AppTypography.bodySm,
          ),
          const SizedBox(height: AppDimens.lg),
          _toggleRow(
            'Append Date to Title',
            _appendDate,
            (v) => setState(() => _appendDate = v),
          ),
          const SizedBox(height: AppDimens.md),
          _toggleRow(
            'Auto-Upload on Capture',
            _autoUpload,
            (v) => setState(() => _autoUpload = v),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: AppTypography.bodyLg)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
          inactiveThumbColor: AppColors.onSurfaceVariant,
          inactiveTrackColor: AppColors.surfaceContainerHighest,
        ),
      ],
    );
  }

  // ── Default Description ───────────────────────────────────────────────────

  Widget _descriptionCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: AppColors.primary, size: 22),
              const SizedBox(width: AppDimens.sm),
              Text('Default Description',
                  style: AppTypography.headlineMd.copyWith(fontSize: 20)),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            'This text will be added to every new upload.',
            style: AppTypography.bodySm,
          ),
          const SizedBox(height: AppDimens.md),
          Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              border: Border.all(color: AppColors.glassWhite10),
            ),
            child: TextField(
              maxLines: 4,
              style: AppTypography.bodyLg,
              decoration: InputDecoration.collapsed(
                hintText: 'Enter default description…',
                hintStyle: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerHighest,
                foregroundColor: AppColors.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  side: const BorderSide(color: AppColors.glassWhite10),
                ),
              ),
              child: Text('Save Template', style: AppTypography.buttonText),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Widget _signOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleSignOut,
        icon: const Icon(Icons.logout, size: 20),
        label: Text('Sign Out',
            style: AppTypography.buttonText.copyWith(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorContainer,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
