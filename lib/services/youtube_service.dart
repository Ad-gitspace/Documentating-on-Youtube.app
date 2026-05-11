import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:googleapis/youtube/v3.dart' as youtube;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'firebase_service.dart';
import '../core/models/video_record.dart';

class YouTubeService {
  static final YouTubeService _instance = YouTubeService._internal();
  factory YouTubeService() => _instance;
  YouTubeService._internal();

  /// Uploads a video to the authenticated user's YouTube channel.
  Future<String?> uploadVideo({
    required File videoFile,
    required String title,
    String description = "Uploaded via DocsMe App - developed by plus ",
    List<String> tags = const ["DocsMe", "Vlog", "Daily"],
    String privacyStatus = "private",
    void Function(double)? onProgress,
  }) async {
    final auth.AuthClient? client = await AuthService().getAuthenticatedClient();
    
    if (client == null) {
      throw Exception("User is not authenticated or scopes not granted.");
    }

    final youtubeApi = youtube.YouTubeApi(client);

    final video = youtube.Video()
      ..snippet = (youtube.VideoSnippet()
        ..title = title
        ..description = description
        ..tags = tags)
      ..status = (youtube.VideoStatus()
        ..embeddable = true
        ..privacyStatus = privacyStatus);

    final fileLength = await videoFile.length();
    
    // Create a stream that tracks progress as it is read by the uploader
    int bytesRead = 0;
    final progressStream = videoFile.openRead().map((chunk) {
      bytesRead += chunk.length;
      if (onProgress != null && fileLength > 0) {
        onProgress(bytesRead / fileLength);
      }
      return chunk;
    });

    final media = youtube.Media(
      progressStream,
      fileLength,
      contentType: 'video/*',
    );

    int retries = 0;
    const int maxRetries = 5;

    while (retries <= maxRetries) {
      try {
        final response = await youtubeApi.videos.insert(
          video,
          ['snippet', 'status'],
          uploadMedia: media,
          uploadOptions: youtube.UploadOptions.resumable,
        );
        
        if (response.id != null) {
          await FirebaseService().saveVideoRecord(
            VideoRecord(
              youtubeVideoId: response.id!,
              title: title,
              description: description,
              uploadedAt: Timestamp.now(), 
              thumbnailUrl: response.snippet?.thumbnails?.high?.url ?? response.snippet?.thumbnails?.default_?.url,
              status: 'uploaded',
            ),
          );
        }
        
        return response.id; 
      } catch (e) {
        final errorString = e.toString().toLowerCase();
        final isNetworkError = errorString.contains('clientexception') || 
                               errorString.contains('software caused connection abort') || 
                               errorString.contains('failed host lookup') ||
                               errorString.contains('socketexception');
        if (isNetworkError && retries < maxRetries) {
          retries++;
          final backoffDelay = math.pow(2, retries).toInt();
          debugPrint('Network error during upload. Retrying in $backoffDelay seconds... (Attempt $retries of $maxRetries)');
          await Future.delayed(Duration(seconds: backoffDelay));
        } else {
          debugPrint('Error uploading video to YouTube: $e');
          rethrow;
        }
      }
    }
    return null;
  }

  /// Checks if the video processing is complete on YouTube.
  Future<bool> isVideoProcessingComplete(String videoId) async {
    final auth.AuthClient? client = await AuthService().getAuthenticatedClient();
    if (client == null) return false;

    final youtubeApi = youtube.YouTubeApi(client);
    try {
      final response = await youtubeApi.videos.list(['processingDetails'], id: [videoId]);
      if (response.items == null || response.items!.isEmpty) return false;

      final processingStatus = response.items!.first.processingDetails?.processingStatus;
      // processingStatus can be 'processing', 'succeeded', 'failed', 'terminated'
      return processingStatus == 'succeeded';
    } catch (e) {
      debugPrint('Error checking processing status: $e');
      return false; // Assume not done on error
    }
  }
}
