import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'youtube_service.dart';

enum UploadStatus { pending, uploading, processing, success, failed }

class UploadItem {
  final String id;
  final String filePath;
  final String title;
  final String description;
  final List<String> tags;
  UploadStatus status;
  double progress;
  String? videoId;
  String? errorMessage;
  final DateTime createdAt;

  UploadItem({
    required this.id,
    required this.filePath,
    required this.title,
    this.description = "Uploaded via DocsMe App",
    this.tags = const [],
    this.status = UploadStatus.pending,
    this.progress = 0.0,
    this.videoId,
    this.errorMessage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'title': title,
      'description': description,
      'tags': tags,
      'status': status.index,
      'progress': progress,
      'videoId': videoId,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UploadItem.fromMap(Map<String, dynamic> map) {
    return UploadItem(
      id: map['id'],
      filePath: map['filePath'],
      title: map['title'],
      description: map['description'] ?? 'Uploaded via DocsMe App',
      tags: List<String>.from(map['tags'] ?? []),
      status: UploadStatus.values[map['status'] ?? 0],
      progress: map['progress'] ?? 0.0,
      videoId: map['videoId'],
      errorMessage: map['errorMessage'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}

class UploadManager extends ChangeNotifier {
  static final UploadManager _instance = UploadManager._internal();
  factory UploadManager() => _instance;
  UploadManager._internal();

  final List<UploadItem> _queue = [];
  bool _isProcessing = false;
  static const String _prefsKey = 'upload_queue_v1';

  Future<void> initQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final String? queueData = prefs.getString(_prefsKey);
    if (queueData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(queueData);
        _queue.clear();
        for (var map in decoded) {
          final item = UploadItem.fromMap(map as Map<String, dynamic>);
          // If an item was uploading or processing when the app closed, it's failed now
          if (item.status == UploadStatus.uploading || item.status == UploadStatus.processing) {
            item.status = UploadStatus.failed;
            item.errorMessage = 'Upload interrupted';
          }
          _queue.add(item);
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to load queue: $e');
      }
    }
  }

  Future<void> _saveQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_queue.map((e) => e.toMap()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  List<UploadItem> get queue => List.unmodifiable(_queue);

  List<UploadItem> get pendingOrUploading => 
      _queue.where((item) => item.status == UploadStatus.pending || item.status == UploadStatus.uploading).toList();
      
  List<UploadItem> get completed => 
      _queue.where((item) => item.status == UploadStatus.success).toList();

  UploadItem? get currentUpload => 
      _queue.cast<UploadItem?>().firstWhere((item) => item?.status == UploadStatus.uploading || item?.status == UploadStatus.processing, orElse: () => null);

  void enqueueUpload(
    String filePath, {
    bool uploadNow = true,
    String? title,
    String? description,
    List<String>? tags,
  }) {
    // Duplicate Upload Prevention
    final isDuplicate = _queue.any((item) => 
      item.filePath == filePath && 
      (item.status == UploadStatus.success || item.status == UploadStatus.processing || item.status == UploadStatus.uploading)
    );

    if (isDuplicate) {
      debugPrint('Skipping duplicate upload for: $filePath');
      return;
    }

    final finalTitle = title ?? 'DocsMe - ${DateTime.now().toIso8601String().split('T').first}';
    final newItem = UploadItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: filePath,
      title: finalTitle,
      description: description ?? "Uploaded via DocsMe App",
      tags: tags ?? const ["DocsMe", "Vlog", "Daily"],
      status: UploadStatus.pending,
    );
    _queue.insert(0, newItem);
    _saveQueue();
    notifyListeners();

    if (uploadNow) {
      _processQueue();
    }
  }

  void resumeQueue() {
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    
    final pendingItems = _queue.where((item) => item.status == UploadStatus.pending || item.status == UploadStatus.failed).toList();
    if (pendingItems.isEmpty) return;

    _isProcessing = true;

    for (var item in pendingItems) {
      try {
        item.status = UploadStatus.uploading;
        item.errorMessage = null;
        _saveQueue();
        notifyListeners();

        final videoId = await YouTubeService().uploadVideo(
          videoFile: File(item.filePath),
          title: item.title,
          description: item.description,
          tags: item.tags,
          privacyStatus: 'private',
          onProgress: (progress) {
            item.progress = progress;
            notifyListeners(); // Don't save queue on every progress tick to avoid excessive disk I/O
          },
        );

        item.videoId = videoId;
        item.status = UploadStatus.processing;
        _saveQueue();
        notifyListeners();
        
        // Start polling for processing status without blocking the queue completely if possible, 
        // but since we process sequentially, we'll await it or do it async. 
        // Let's do it asynchronously so the next upload can start.
        _pollProcessingStatus(item);

      } catch (e) {
        item.status = UploadStatus.failed;
        item.errorMessage = e.toString();
        _saveQueue();
        notifyListeners();
      }
    }

    _isProcessing = false;
  }

  Future<void> _pollProcessingStatus(UploadItem item) async {
    if (item.videoId == null) return;
    
    bool isComplete = false;
    int attempts = 0;
    
    // Poll up to 60 times, once every 10 seconds (10 mins max)
    while (!isComplete && attempts < 60) {
      await Future.delayed(const Duration(seconds: 10));
      isComplete = await YouTubeService().isVideoProcessingComplete(item.videoId!);
      attempts++;
    }
    
    item.status = UploadStatus.success;
    _saveQueue();
    notifyListeners();
  }
}
