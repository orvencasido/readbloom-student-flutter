import 'package:flutter/material.dart';
import 'package:student_mobile/models/student_profile.dart';
import 'package:student_mobile/pages/agreement_page.dart';
import 'package:student_mobile/pages/home_page.dart';
import 'package:student_mobile/pages/login_page.dart';
import 'package:student_mobile/services/student_repository.dart';
import 'package:student_mobile/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final StudentRepository _studentRepository = StudentRepository();
  late Future<StudentProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<StudentProfile?> _loadProfile() async {
    if (!SupabaseConfig.isConfigured) return null;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    return _studentRepository.fetchCurrentProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF48FE1)),
            ),
          );
        }

        final profile = snapshot.data;
        if (profile == null) {
          return const LoginPage();
        }

        if (profile.hasAcceptedPrivacyAgreement) {
          return const HomePage();
        }

        return const AgreementPage();
      },
    );
  }
}
