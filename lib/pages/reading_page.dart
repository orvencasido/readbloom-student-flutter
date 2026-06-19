import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:student_mobile/models/reading_book.dart';
import 'package:student_mobile/models/reading_session.dart';
import 'package:student_mobile/pages/preview_page.dart';

class ReadingPage extends StatefulWidget {
  const ReadingPage({super.key, required this.book});

  final ReadingBook book;

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  final SpeechToText _speech = SpeechToText();
  final Stopwatch _stopwatch = Stopwatch();
  CameraController? _camera;
  String _transcript = '';
  final List<String> _transcriptSegments = [];
  String? _error;
  bool _preparing = true;
  bool _recording = false;
  bool _finishing = false;
  bool _handedOff = false;
  bool _restartScheduled = false;

  @override
  void initState() {
    super.initState();
    _prepareAndRecord();
  }

  Future<void> _prepareAndRecord() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw StateError('No camera is available.');
      final selected =
          cameras.cast<CameraDescription?>().firstWhere(
            (camera) => camera?.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          ) ??
          cameras.first;

      final camera = CameraController(
        selected,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      _camera = camera;
      await camera.initialize();

      final speechReady = await _speech.initialize(
        onStatus: (status) {
          if (status == SpeechToText.doneStatus ||
              status == SpeechToText.notListeningStatus) {
            _restartSpeechAfterPause();
          }
        },
        onError: (error) {
          if (mounted && !_finishing) {
            setState(() => _error = 'Speech recognition: ${error.errorMsg}');
          }
        },
      );
      if (!speechReady) {
        throw StateError(
          'Microphone or speech-recognition permission was denied.',
        );
      }

      await camera.startVideoRecording();
      _recording = true;
      await _startListening();
      _stopwatch.start();
      if (mounted) {
        setState(() {
          _preparing = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _preparing = false;
          _error = error.toString().replaceFirst('Bad state: ', '');
        });
      }
    }
  }

  Future<void> _startListening() async {
    if (_finishing || !_recording || _speech.isListening) return;
    await _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords.trim();
        if (result.finalResult && words.isNotEmpty) {
          _transcriptSegments.add(words);
        }
        if (mounted) {
          setState(() {
            _transcript = [
              ..._transcriptSegments,
              if (!result.finalResult && words.isNotEmpty) words,
            ].join(' ').trim();
          });
        }
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  void _restartSpeechAfterPause() {
    if (!_recording || _finishing || _restartScheduled) return;
    _restartScheduled = true;
    Future<void>.delayed(const Duration(milliseconds: 250), () async {
      _restartScheduled = false;
      if (_recording && !_finishing) await _startListening();
    });
  }

  Future<void> _finish() async {
    final camera = _camera;
    if (camera == null || !camera.value.isRecordingVideo || _finishing) return;
    setState(() => _finishing = true);
    try {
      _stopwatch.stop();
      await _speech.stop();
      final video = await camera.stopVideoRecording();
      final session = ReadingSession(
        videoPath: video.path,
        transcript: _transcript.trim(),
        duration: _stopwatch.elapsed,
      );
      _handedOff = true;
      if (!mounted) {
        await session.discard();
        return;
      }
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewPage(book: widget.book, session: session),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _finishing = false;
          _error = 'Could not finish recording: $error';
        });
      }
    }
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _speech.cancel();
    final camera = _camera;
    if (!_handedOff && camera?.value.isRecordingVideo == true) {
      camera!
          .stopVideoRecording()
          .then<void>((file) async {
            await File(file.path).delete();
          })
          .catchError((_) {});
    }
    camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF6A3), Color(0xFFF48FE1)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 180,
                  height: 180,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: _camera?.value.isInitialized == true
                      ? CameraPreview(_camera!)
                      : const Center(child: CircularProgressIndicator()),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fiber_manual_record,
                      color: _recording ? Colors.red : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _preparing
                          ? 'Preparing camera and microphone…'
                          : _recording
                          ? 'Recording and transcribing'
                          : 'Not recording',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF66BB6A),
                      width: 2.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.book.title.toUpperCase(),
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.book.passage,
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      if (_transcript.isNotEmpty) ...[
                        const Divider(height: 32),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Live transcript: $_transcript',
                            style: GoogleFonts.quicksand(color: Colors.black54),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _recording && !_finishing ? _finish : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A70FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42,
                      vertical: 14,
                    ),
                  ),
                  child: _finishing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "I'm Done",
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
