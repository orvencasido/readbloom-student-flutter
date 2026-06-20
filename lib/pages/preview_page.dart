import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_mobile/models/reading_book.dart';
import 'package:student_mobile/models/reading_session.dart';
import 'package:student_mobile/pages/quiz_page.dart';
import 'package:student_mobile/pages/reading_page.dart';
import 'package:student_mobile/services/audio_extractor.dart';
import 'package:student_mobile/services/student_repository.dart';
import 'package:video_player/video_player.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({super.key, required this.book, required this.session});

  final ReadingBook book;
  final ReadingSession session;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final StudentRepository _studentRepository = StudentRepository();
  late final VideoPlayerController _video;
  late ReadingSession _session;
  bool _ready = false;
  bool _leaving = false;
  bool _transcribing = true;
  String? _transcriptionError;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _video = VideoPlayerController.file(File(widget.session.videoPath))
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      });
    _transcribeRecording();
  }

  Future<void> _transcribeRecording() async {
    if (_leaving) return;
    if (mounted) {
      setState(() {
        _transcribing = true;
        _transcriptionError = null;
      });
    }

    File? audioFile;
    String? remoteAudioPath;
    String? transcript;
    Object? transcriptionError;
    try {
      _session = await _studentRepository.uploadReadingRecording(
        bookId: widget.book.id,
        session: _session,
      );
      if (_leaving) {
        await _studentRepository.deleteReadingRecording(_session);
        return;
      }
      audioFile = await AudioExtractor.extractFromVideo(_session.videoPath);
      if (_leaving) return;

      remoteAudioPath = await _studentRepository.uploadTranscriptionAudio(
        bookId: widget.book.id,
        audioFile: audioFile,
      );
      if (_leaving) return;

      transcript = await _studentRepository.transcribeReadingAudio(
        remoteAudioPath,
      );
    } catch (error) {
      transcriptionError = error;
    } finally {
      if (remoteAudioPath != null) {
        try {
          await _studentRepository.deleteTranscriptionAudio(remoteAudioPath);
        } catch (_) {
          // The Edge Function may already have removed the temporary object.
        }
      }
      try {
        if (audioFile != null && await audioFile.exists()) {
          await audioFile.delete();
        }
      } catch (_) {
        // Temporary local files can also be removed by OS cache cleanup.
      }
    }

    if (!mounted || _leaving) return;
    setState(() {
      if (transcriptionError == null) {
        _session = _session.copyWith(transcript: transcript ?? '');
      } else {
        _transcriptionError = transcriptionError.toString();
      }
      _transcribing = false;
    });
  }

  Future<void> _startOver() async {
    if (_leaving) return;
    setState(() => _leaving = true);
    await _video.pause();
    try {
      await _studentRepository.deleteReadingRecording(_session);
    } catch (_) {
      // A failed cleanup must not trap the learner on the preview screen.
    }
    await _session.discard();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReadingPage(book: widget.book)),
    );
  }

  void _continueToQuiz() {
    if (_leaving) return;
    _leaving = true;
    _video.pause();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(book: widget.book, session: _session),
      ),
    );
  }

  @override
  void dispose() {
    _video.dispose();
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
            colors: [Color(0xFFFFF6A3), Color(0xFFF48FE1)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  'Preview your Video',
                  style: GoogleFonts.quicksand(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _ready
                      ? AspectRatio(
                          aspectRatio: _video.value.aspectRatio,
                          child: VideoPlayer(_video),
                        )
                      : const AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                ),
                if (_ready) ...[
                  VideoProgressIndicator(
                    _video,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Rewind 10 seconds',
                        onPressed: () {
                          final target =
                              _video.value.position -
                              const Duration(seconds: 10);
                          _video.seekTo(
                            target.isNegative ? Duration.zero : target,
                          );
                        },
                        icon: const Icon(Icons.replay_10_rounded),
                      ),
                      IconButton(
                        tooltip: _video.value.isPlaying ? 'Pause' : 'Play',
                        onPressed: () => setState(() {
                          _video.value.isPlaying
                              ? _video.pause()
                              : _video.play();
                        }),
                        icon: Icon(
                          _video.value.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _transcribing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Extracting and transcribing audio…'),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _transcriptionError != null
                                  ? 'Could not transcribe the recording.\n$_transcriptionError'
                                  : _session.transcript.isEmpty
                                  ? 'No speech was found in the recorded video.'
                                  : 'Transcript\n${_session.transcript}',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_transcriptionError != null) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _transcribeRecording,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry transcription'),
                              ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 14,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _leaving ? null : _startOver,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Start Over'),
                    ),
                    ElevatedButton.icon(
                      onPressed:
                          _leaving ||
                              _transcribing ||
                              _session.transcript.isEmpty
                          ? null
                          : _continueToQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text("I'm Done"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
