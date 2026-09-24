import 'package:flutter/material.dart';

import '../account/account_repository.dart';
import 'backoffice_repository.dart';

/// Backoffice mit einer gemeinsamen Oberfläche für Admin und Moderation.
///
/// Sichtbare Tabs verbessern die Orientierung, sind aber nicht die
/// Berechtigungsgrenze: Jede Aktion wird von PHP gegen eine Capability geprüft.
class BackofficePage extends StatefulWidget {
  const BackofficePage({
    super.key,
    required this.csrfToken,
    required this.profile,
  });

  final String csrfToken;
  final AccountProfile profile;

  @override
  State<BackofficePage> createState() => _BackofficePageState();
}

class _BackofficePageState extends State<BackofficePage> {
  late final BackofficeRepository _repository;
  BackofficeOverview? _overview;
  List<BackofficeTransaction> _transactions = const [];
  List<ModerationCase> _cases = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = BackofficeRepository(widget.csrfToken);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final overview = await _repository.loadOverview();
      final cases = await _repository.loadCases();
      final transactions = widget.profile.canReadBilling
          ? await _repository.loadTransactions()
          : const <BackofficeTransaction>[];
      if (mounted) {
        setState(() {
          _overview = overview;
          _cases = cases;
          _transactions = transactions;
        });
      }
    } on BackofficeApiException {
      _error = 'Das Backoffice ist noch nicht bereit oder deine Rechte haben sich geändert.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createCase() async {
    final category = TextEditingController();
    final description = TextEditingController();
    String priority = 'normal';
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Moderationsfall anlegen'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: category,
                  maxLength: 64,
                  decoration: const InputDecoration(labelText: 'Kategorie'),
                ),
                TextField(
                  controller: description,
                  maxLength: 1000,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Sachverhalt (optional)',
                    helperText: 'Keine sensiblen Zahlungs- oder Zugangsdaten eintragen.',
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priorität'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Niedrig')),
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'high', child: Text('Hoch')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => priority = value ?? 'normal'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, category.text.trim().isNotEmpty),
              child: const Text('Fall anlegen'),
            ),
          ],
        ),
      ),
    );
    if (submit != true) return;
    try {
      await _repository.createCase(
        category: category.text.trim(),
        description: description.text.trim(),
        priority: priority,
      );
      await _load();
    } on BackofficeApiException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fall konnte nicht angelegt werden.')),
        );
      }
    }
  }

  Future<void> _changeCaseStatus(ModerationCase item) async {
    String status = item.status;
    final resolution = TextEditingController(text: item.resolution);
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Fall: ${item.category}'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description.isNotEmpty) Text(item.description),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'open', child: Text('Offen')),
                    DropdownMenuItem(
                      value: 'in_review',
                      child: Text('In Prüfung'),
                    ),
                    DropdownMenuItem(value: 'resolved', child: Text('Gelöst')),
                    DropdownMenuItem(
                      value: 'closed',
                      child: Text('Geschlossen'),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => status = value ?? item.status),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: resolution,
                  maxLength: 1000,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Entscheidung / Begründung',
                    helperText: 'Für Gelöst oder Geschlossen erforderlich.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
    if (submit != true) return;
    try {
      await _repository.updateCase(
        id: item.id,
        status: status,
        resolution: resolution.text.trim(),
      );
      await _load();
    } on BackofficeApiException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fall konnte nicht aktualisiert werden.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: FilledButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(_error!),
        ),
      );
    }
    final overview = _overview!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backoffice',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    overview.role == 'admin'
                        ? 'Administration mit revisionspflichtigen Aktionen.'
                        : 'Moderation: dokumentierte Fälle ohne Zugriff auf Konten oder Zahlungen.',
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Aktualisieren',
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              label: 'Konten',
              value: '${overview.metrics['accounts'] ?? 0}',
            ),
            _MetricCard(
              label: 'Projekte',
              value: '${overview.metrics['projects'] ?? 0}',
            ),
            _MetricCard(
              label: 'Offene Fälle',
              value: '${overview.metrics['open_cases'] ?? 0}',
            ),
            if (widget.profile.canReadBilling)
              _MetricCard(
                label: 'Testzahlungen',
                value: '${overview.metrics['test_transactions'] ?? 0}',
              ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Moderationsfälle', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        if (widget.profile.canManageModeration)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _createCase,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Fall dokumentieren'),
            ),
          ),
        const SizedBox(height: 8),
        if (_cases.isEmpty)
          const Card(
            child: ListTile(
              title: Text('Keine offenen oder dokumentierten Fälle.'),
            ),
          )
        else
          ..._cases.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.category),
                subtitle: Text('${item.priority} · ${item.status}'),
                trailing: widget.profile.canManageModeration
                    ? IconButton(
                        tooltip: 'Fall bearbeiten',
                        onPressed: () => _changeCaseStatus(item),
                        icon: const Icon(Icons.edit_outlined),
                      )
                    : null,
              ),
            ),
          ),
        if (widget.profile.canReadBilling) ...[
          const SizedBox(height: 32),
          Text(
            'Zahlungsübersicht',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Nur Status und aggregierte Beträge – keine Zahlungs- oder Kundendaten.',
          ),
          const SizedBox(height: 10),
          if (_transactions.isEmpty)
            const Card(
              child: ListTile(
                title: Text('Noch keine verifizierten Zahlungsereignisse.'),
              ),
            )
          else
            ..._transactions.map(
              (item) => Card(
                child: ListTile(
                  title: Text('${item.plan ?? 'Ohne Tarif'} · ${item.status}'),
                  subtitle: Text(
                    '${item.mode} · ${item.kind} · ${item.occurredAt}',
                  ),
                  trailing: Text(
                    '${(item.amountCents / 100).toStringAsFixed(2)} ${item.currency}',
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 160,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    ),
  );
}
