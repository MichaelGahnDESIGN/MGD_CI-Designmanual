import 'dart:convert';

import 'package:http/http.dart' as http;

/// Serverseitig berechnete Profil- und Nutzungsdaten.
///
/// Slots und Speicher werden nicht im Flutter-Client abgeleitet: Nur die API
/// kennt aktive Entitlements und ist damit die verbindliche Instanz.
class AccountProfile {
  const AccountProfile({
    required this.username,
    required this.email,
    required this.planLabel,
    required this.projectsUsed,
    required this.projectsTotal,
    required this.storageUsedBytes,
    required this.storageTotalBytes,
    required this.roles,
    required this.capabilities,
  });

  final String username;
  final String email;
  final String planLabel;
  final int projectsUsed;
  final int projectsTotal;
  final int storageUsedBytes;
  final int storageTotalBytes;
  final List<String> roles;
  final List<String> capabilities;

  bool get canOpenBackoffice => capabilities.contains('backoffice.access');
  bool get canReadBilling => capabilities.contains('billing.read');
  bool get canManageModeration =>
      capabilities.contains('moderation.case.manage');

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final plan = json['plan'] as Map<String, dynamic>;
    return AccountProfile(
      username: user['username'] as String,
      email: user['email'] as String,
      planLabel: plan['label'] as String,
      projectsUsed: plan['projects_used'] as int,
      projectsTotal: plan['projects_total'] as int,
      storageUsedBytes: plan['storage_used_bytes'] as int,
      storageTotalBytes: plan['storage_total_bytes'] as int,
      roles: (user['roles'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      capabilities: (user['capabilities'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }
}

class AccountRepository {
  const AccountRepository();

  Future<AccountProfile> loadProfile() async {
    final response = await http.get(Uri.base.resolve('api/auth/me'));
    if (response.statusCode != 200) throw const AccountApiException();
    return AccountProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

class AccountApiException implements Exception {
  const AccountApiException();
}
