import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../widgets/glass_card.dart';
import '../../../services/auth_service.dart';
import '../../../services/upload_manager.dart';
import '../camera_screen.dart';

/// Home Tab — personalized welcome, activity status, and bottom action buttons.
///
/// Responsive: uses [SingleChildScrollView] so all content is reachable in
/// both portrait and landscape orientations.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  final ImagePicker _picker = ImagePicker();

  @override
  bool get wantKeepAlive => true;

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _recordVideo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      final path = result['path'] as String;
      if (mounted) {
        await _showUploadOptionsDialog(path);
      }
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null && mounted) {
      await _showUploadOptionsDialog(video.path);
    }
  }

  Future<void> _showUploadOptionsDialog(String path) async {
    final String? action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.containerPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Upload Options', style: AppTypography.headlineMd.copyWith(color: AppColors.primary)),
                const SizedBox(height: AppDimens.md),
                ListTile(
                  leading: const Icon(Icons.flash_on, color: AppColors.primary),
                  title: Text('Fast Upload', style: TextStyle(color: AppColors.onSurface)),
                  subtitle: Text('Use default template', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  onTap: () => Navigator.pop(context, 'fast'),
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.primary),
                  title: Text('Edit Details', style: TextStyle(color: AppColors.onSurface)),
                  subtitle: Text('Modify Title, Description, and Tags', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  onTap: () => Navigator.pop(context, 'custom'),
                ),
                ListTile(
                  leading: const Icon(Icons.queue, color: AppColors.primary),
                  title: Text('Save for Later', style: TextStyle(color: AppColors.onSurface)),
                  subtitle: Text('Add to queue without uploading', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  onTap: () => Navigator.pop(context, 'queue'),
                ),
              ],
            ),
          ),
        );
      }
    );

    if (action == null) return;
    if (!mounted) return;

    if (action == 'fast') {
      context.read<UploadManager>().enqueueUpload(path, uploadNow: true);
    } else if (action == 'queue') {
      context.read<UploadManager>().enqueueUpload(path, uploadNow: false);
    } else if (action == 'custom') {
      final titleController = TextEditingController(text: 'DocsMe - ${DateTime.now().toIso8601String().split('T').first}');
      final descController = TextEditingController(text: 'Uploaded via DocsMe App');
      final tagsController = TextEditingController(text: 'DocsMe, Vlog, Daily');

      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            title: Text('Edit Details', style: TextStyle(color: AppColors.primary)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: TextStyle(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Title', 
                      labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.glassWhite10)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  TextField(
                    controller: descController,
                    style: TextStyle(color: AppColors.onSurface),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description', 
                      labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.glassWhite10)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  TextField(
                    controller: tagsController,
                    style: TextStyle(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Tags (comma separated)', 
                      labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.glassWhite10)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  Navigator.pop(context, {
                    'title': titleController.text,
                    'description': descController.text,
                    'tags': tagsController.text,
                  });
                },
                child: Text('Start Upload', style: TextStyle(color: AppColors.onPrimary)),
              ),
            ],
          );
        }
      );

      if (result != null && mounted) {
        final tagsList = result['tags']!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        context.read<UploadManager>().enqueueUpload(
          path, 
          uploadNow: true,
          title: result['title'],
          description: result['description'],
          tags: tagsList.isEmpty ? null : tagsList,
        );
      }
    }
  }

  // ── Greeting ──────────────────────────────────────────────────────────────

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = AuthService().currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'Creator';
    final uploadManager = context.watch<UploadManager>();
    final isUploading = uploadManager.currentUpload != null;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Adaptive bottom padding: smaller in landscape so content isn't pushed
    // off-screen by the nav bar.
    final bottomPadding = isLandscape ? 60.0 : 100.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ───────────────────────────────────────────────────
            _buildAppBar(),

            // ── Scrollable content ────────────────────────────────────────
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
                    SizedBox(height: isLandscape ? AppDimens.md : AppDimens.xl),

                    // Welcome
                    Text(
                      '${_getGreeting()}, $firstName 👋',
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.primary,
                        fontSize: isLandscape ? 24 : 32,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Text(
                      "What's happening in your\nbeautiful day today, show me!",
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: isLandscape ? AppDimens.md : AppDimens.xl),

                    // ── Activity Section ──────────────────────────────────
                    _buildActivitySection(uploadManager),

                    SizedBox(height: isLandscape ? AppDimens.md : AppDimens.xl),

                    // ── Bottom Action Row ─────────────────────────────────
                    _buildActionRow(isUploading, isLandscape),
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

  // ── Activity Section ──────────────────────────────────────────────────────

  Widget _buildActivitySection(UploadManager manager) {
    final current = manager.currentUpload;

    if (current != null) {
      return _uploadingCard(current);
    }

    final completed = manager.completed;
    if (completed.isNotEmpty) {
      return _lastUploadCard(completed.first);
    }

    return _noActivityCard();
  }

  Widget _uploadingCard(UploadItem item) {
    final isProcessing = item.status == UploadStatus.processing;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isProcessing ? AppColors.secondary : AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (isProcessing ? AppColors.secondary : AppColors.primary)
                          .withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Text(
                isProcessing ? 'PROCESSING' : 'UPLOADING',
                style: AppTypography.labelCaps.copyWith(
                  color: isProcessing ? AppColors.secondary : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            isProcessing
                ? 'YouTube is processing your video…'
                : 'Uploading to YouTube…',
            style: AppTypography.bodyLg.copyWith(color: AppColors.onBackground),
          ),
          const SizedBox(height: AppDimens.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: isProcessing
                  ? null
                  : (item.progress > 0 ? item.progress : null),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation(
                  isProcessing ? AppColors.secondary : AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the last uploaded video with an embedded YouTube player.
  Widget _lastUploadCard(UploadItem item) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.secondary, size: 18),
              const SizedBox(width: AppDimens.sm),
              Text(
                'LAST UPLOAD',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            'Upload complete!',
            style: AppTypography.bodyLg.copyWith(color: AppColors.onBackground),
          ),
          const SizedBox(height: AppDimens.md),

          // ── Embedded YouTube Player ──────────────────────────────────
          if (item.videoId != null) _embeddedPlayer(item.videoId!),
        ],
      ),
    );
  }

  /// Glassmorphic container wrapping a YouTube iFrame player.
  Widget _embeddedPlayer(String videoId) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassWhite05,
            borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
            border: Border.all(color: AppColors.glassWhite10),
          ),
          child: Column(
            children: [
              // Player
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.radiusDefault),
                ),
                child: YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: videoId,
                    flags: const YoutubePlayerFlags(
                      autoPlay: false,
                      mute: false,
                      showLiveFullscreenButton: false,
                    ),
                  ),
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
              // Video info bar
              Container(
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
                    Icon(Icons.play_circle_filled,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: Text(
                        'youtube.com/watch?v=$videoId',
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

  Widget _noActivityCard() {
    return GlassCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppDimens.md),
            Text(
              'No recent activity',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimens.xs),
            Text(
              'Capture or upload a video to get started',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Action Row (bottom) ───────────────────────────────────────────────────

  Widget _buildActionRow(bool isUploading, bool isLandscape) {
    final buttonHeight = isLandscape ? 80.0 : 110.0;

    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.upload_file,
            label: 'Upload',
            isPrimary: false,
            height: buttonHeight,
            onTap: isUploading ? null : _pickVideoFromGallery,
          ),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: _actionButton(
            icon: Icons.videocam_rounded,
            label: 'Capture',
            isPrimary: true,
            height: buttonHeight,
            onTap: isUploading ? null : _recordVideo,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required double height,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: isPrimary ? null : Border.all(color: AppColors.glassWhite10),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: height > 90 ? 36 : 28,
              color: isPrimary ? AppColors.onPrimary : AppColors.primary,
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              label,
              style: AppTypography.buttonText.copyWith(
                color: isPrimary ? AppColors.onPrimary : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
