import 'dart:io';

class ReadingSession {
  const ReadingSession({
    required this.videoPath,
    required this.transcript,
    required this.duration,
  });

  final String videoPath;
  final String transcript;
  final Duration duration;

  File get videoFile => File(videoPath);

  Future<void> discard() async {
    final file = videoFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
