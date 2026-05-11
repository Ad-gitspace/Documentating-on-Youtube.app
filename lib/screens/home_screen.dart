import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/youtube_service.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final YouTubeService _youtubeService = YouTubeService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    await _authService.init();
    setState(() {});
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    await _authService.signIn();
    setState(() => _isLoading = false);
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    await _authService.signOut();
    setState(() => _isLoading = false);
  }

  Future<void> _recordVideo() async {
    final String? videoPath = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );

    if (videoPath != null) {
      await _uploadVideo(videoPath);
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      await _uploadVideo(video.path);
    }
  }

  Future<void> _uploadVideo(String filePath) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Uploading to YouTube...';
    });

    try {
      final title = "Daily Vlog - ${DateTime.now().toIso8601String().split('T').first}";
      final videoId = await _youtubeService.uploadVideo(
        videoFile: File(filePath),
        title: title,
        privacyStatus: 'private', // Upload as private for MVP
      );

      setState(() {
        _statusMessage = 'Success! Video ID: $videoId';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Upload failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Premium Dark Mode
      appBar: AppBar(
        title: const Text('SaveMoments', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      user != null ? Icons.check_circle : Icons.account_circle,
                      size: 64,
                      color: user != null ? Colors.greenAccent : Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user != null ? 'Logged in as\n${user.email}' : 'Not Authenticated',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user != null ? Colors.redAccent : Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading ? null : (user != null ? _handleSignOut : _handleSignIn),
                      child: Text(user != null ? 'Sign Out' : 'Sign In with Google'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Action Buttons
              if (user != null) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.videocam, size: 28),
                  label: const Text('Record Moment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: _isLoading ? null : _recordVideo,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.photo_library, color: Colors.white70),
                  label: const Text('Pick from Gallery', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  onPressed: _isLoading ? null : _pickVideoFromGallery,
                ),
              ],

              const SizedBox(height: 40),

              // Status indicator
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.redAccent))
              else if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _statusMessage.contains('Success') ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _statusMessage.contains('Success') ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
