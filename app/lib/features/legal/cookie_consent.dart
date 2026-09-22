import 'package:flutter/material.dart';

import 'browser_storage.dart';

class CookieConsentBanner extends StatefulWidget {
  const CookieConsentBanner({super.key});

  @override
  State<CookieConsentBanner> createState() => _CookieConsentBannerState();
}

class _CookieConsentBannerState extends State<CookieConsentBanner> {
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _visible = !hasSavedCookieChoice();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 16,
            shadowColor: Colors.black.withValues(alpha: .18),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 620;
                  final copy = Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privatsphäre-Einstellungen',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Der CI BUILDER nutzt aktuell nur notwendige Speicherungen für Sicherheit, Anmeldung und deine Cookie-Auswahl. Keine Analyse und keine Werbung.',
                      ),
                    ],
                  );
                  final actions = Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await showCookieSettings(context);
                          if (mounted) setState(() => _visible = false);
                        },
                        child: const Text('Einstellungen'),
                      ),
                      FilledButton(
                        onPressed: _acceptNecessary,
                        child: const Text('Nur notwendige verwenden'),
                      ),
                    ],
                  );

                  if (compact) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [copy, const SizedBox(height: 18), actions],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: copy),
                      const SizedBox(width: 28),
                      Flexible(child: actions),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _acceptNecessary() {
    saveNecessaryCookieChoice();
    setState(() => _visible = false);
  }
}

Future<void> showCookieSettings(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 720),
      builder: (context) => const _CookieSettingsSheet(),
    );

class _CookieSettingsSheet extends StatelessWidget {
  const _CookieSettingsSheet();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cookie-Einstellungen',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          const Text(
            'Optionale Kategorien bleiben ausgeschaltet, solange sie im CI BUILDER nicht eingesetzt werden.',
          ),
          const SizedBox(height: 24),
          const _CookieCategory(
            title: 'Technisch notwendig',
            description: 'Sitzung, CSRF-Schutz, App-Cache und diese Auswahl.',
            value: true,
            status: 'Immer aktiv',
          ),
          const Divider(height: 28),
          const _CookieCategory(
            title: 'Präferenzen',
            description: 'Zusätzliche Komforteinstellungen.',
            value: false,
            status: 'Nicht eingesetzt',
          ),
          const Divider(height: 28),
          const _CookieCategory(
            title: 'Statistik',
            description: 'Reichweitenmessung oder Nutzungsanalyse.',
            value: false,
            status: 'Nicht eingesetzt',
          ),
          const Divider(height: 28),
          const _CookieCategory(
            title: 'Marketing und externe Medien',
            description:
                'Werbung, Social Media, Videos oder externe Schriften.',
            value: false,
            status: 'Nicht eingesetzt',
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                saveNecessaryCookieChoice();
                Navigator.pop(context);
              },
              child: const Text('Auswahl speichern'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CookieCategory extends StatelessWidget {
  const _CookieCategory({
    required this.title,
    required this.description,
    required this.value,
    required this.status,
  });

  final String title;
  final String description;
  final bool value;
  final String status;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 4),
            Text(
              status,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      const SizedBox(width: 16),
      Switch(value: value, onChanged: null),
    ],
  );
}
