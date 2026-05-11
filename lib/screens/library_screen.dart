import 'package:flutter/material.dart';
import '../core/models/video_record.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/constants/app_dimens.dart';
import '../widgets/glass_card.dart';
import '../services/firebase_service.dart';
import 'video_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'uploaded':
        return AppColors.secondary; // Sage green
      case 'processing':
        return AppColors.tertiary; // Sky blue
      case 'failed':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  void _confirmDelete(BuildContext context, String videoId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('Delete Video Record?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this record? This does not delete the video from YouTube.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseService().deleteVideoRecord(videoId);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Library', style: AppTypography.headlineLg.copyWith(color: AppColors.primary)),
      ),
      body: StreamBuilder<List<VideoRecord>>(
        stream: FirebaseService().watchUserVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          
          final videos = snapshot.data ?? [];
          
          if (videos.isEmpty) {
            return const Center(
              child: Text('No videos found.', style: TextStyle(color: AppColors.onSurfaceVariant)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimens.containerPadding),
            itemCount: videos.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
            itemBuilder: (context, index) {
              final video = videos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VideoDetailScreen(video: video)),
                  );
                },
                onLongPress: () => _confirmDelete(context, video.youtubeVideoId),
                child: GlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: video.thumbnailUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(video.thumbnailUrl!, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.video_library, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyLg.copyWith(color: AppColors.onBackground),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              video.uploadedAt.toDate().toString().split(' ')[0],
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(video.status).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getStatusColor(video.status)),
                        ),
                        child: Text(
                          video.status.toUpperCase(),
                          style: AppTypography.labelCaps.copyWith(color: _getStatusColor(video.status), fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
