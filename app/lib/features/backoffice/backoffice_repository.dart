import 'dart:convert';

import 'package:http/http.dart' as http;

/// Schnittstelle für das capability-geschützte Backoffice.
///
/// Der Client blendet Tabs zusätzlich aus, aber jede API-Antwort wird auf dem
/// Server autorisiert. Zahlungsreferenzen und personenbezogene Daten werden
/// von diesen DTOs bewusst nicht abgebildet.
class BackofficeRepository {
  const BackofficeRepository(this.csrfToken);

  final String csrfToken;

  Future<BackofficeOverview> loadOverview() async {
    final json = await _get('api/backoffice/overview');
    return BackofficeOverview.fromJson(json);
  }

  Future<List<BackofficeTransaction>> loadTransactions() async {
    final json = await _get('api/backoffice/billing/transactions');
    return (json['transactions'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(BackofficeTransaction.fromJson)
        .toList(growable: false);
  }

  Future<List<ModerationCase>> loadCases() async {
    final json = await _get('api/backoffice/moderation/cases');
    return (json['cases'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(ModerationCase.fromJson)
        .toList(growable: false);
  }

  Future<void> createCase({
    required String category,
    required String description,
    required String priority,
  }) async {
    await _write('api/backoffice/moderation/cases', 'POST', {
      'subject_type': 'content',
      'category': category,
      'description': description,
      'priority': priority,
    });
  }

  Future<void> updateCase({
    required String id,
    required String status,
    String resolution = '',
  }) => _write('api/backoffice/moderation/cases/$id', 'PATCH', {
    'status': status,
    'resolution': resolution,
  });

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await http.get(Uri.base.resolve(path));
    if (response.statusCode != 200) throw const BackofficeApiException();
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> _write(
    String path,
    String method,
    Map<String, dynamic> body,
  ) async {
    final request = http.Request(method, Uri.base.resolve(path))
      ..headers.addAll({
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      })
      ..body = jsonEncode(body);
    final response = await request.send();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const BackofficeApiException();
    }
  }
}

class BackofficeOverview {
  const BackofficeOverview({required this.role, required this.metrics});
  final String role;
  final Map<String, int> metrics;

  factory BackofficeOverview.fromJson(Map<String, dynamic> json) {
    final raw = json['metrics'] as Map<String, dynamic>;
    return BackofficeOverview(
      role: json['role'] as String,
      metrics: raw.map((key, value) => MapEntry(key, value as int)),
    );
  }
}

class BackofficeTransaction {
  const BackofficeTransaction({
    required this.plan,
    required this.mode,
    required this.kind,
    required this.status,
    required this.amountCents,
    required this.currency,
    required this.occurredAt,
  });
  final String? plan;
  final String mode;
  final String kind;
  final String status;
  final int amountCents;
  final String currency;
  final String occurredAt;

  factory BackofficeTransaction.fromJson(Map<String, dynamic> json) =>
      BackofficeTransaction(
        plan: json['plan'] as String?,
        mode: json['mode'] as String,
        kind: json['kind'] as String,
        status: json['status'] as String,
        amountCents: json['amount_cents'] as int,
        currency: json['currency'] as String,
        occurredAt: json['occurred_at'] as String,
      );
}

class ModerationCase {
  const ModerationCase({
    required this.id,
    required this.category,
    required this.priority,
    required this.status,
    required this.description,
    required this.resolution,
  });
  final String id;
  final String category;
  final String priority;
  final String status;
  final String description;
  final String resolution;

  factory ModerationCase.fromJson(Map<String, dynamic> json) => ModerationCase(
    id: json['id'] as String,
    category: json['category'] as String,
    priority: json['priority'] as String,
    status: json['status'] as String,
    description: json['description'] as String,
    resolution: json['resolution'] as String,
  );
}

class BackofficeApiException implements Exception {
  const BackofficeApiException();
}
