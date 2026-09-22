import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'account_repository.dart';
import '../billing/upgrade_offer_sheet.dart';

/// Selbstständiger Bereich für persönliche Sicherheitseinstellungen.
///
/// Die Kontolöschung fragt Kennwort und das eindeutige Wort DELETE ab. Die
/// tatsächliche Berechtigungsprüfung bleibt ausschließlich beim Backend.
class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
    required this.csrfToken,
    required this.onChangePassword,
  });

  final String csrfToken;
  final VoidCallback onChangePassword;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _deleting = false;
  late final AccountRepository _repository;
  AccountProfile? _profile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _repository = const AccountRepository();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.loadProfile();
      if (mounted) setState(() => _profile = profile);
    } on AccountApiException {
      // Die Sicherheitsaktionen bleiben auch bei einem temporären Profilfehler
      // erreichbar; wir zeigen keine technischen Backenddetails an.
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _confirmDeletion() async {
    final password = TextEditingController();
    final confirmation = TextEditingController();
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konto endgültig löschen?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Projekte und private Medien werden unwiderruflich gelöscht.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Kennwort'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmation,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Zur Bestätigung DELETE eingeben',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(
              context,
              password.text.isNotEmpty && confirmation.text == 'DELETE',
            ),
            child: const Text('Endgültig löschen'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      final response = await http.post(
        Uri.base.resolve('api/auth/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': widget.csrfToken,
        },
        body: jsonEncode({
          'password': password.text,
          'confirmation': confirmation.text,
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 204) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konto konnte nicht gelöscht werden.')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Der Dienst ist gerade nicht erreichbar.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Konto & Sicherheit',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 10),
      const Text('Verwalte dein Kennwort und deine persönlichen Daten.'),
      const SizedBox(height: 28),
      if (_loadingProfile)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (_profile != null) ...[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _profile!.username,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Chip(label: Text(_profile!.planLabel)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_profile!.email),
                const SizedBox(height: 16),
                Text(
                  '${_profile!.projectsUsed} von ${_profile!.projectsTotal} Projektslots genutzt',
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: _profile!.projectsTotal == 0
                      ? 1
                      : (_profile!.projectsUsed / _profile!.projectsTotal)
                            .clamp(0, 1)
                            .toDouble(),
                ),
                const SizedBox(height: 14),
                Text(
                  '${_formatMegabytes(_profile!.storageUsedBytes)} von ${_formatMegabytes(_profile!.storageTotalBytes)} privatem Medienspeicher genutzt',
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => UpgradeOfferSheet.show(context),
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: const Text('Tarife & Speicher ansehen'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      Card(
        child: ListTile(
          leading: const Icon(Icons.password_outlined),
          title: const Text('Kennwort ändern'),
          subtitle: const Text(
            'Aktuelles Kennwort bestätigen und neu festlegen.',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: widget.onChangePassword,
        ),
      ),
      const SizedBox(height: 24),
      Text('Gefahrenzone', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      const Text(
        'Beim Löschen werden dein Konto, alle Projekte und private Medien entfernt.',
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        key: const Key('account.delete'),
        onPressed: _deleting ? null : _confirmDeletion,
        icon: const Icon(Icons.delete_outline),
        label: Text(_deleting ? 'Konto wird gelöscht …' : 'Konto löschen'),
      ),
    ],
  );

  String _formatMegabytes(int bytes) =>
      '${(bytes / (1024 * 1024)).toStringAsFixed(bytes < 10 * 1024 * 1024 ? 1 : 0)} MB';
}
