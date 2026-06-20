import 'dart:io';

import 'package:flutter/services.dart';

class AudioExtractor {
  static const MethodChannel _channel = MethodChannel(
    'readbloom/audio_extractor',
  );

  static Future<File> extractFromVideo(String videoPath) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'Recorded-video audio extraction is currently available on Android.',
      );
    }

    final outputPath = '$videoPath.transcription.m4a';
    final extractedPath = await _channel.invokeMethod<String>('extractAudio', {
      'videoPath': videoPath,
      'outputPath': outputPath,
    });
    if (extractedPath == null || extractedPath.isEmpty) {
      throw StateError('Audio extraction did not return an output file.');
    }

    final audioFile = File(extractedPath);
    if (!await audioFile.exists() || await audioFile.length() == 0) {
      throw StateError('The extracted audio file is empty.');
    }
    return audioFile;
  }
}
