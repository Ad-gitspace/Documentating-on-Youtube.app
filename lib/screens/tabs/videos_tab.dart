import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../widgets/glass_card.dart';
import '../../../services/upload_manager.dart';

/// Videos Tab — displays the user's queued and uploaded videos.
///
/// Uses [SingleChildScrollView] wrapping a [Column] so the layout
/// remains scrollable in landscape mode.
class VideosTab extends StatefulWidget {
  const VideosTab({super.key});

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _showPlayerDialog(BuildContext context, String videoId) {
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        showLiveFullscreenButton: false,
      ),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                  border: Border.all(color: AppColors.glassWhite15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.md,
                        vertical: AppDimens.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.play_circle_filled,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: Text(
                              'Video Player',
                              style: AppTypography.buttonText.copyWith(
                                color: AppColors.onBackground,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.onSurfaceVariant, size: 22),
                            onPressed: () {
                              controller.pause();
                              Navigator.pop(dialogContext);
                            },
                          ),
                        ],
                      ),
                    ),
                    // Player
                    YoutubePlayer(
                      controller: controller,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: AppColors.primary,
                      progressColors: ProgressBarColors(
                        playedColor: AppColors.primary,
                        handleColor: AppColors.primary,
                        bufferedColor: AppColors.primary.withValues(alpha: 0.3),
                        backgroundColor: AppColors.surfaceContainerHigh,
                      ),
                    ),
                    // Video URL bar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimens.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(AppDimens.radiusDefault),
                        ),
                      ),
                      child: Text(
                        'youtube.com/watch?v=$videoId',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.tertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final uploadManager = context.watch<UploadManager>();
    final videos = uploadManager.queue;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final bottomPadding = isLandscape ? 60.0 : 100.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppDimens.containerPadding,
                  0,
                  AppDimens.containerPadding,
                  bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimens.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('My Videos', style: AppTypography.headlineLg),
                        if (uploadManager.pendingOrUploading.isNotEmpty)
                          TextButton.icon(
                            icon: const Icon(Icons.play_arrow,
                                color: AppColors.primary),
                            label: Text('Resume Queue',
                                style: TextStyle(color: AppColors.primary)),
                            onPressed: () => uploadManager.resumeQueue(),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.xs),
                    Text(
                      'Your queued and uploaded videos will appear here.',
                      style: AppTypography.bodySm,
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Video list or empty state
                    if (videos.isEmpty)
                      _buildEmptyState()
                    else
                      ..._buildVideoCards(videos),
                  ],
                ),
              ),
            ),
          ],
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

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerHigh,
                border: Border.all(color: AppColors.glassWhite10),
              ),
              child: Icon(
                Icons.video_library_outlined,
                size: 48,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            Text(
              'No videos yet',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimens.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Your uploaded videos will show up here.\nCapture or upload from the Home tab to get started.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Video Cards ───────────────────────────────────────────────────────────

  List<Widget> _buildVideoCards(List<UploadItem> videos) {
    return videos
        .map((video) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.md),
              child: _videoCard(video),
            ))
        .toList();
  }

  Widget _videoCard(UploadItem video) {
    final isComplete = video.status == UploadStatus.success;
    final isProcessing = video.status == UploadStatus.processing;
    final isUploading = video.status == UploadStatus.uploading;
    final isFailed = video.status == UploadStatus.failed;

    return GlassCard(
      child: Row(
        children: [
          // Thumbnail / status icon
          Container(
            width: 72,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: (isUploading || isProcessing)
                  ? const CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2)
                  : Icon(
                      isComplete
                          ? Icons.play_circle_filled
                          : (isFailed ? Icons.error : Icons.schedule),
                      color: isFailed ? Colors.red : AppColors.primary,
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  video.status.name.toUpperCase(),
                  style: AppTypography.bodySm.copyWith(
                    color: isComplete
                        ? AppColors.secondary
                        : (isFailed
                            ? Colors.red
                            : (isProcessing
                                ? AppColors.secondary
                                : AppColors.primary)),
                  ),
                ),
                if (isUploading)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: LinearProgressIndicator(
                      value: video.progress > 0 ? video.progress : null,
                    ),
                  ),
                if (isFailed && video.errorMessage != null)
                  Text(
                    video.errorMessage!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm
                        .copyWith(color: Colors.redAccent, fontSize: 10),
                  ),
              ],
            ),
          ),
          // Open player
          if (isComplete && video.videoId != null)
            IconButton(
              icon: const Icon(Icons.open_in_new,
                  color: AppColors.tertiary, size: 20),
              onPressed: () => _showPlayerDialog(context, video.videoId!),
            ),
        ],
      ),
    );
  }
}
