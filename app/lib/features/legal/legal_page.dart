import 'package:flutter/material.dart';

import '../../shared/ci_brand_mark.dart';
import 'browser_storage.dart';
import 'cookie_consent.dart';
import 'legal_document.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({
    super.key,
    required this.document,
    required this.darkMode,
    required this.onThemeToggle,
  });

  final LegalDocument document;
  final bool darkMode;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        tooltip: 'Zurück',
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 8),
                      const CiBrandMark(),
                      const Spacer(),
                      IconButton(
                        onPressed: onThemeToggle,
                        tooltip: darkMode ? 'Lightmode' : 'Darkmode',
                        icon: Icon(
                          darkMode
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                  if (document.isDraft) ...[
                    const _DraftBanner(),
                    const SizedBox(height: 24),
                  ],
                  LayoutBuilder(
                    builder: (context, constraints) => Text(
                      document.title,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontSize: constraints.maxWidth < 600 ? 38 : 54,
                            height: 1,
                            letterSpacing: -1.8,
                          ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      document.intro,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(fontSize: 17),
                    ),
                  ),
                  const SizedBox(height: 48),
                  for (final section in document.sections) ...[
                    _LegalSectionView(section: section),
                    const SizedBox(height: 34),
                  ],
                  if (document == LegalDocument.cookies) ...[
                    OutlinedButton.icon(
                      onPressed: () => showCookieSettings(context),
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('Cookie-Einstellungen öffnen'),
                    ),
                    const SizedBox(height: 34),
                  ],
                  if (document.sources.isNotEmpty) ...[
                    Text(
                      'Quellen und weiterführende Informationen',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    for (final source in document.sources)
                      TextButton.icon(
                        onPressed: () => openExternalUrl(source.url),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: Text(source.label),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _LegalSectionView extends StatelessWidget {
  const _LegalSectionView({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 760),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        SelectableText(
          section.body,
          style: const TextStyle(fontSize: 16, height: 1.65),
        ),
      ],
    ),
  );
}

class _DraftBanner extends StatelessWidget {
  const _DraftBanner();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.edit_note_rounded, size: 20),
        SizedBox(width: 8),
        Flexible(child: Text('Entwurf – noch nicht verbindlich')),
      ],
    ),
  );
}
