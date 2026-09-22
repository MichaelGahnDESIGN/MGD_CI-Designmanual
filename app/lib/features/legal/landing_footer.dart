import 'package:flutter/material.dart';

import 'browser_storage.dart';
import 'legal_document.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key, required this.onOpenDocument});

  final ValueChanged<LegalDocument> onOpenDocument;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Divider(color: Theme.of(context).colorScheme.outlineVariant),
      const SizedBox(height: 28),
      Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          // Unveröffentlichte Rechtstexte bleiben intern vorbereitet, werden
          // im öffentlichen Footer aber erst nach Freigabe angeboten.
          for (final document in LegalDocument.values.where(
            (document) => !document.isDraft,
          ))
            _FooterLink(
              document: document,
              onPressed: () => onOpenDocument(document),
            ),
        ],
      ),
      const SizedBox(height: 26),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('support by:', style: Theme.of(context).textTheme.bodySmall),
          TextButton.icon(
            onPressed: () => openExternalUrl('https://michael-gahn.de'),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Michael Gahn DESIGN'),
          ),
        ],
      ),
    ],
  );
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.document, required this.onPressed});

  final LegalDocument document;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(document.footerLabel),
        if (document.isDraft) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'Entwurf',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ],
    ),
  );
}
