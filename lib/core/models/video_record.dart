import 'package:cloud_firestore/cloud_firestore.dart';

class VideoRecord {
  final String youtubeVideoId;
  final String title;
  final String description;
  final Timestamp uploadedAt;
  final String? thumbnailUrl;
  final String status;

  const VideoRecord({
    required this.youtubeVideoId,
    required this.title,
    required this.description,
    required this.uploadedAt,
    this.thumbnailUrl,
    required this.status,
  });

  factory VideoRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoRecord(
      youtubeVideoId: data['youtubeVideoId'] as String? ?? doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      uploadedAt: data['uploadedAt'] as Timestamp? ?? Timestamp.now(),
      thumbnailUrl: data['thumbnailUrl'] as String?,
      status: data['status'] as String? ?? 'uploaded',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'youtubeVideoId': youtubeVideoId,
      'title': title,
      'description': description,
      'uploadedAt': uploadedAt,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'status': status,
    };
  }
}
