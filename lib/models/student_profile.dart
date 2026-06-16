class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.section,
    required this.yearLevel,
    required this.privacyAgreedAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String section;
  final String yearLevel;
  final DateTime? privacyAgreedAt;

  bool get hasAcceptedPrivacyAgreement => privacyAgreedAt != null;

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    final rawPrivacyAgreedAt = map['privacy_agreed_at'];

    return StudentProfile(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      section: map['section'] as String? ?? '',
      yearLevel: map['year_level'] as String? ?? '',
      privacyAgreedAt: rawPrivacyAgreedAt is String
          ? DateTime.tryParse(rawPrivacyAgreedAt)
          : null,
    );
  }
}
