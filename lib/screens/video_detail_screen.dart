import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../core/models/video_record.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/constants/app_dimens.dart';
import '../widgets/glass_card.dart';

/// Full-screen video detail with an embedded YouTube player.
///
/// Receives a [VideoRecord] from Firestore and renders the player
/// inside a glassmorphic container, along with video metadata.
class VideoDetailScreen extends StatefulWidget {
  final VideoRecord video;

  const VideoDetailScreen({super.key, required this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late YoutubePlayerController _playerController;

  @override
  void initState() {
    super.initState();
    _playerController = YoutubePlayerController(
      initialVideoId: widget.video.youtubeVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        showLiveFullscreenButton: false,
      ),
    );
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Video Details', style: AppTypography.headlineMd),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppDimens.containerPadding,
          0,
          AppDimens.containerPadding,
          isLandscape ? 40 : 80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── YouTube Player (Glassmorphic) ──────────────────────────
            _buildPlayerContainer(),
            const SizedBox(height: AppDimens.lg),

            // ── Metadata Cards ────────────────────────────────────────
            _metaRow('TITLE', widget.video.title),
            const SizedBox(height: AppDimens.md),
            _metaRow('DESCRIPTION', widget.video.description),
            const SizedBox(height: AppDimens.md),
            _metaRow('STATUS', widget.video.status.toUpperCase()),
            const SizedBox(height: AppDimens.md),
            _metaRow(
              'UPLOADED',
              widget.video.uploadedAt.toDate().toString().split('.').first,
            ),
          ],
        ),
      ),
    );
  }

  /// Glassmorphic container wrapping the YouTube iFrame player.
  Widget _buildPlayerContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassWhite05,
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            border: Border.all(color: AppColors.glassWhite15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              // Player
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.radiusDefault),
                ),
                child: YoutubePlayer(
                  controller: _playerController,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: AppColors.primary,
                  progressColors: ProgressBarColors(
                    playedColor: AppColors.primary,
                    handleColor: AppColors.primary,
                    bufferedColor: AppColors.primary.withValues(alpha: 0.3),
                    backgroundColor: AppColors.surfaceContainerHigh,
                  ),
                ),
              ),
              // URL bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.md,
                  vertical: AppDimens.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppDimens.radiusDefault),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_filled,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: Text(
                        'youtube.com/watch?v=${widget.video.youtubeVideoId}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.tertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Metadata label + value rendered inside a glass card.
  Widget _metaRow(String label, String value) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.sm + 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelCaps.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.bodyLg),
        ],
      ),
    );
  }
}
