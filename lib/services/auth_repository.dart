import 'package:student_mobile/services/book_repository.dart';
import 'package:student_mobile/services/student_repository.dart';
import 'package:student_mobile/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository({SupabaseClient? client})
    : _client = client,
      _studentRepository = StudentRepository(client: client);

  final SupabaseClient? _client;
  final StudentRepository _studentRepository;

  SupabaseClient get _supabase {
    if (!SupabaseConfig.isConfigured) {
      throw const SupabaseNotConfiguredException();
    }

    return _client ?? Supabase.instance.client;
  }

  User? get currentUser => SupabaseConfig.isConfigured
      ? (_client ?? Supabase.instance.client).auth.currentUser
      : null;

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    required String section,
    required String yearLevel,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'section': section,
        'year_level': yearLevel,
      },
    );

    if (response.session == null) {
      return false;
    }

    await _studentRepository.fetchCurrentProgress();
    return true;
  }

  Future<bool> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);

    await _studentRepository.fetchCurrentProgress();
    final profile = await _studentRepository.fetchCurrentProfile();
    return profile.hasAcceptedPrivacyAgreement;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
