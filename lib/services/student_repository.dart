import 'dart:io';

import 'package:student_mobile/models/student_profile.dart';
import 'package:student_mobile/models/student_progress.dart';
import 'package:student_mobile/models/reading_session.dart';
import 'package:student_mobile/services/book_repository.dart';
import 'package:student_mobile/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRepository {
  static const _maximumTranscriptionBytes = 25 * 1024 * 1024;

  StudentRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _supabase {
    if (!SupabaseConfig.isConfigured) {
      throw const SupabaseNotConfiguredException();
    }

    return _client ?? Supabase.instance.client;
  }

  String get _currentUserId {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('No authenticated user.');
    }

    return userId;
  }

  Future<StudentProfile> fetchCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user.');
    }

    final row = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (row != null) {
      return StudentProfile.fromMap(row);
    }

    final metadata = user.userMetadata ?? {};
    final profileRow = {
      'id': user.id,
      'full_name': metadata['full_name']?.toString() ?? '',
      'email': user.email ?? '',
      'section': metadata['section']?.toString() ?? '',
      'year_level': metadata['year_level']?.toString() ?? '',
    };

    await _supabase.from('profiles').insert(profileRow);

    return StudentProfile.fromMap(profileRow);
  }

  Future<StudentProgress> fetchCurrentProgress() async {
    final userId = _currentUserId;
    final row = await _supabase
        .from('student_progress')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (row != null) {
      return StudentProgress.fromMap(row);
    }

    await _supabase.from('student_progress').insert({
      'user_id': userId,
      'books_completed': 0,
      'days_streak': 0,
      'reading_level': 1,
      'fluency_level': 1,
      'comprehension_level': 1,
    });

    return StudentProgress(userId: userId, booksCompleted: 0, daysStreak: 0);
  }

  Future<void> acceptPrivacyAgreement() async {
    await _supabase
        .from('profiles')
        .update({'privacy_agreed_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', _currentUserId);
  }

  Future<Set<String>> fetchCompletedBookIds() async {
    final rows = await _supabase
        .from('completed_books')
        .select('book_id')
        .eq('user_id', _currentUserId);
    return rows.map((row) => row['book_id'] as String).toSet();
  }

  Future<void> submitReading({
    required String bookId,
    required ReadingSession session,
    required List<int> answers,
  }) async {
    final uploadedSession = session.remoteVideoPath == null
        ? await uploadReadingRecording(bookId: bookId, session: session)
        : session;
    final objectPath = uploadedSession.remoteVideoPath!;

    await _supabase.rpc(
      'finalize_reading_submission',
      params: {
        'p_book_id': bookId,
        'p_video_path': objectPath,
        'p_transcript': uploadedSession.transcript,
        'p_duration_seconds': uploadedSession.duration.inSeconds,
        'p_answers': answers,
      },
    );
  }

  Future<ReadingSession> uploadReadingRecording({
    required String bookId,
    required ReadingSession session,
  }) async {
    if (session.remoteVideoPath != null) return session;

    final extension = session.videoPath.toLowerCase().endsWith('.mov')
        ? 'mov'
        : 'mp4';
    final objectPath =
        '$_currentUserId/$bookId/${DateTime.now().toUtc().millisecondsSinceEpoch}.$extension';

    await _supabase.storage
        .from('reading-recordings')
        .upload(
          objectPath,
          session.videoFile,
          fileOptions: const FileOptions(upsert: false),
        );
    return session.copyWith(remoteVideoPath: objectPath);
  }

  Future<String> uploadTranscriptionAudio({
    required String bookId,
    required File audioFile,
  }) async {
    if (await audioFile.length() > _maximumTranscriptionBytes) {
      throw StateError(
        'The extracted audio exceeds the 25 MB transcription limit.',
      );
    }
    final objectPath =
        '$_currentUserId/$bookId/${DateTime.now().toUtc().millisecondsSinceEpoch}.m4a';
    await _supabase.storage
        .from('transcription-audio')
        .upload(
          objectPath,
          audioFile,
          fileOptions: const FileOptions(
            upsert: false,
            contentType: 'audio/mp4',
          ),
        );
    return objectPath;
  }

  Future<String> transcribeReadingAudio(String audioPath) async {
    final response = await _supabase.functions.invoke(
      'transcribe-recording',
      body: {'audioPath': audioPath},
    );
    final data = response.data;
    if (data is! Map || data['transcript'] is! String) {
      throw StateError('The transcription service returned an invalid result.');
    }
    return (data['transcript'] as String).trim();
  }

  Future<void> deleteTranscriptionAudio(String audioPath) async {
    await _supabase.storage.from('transcription-audio').remove([audioPath]);
  }

  Future<void> deleteReadingRecording(ReadingSession session) async {
    final objectPath = session.remoteVideoPath;
    if (objectPath != null) {
      await _supabase.storage.from('reading-recordings').remove([objectPath]);
    }
  }
}
