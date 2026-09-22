import 'package:flutter/material.dart';

/// Transparente Angebotsübersicht ohne vorgetäuschten Kaufabschluss.
///
/// Entitlements werden erst nach einem verifizierten Stripe-Webhook aktiviert.
/// Bis Stripe-Preis-IDs, Webhook und Testmodus eingerichtet sind, zeigt diese
/// Oberfläche bewusst nur die geplanten Optionen und löst keine Zahlung aus.
class UpgradeOfferSheet extends StatelessWidget {
  const UpgradeOfferSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const UpgradeOfferSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: .72,
      minChildSize: .52,
      maxChildSize: .92,
      builder: (context, controller) => Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mehr Raum für deine Marken.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Du hast alle verfügbaren Projektslots genutzt. Wähle künftig einen dauerhaften Extra-Slot oder einen Plan mit mehr Raum für dein Team.',
            ),
            const SizedBox(height: 22),
            const _PlanTile(
              title: 'Slot+',
              price: '19 € einmalig',
              detail: '+1 Projektslot · +100 MB privater Speicher',
              accent: false,
            ),
            const SizedBox(height: 10),
            const _PlanTile(
              title: 'Studio',
              price: '12 € / Monat · 120 € / Jahr',
              detail: '5 Projektslots · 500 MB · Vorlagen · Export',
              accent: true,
            ),
            const SizedBox(height: 10),
            const _PlanTile(
              title: 'Agentur',
              price: '29 € / Monat · 290 € / Jahr',
              detail: '20 Projektslots · 1,5 GB · Teamzugänge · Vorlagen',
              accent: false,
            ),
            const SizedBox(height: 20),
            Text(
              'Noch kein Kauf möglich',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Zahlungen werden erst nach Einrichtung von Stripe Checkout, Preis-IDs und signierter Webhook-Prüfung aktiviert. Bis dahin entstehen durch diese Auswahl keine Kosten und keine neuen Berechtigungen.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.title,
    required this.price,
    required this.detail,
    required this.accent,
  });

  final String title;
  final String price;
  final String detail;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent ? colors.surfaceContainerHighest : colors.surface,
        border: Border.all(
          color: accent ? colors.onSurface : colors.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(detail),
        ],
      ),
    );
  }
}
