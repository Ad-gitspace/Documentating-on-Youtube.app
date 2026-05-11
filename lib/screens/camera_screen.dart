import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isRecording = false;
  bool _isPaused = false;
  int _selectedCameraIndex = 0;
  
  // Flash & Zoom
  FlashMode _flashMode = FlashMode.off;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request permissions
    await [Permission.camera, Permission.microphone].request();

    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _setCamera(_selectedCameraIndex);
    } else {
      // Handle no camera found
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera found on this device.')),
        );
      }
    }
  }

  Future<void> _setCamera(int index) async {
    if (_cameras.isEmpty || index < 0 || index >= _cameras.length) return;
    
    // Dispose the old controller if it exists and we're switching
    if (_controller != null) {
      await _controller!.dispose();
    }

    final CameraController newController = CameraController(
      _cameras[index],
      ResolutionPreset.max, // High quality as original
      enableAudio: true,
    );

    _controller = newController;

    try {
      await newController.initialize();
      _maxZoom = await newController.getMaxZoomLevel();
      _minZoom = await newController.getMinZoomLevel();
      _currentZoom = _minZoom;
      _baseZoom = _currentZoom;
      await newController.setFlashMode(_flashMode);
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    
    FlashMode nextMode;
    if (_flashMode == FlashMode.off) {
      nextMode = FlashMode.torch;
    } else if (_flashMode == FlashMode.torch) {
      nextMode = FlashMode.auto;
    } else {
      nextMode = FlashMode.off;
    }

    try {
      await _controller!.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
    } catch (e) {
      debugPrint("Error toggling flash: $e");
    }
  }

  void _switchCamera() {
    if (_cameras.length < 2 || _isRecording) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _setCamera(_selectedCameraIndex);
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isRecording) return;

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _isPaused = false;
      });
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  Future<void> _pauseRecording() async {
    if (_controller == null || !_isRecording || _isPaused) return;

    try {
      await _controller!.pauseVideoRecording();
      setState(() {
        _isPaused = true;
      });
    } catch (e) {
      debugPrint("Error pausing record: $e");
    }
  }

  Future<void> _resumeRecording() async {
    if (_controller == null || !_isRecording || !_isPaused) return;

    try {
      await _controller!.resumeVideoRecording();
      setState(() {
        _isPaused = false;
      });
    } catch (e) {
      debugPrint("Error resuming record: $e");
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_isRecording) return;

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isPaused = false;
      });

      if (mounted) {
        Navigator.pop(context, {'path': videoFile.path});
      }
    } catch (e) {
      debugPrint("Error stopping record: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.torch:
        return Icons.flash_on;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.off:
      default:
        return Icons.flash_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (details) {
                  _baseZoom = _currentZoom;
                },
                onScaleUpdate: (details) async {
                  if (_controller == null) return;
                  double zoom = _baseZoom * details.scale;
                  zoom = zoom.clamp(_minZoom, _maxZoom);
                  setState(() {
                    _currentZoom = zoom;
                  });
                  await _controller!.setZoomLevel(zoom);
                },
                child: CameraPreview(_controller!),
              ),
            ),
            
            // Top Controls (Flash, Switch Camera)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () {
                      if (_isRecording) {
                        _stopRecording();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_getFlashIcon(), color: Colors.white, size: 28),
                        onPressed: _toggleFlash,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
                        onPressed: _switchCamera,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Zoom Slider Indicator
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height * 0.3,
              bottom: MediaQuery.of(context).size.height * 0.3,
              child: RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  value: _currentZoom,
                  min: _minZoom,
                  max: _maxZoom,
                  activeColor: AppColors.primary,
                  inactiveColor: Colors.white30,
                  onChanged: (value) async {
                    setState(() {
                      _currentZoom = value;
                    });
                    await _controller!.setZoomLevel(value);
                  },
                ),
              ),
            ),

            // Bottom Controls (Record, Pause/Resume)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pause / Resume Button
                  if (_isRecording)
                    GestureDetector(
                      onTap: _isPaused ? _resumeRecording : _pauseRecording,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPaused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 64), // Spacer

                  // Main Record / Stop Button
                  GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: _isRecording ? 30 : 60,
                          width: _isRecording ? 30 : 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(_isRecording ? 8 : 30),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 64), // Spacer for symmetry
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
