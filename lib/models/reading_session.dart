import 'dart:io';

class ReadingSession {
  const ReadingSession({
    required this.videoPath,
    required this.transcript,
    required this.duration,
    this.remoteVideoPath,
  });

  final String videoPath;
  final String transcript;
  final Duration duration;
  final String? remoteVideoPath;

  ReadingSession copyWith({String? transcript, String? remoteVideoPath}) {
    return ReadingSession(
      videoPath: videoPath,
      transcript: transcript ?? this.transcript,
      duration: duration,
      remoteVideoPath: remoteVideoPath ?? this.remoteVideoPath,
    );
  }

  File get videoFile => File(videoPath);

  Future<void> discard() async {
    final file = videoFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
