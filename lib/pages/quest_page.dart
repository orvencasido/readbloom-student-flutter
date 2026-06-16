import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:student_mobile/models/reading_book.dart';
import 'package:student_mobile/pages/reading_page.dart';

class QuestPage extends StatefulWidget {
  const QuestPage({super.key, required this.book});

  final ReadingBook book;

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _hasCameraError = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _hasCameraError = true;
        });
        return;
      }

      // Find the front-facing camera
      CameraDescription? frontCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      // Fallback to first camera if front camera is not found
      final selectedCamera = frontCamera ?? cameras.first;

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera Initialization Error: $e');
      if (mounted) {
        setState(() {
          _hasCameraError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF6A3), // Pastel yellow
              Color(0xFFF48FE1), // Pastel pink/magenta
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back Button top left
              Positioned(
                top: 12,
                left: 12,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),

              // Main content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Section: Camera View and Voice bar
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Camera Preview Box
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.black,
                                width: 3.0,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.15),
                                  blurRadius: 8,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: _buildCameraWidget(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Voice Indicator Waveform row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.mic_rounded,
                                color: Color(0xFF00E676), // Green mic
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              // Waveform pills (blue and green as mockup)
                              _buildWaveformPill(const Color(0xFF42A5F5)),
                              _buildWaveformPill(const Color(0xFF42A5F5)),
                              _buildWaveformPill(const Color(0xFF42A5F5)),
                              _buildWaveformPill(const Color(0xFF42A5F5)),
                              _buildWaveformPill(const Color(0xFFCCFF90)),
                              _buildWaveformPill(const Color(0xFFCCFF90)),
                              _buildWaveformPill(const Color(0xFFCCFF90)),
                              _buildWaveformPill(const Color(0xFFCCFF90)),
                              _buildWaveformPill(const Color(0xFFCCFF90)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),

                      // Right Section: Start Button & reading duration
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Capsule Start Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color.fromRGBO(0, 0, 0, 0.08),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromRGBO(0, 0, 0, 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ReadingPage(book: widget.book),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                color: Color(0xFF00E676), // Green play icon
                                size: 30,
                              ),
                              label: Text(
                                'START',
                                style: GoogleFonts.quicksand(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtitle duration description
                          Text(
                            '${widget.book.estimatedMinutesToRead} minutes to read',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to construct the waveform pill indicators
  Widget _buildWaveformPill(Color color) {
    return Container(
      width: 8,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Camera preview builder that renders real feed or mock avatar gracefully
  Widget _buildCameraWidget() {
    if (_hasCameraError) {
      // Fallback avatar when camera fails (e.g. simulator)
      return Image.asset('assets/icons/kai.png', fit: BoxFit.cover);
    }

    if (_isCameraInitialized && _cameraController != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: 200,
          height: 200 * _cameraController!.value.aspectRatio,
          child: CameraPreview(_cameraController!),
        ),
      );
    }

    // Loader while camera is startup initializing
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFF48FE1)),
    );
  }
}
