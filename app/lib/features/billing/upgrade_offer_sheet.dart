import 'package:flutter/material.dart';

import 'plan_catalog.dart';

/// Transparente Angebotsübersicht ohne vorgetäuschten Kaufabschluss.
///
/// Entitlements werden erst nach einem verifizierten Stripe-Webhook aktiviert.
/// Bis Stripe-Preis-IDs, Webhook und Testmodus eingerichtet sind, zeigt diese
/// Oberfläche bewusst nur die geplanten Optionen und löst keine Zahlung aus.
class UpgradeOfferSheet extends StatefulWidget {
  const UpgradeOfferSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const UpgradeOfferSheet(),
  );

  @override
  State<UpgradeOfferSheet> createState() => _UpgradeOfferSheetState();
}

class _UpgradeOfferSheetState extends State<UpgradeOfferSheet> {
  bool _annual = true;

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
              'Alle Grundlagen bleiben kostenlos. Zusätzliche Slots, Speicher, Varianten und Vorlagen kommen mit den Tarifen dazu.',
            ),
            const SizedBox(height: 22),
            Semantics(
              label: 'Abrechnungszeitraum',
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Monatlich')),
                  ButtonSegment(value: true, label: Text('Jährlich')),
                ],
                selected: {_annual},
                onSelectionChanged: (value) =>
                    setState(() => _annual = value.single),
              ),
            ),
            const SizedBox(height: 16),
            ...PlanCatalog.publicPlans.map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlanTile(
                  plan: plan,
                  annual: _annual,
                  accent: plan.slug == 'studio',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Noch kein Kauf möglich',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Zahlungen werden erst nach Einrichtung von Stripe Checkout, Test-Preis-IDs und signierter Webhook-Prüfung aktiviert. Bis dahin entstehen durch diese Ansicht keine Kosten und keine neuen Berechtigungen.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.annual,
    required this.accent,
  });

  final PlanDefinition plan;
  final bool annual;
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
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (annual && plan.annualSavingsPercent > 0)
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('${plan.annualSavingsPercent}% sparen'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _priceLabel(plan, annual),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(_details(plan)),
          if (plan.includesAllCoreFeatures) ...[
            const SizedBox(height: 6),
            const Text('Alle Grundfunktionen inklusive.'),
          ],
          if (!plan.isAvailable && plan.isPaid) ...[
            const SizedBox(height: 8),
            const Text('Noch nicht buchbar – unverbindliche Vorschau.'),
          ],
        ],
      ),
    );
  }

  String _priceLabel(PlanDefinition value, bool annual) {
    if (!value.isPaid) return '0 €';
    final cents = annual ? value.yearlyPriceCents : value.monthlyPriceCents;
    final euros = (cents / 100).toStringAsFixed(0);
    return annual ? '$euros € / Jahr' : '$euros € / Monat';
  }

  String _details(PlanDefinition value) {
    final storage = value.storageBytes >= 1024 * 1024 * 1024
        ? '${(value.storageBytes / (1024 * 1024 * 1024)).toStringAsFixed(value.storageBytes % (1024 * 1024 * 1024) == 0 ? 0 : 1)} GB'
        : '${value.storageBytes ~/ (1024 * 1024)} MB';
    return '${value.projectSlots} Projektslots · $storage · '
        '${value.logoVariants} Logo-Varianten · ${value.templates} Vorlagen';
  }
}
