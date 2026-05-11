import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/models/video_record.dart';
import '../core/models/user_settings.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        // Also update in Firestore users document
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': displayName,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to update display name: ${e.toString()}');
    }
  }

  // ── Video operations ──────────────────────────────────────────────────────

  Future<void> saveVideoRecord(VideoRecord record) async {
    try {
      // Create a map to store, replacing the local Timestamp with a server timestamp
      final map = record.toMap();
      map['uploadedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('videos')
          .doc(record.youtubeVideoId)
          .set(map);
    } catch (e) {
      throw Exception('Failed to save video record: ${e.toString()}');
    }
  }

  Future<List<VideoRecord>> fetchUserVideos() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('videos')
          .orderBy('uploadedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => VideoRecord.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user videos: ${e.toString()}');
    }
  }

  Future<void> updateVideoStatus(String videoId, String status) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('videos')
          .doc(videoId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Failed to update video status: ${e.toString()}');
    }
  }

  Future<void> deleteVideoRecord(String videoId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('videos')
          .doc(videoId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete video record: ${e.toString()}');
    }
  }

  Stream<List<VideoRecord>> watchUserVideos() {
    try {
      return _firestore
          .collection('users')
          .doc(_uid)
          .collection('videos')
          .orderBy('uploadedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => VideoRecord.fromFirestore(doc)).toList());
    } catch (e) {
      throw Exception('Failed to watch user videos: ${e.toString()}');
    }
  }

  // ── Settings operations ───────────────────────────────────────────────────

  Future<void> saveUserSettings(UserSettings settings) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .set({'settings': settings.toMap()}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user settings: ${e.toString()}');
    }
  }

  Future<UserSettings?> fetchUserSettings() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      if (!doc.exists) return null;
      
      final data = doc.data();
      if (data != null && data.containsKey('settings')) {
        // Create a fake DocumentSnapshot behavior by wrapping it
        // Or just map it directly:
        final settingsMap = data['settings'] as Map<String, dynamic>;
        return UserSettings(
          defaultTitle: settingsMap['defaultTitle'] as String? ?? 'DocsMe Upload',
          defaultDescription: settingsMap['defaultDescription'] as String? ?? 'Uploaded via DocsMe App',
          autoUploadEnabled: settingsMap['autoUploadEnabled'] as bool? ?? false,
          preferredPrivacy: settingsMap['preferredPrivacy'] as String? ?? 'private',
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user settings: ${e.toString()}');
    }
  }
}
