import 'dart:convert';

import 'package:http/http.dart' as http;

import '../onboarding/brand_asset_picker_types.dart';

class ProjectSummary {
  const ProjectSummary({
    required this.id,
    required this.name,
    required this.company,
    required this.fontFamily,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? company;
  final String fontFamily;
  final DateTime createdAt;

  factory ProjectSummary.fromJson(Map<String, dynamic> json) => ProjectSummary(
    id: json['id'] as String,
    name: json['name'] as String,
    company: json['company'] as String?,
    fontFamily: json['font_family'] as String? ?? 'Open Sans',
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.kind,
    required this.mimeType,
    required this.byteSize,
    required this.contentUrl,
  });

  final String id;
  final String kind;
  final String mimeType;
  final int byteSize;
  final String contentUrl;

  factory MediaAsset.fromJson(Map<String, dynamic> json) => MediaAsset(
    id: json['id'] as String,
    kind: json['kind'] as String,
    mimeType: json['mime_type'] as String,
    byteSize: json['byte_size'] as int,
    contentUrl: json['content_url'] as String,
  );
}

class ProjectRepository {
  const ProjectRepository(this.csrfToken);

  final String csrfToken;

  Future<List<ProjectSummary>> list() async {
    final response = await http.get(Uri.base.resolve('api/projects'));
    if (response.statusCode != 200) throw const ProjectApiException();
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['projects'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ProjectSummary.fromJson)
        .toList(growable: false);
  }

  Future<ProjectSummary> create({
    required String name,
    required String company,
    required String description,
    required String fontFamily,
  }) async {
    final response = await http.post(
      Uri.base.resolve('api/projects'),
      headers: {'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken},
      body: jsonEncode({
        'name': name,
        'company': company,
        'description': description,
        'font_family': fontFamily,
      }),
    );
    if (response.statusCode != 201) throw const ProjectApiException();
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ProjectSummary.fromJson(body['project'] as Map<String, dynamic>);
  }

  /// Lädt ausschließlich über die Same-Origin-Session und den CSRF-Schutz hoch.
  /// Der Browser erhält nie einen direkten Storage-Pfad oder einen Zugangsschlüssel.
  Future<void> uploadAsset({
    required String projectId,
    required BrandAssetKind kind,
    required BrandAssetSelection selection,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.base.resolve('api/projects/$projectId/media'),
    )
      ..headers['X-CSRF-Token'] = csrfToken
      ..fields['kind'] = switch (kind) {
        BrandAssetKind.logo => 'logo',
        BrandAssetKind.referenceImage => 'reference_image',
      }
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        selection.bytes,
        filename: selection.name,
      ));
    final response = await request.send();
    if (response.statusCode != 201) throw const ProjectApiException();
  }

  Future<List<MediaAsset>> listAssets(String projectId) async {
    final response = await http.get(Uri.base.resolve('api/projects/$projectId/media'));
    if (response.statusCode != 200) throw const ProjectApiException();
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['assets'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(MediaAsset.fromJson)
        .toList(growable: false);
  }

  Future<void> deleteAsset(String projectId, String assetId) async {
    final response = await http.delete(
      Uri.base.resolve('api/projects/$projectId/media/$assetId'),
      headers: {'X-CSRF-Token': csrfToken},
    );
    if (response.statusCode != 204) throw const ProjectApiException();
  }
}

class ProjectApiException implements Exception {
  const ProjectApiException();
}
