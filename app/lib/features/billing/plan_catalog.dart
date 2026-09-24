/// Öffentlicher Tarifkatalog für die vorvertragliche Information im Client.
///
/// Der Katalog berechnet niemals Berechtigungen. Verbindliche Slots und
/// Speicherquoten kommen ausschließlich aus einem serverseitigen Entitlement.
/// Die Werte sind hier trotzdem bewusst zentralisiert, damit die Darstellung
/// vor der späteren Stripe- und Backoffice-Anbindung konsistent bleibt.
class PlanDefinition {
  const PlanDefinition({
    required this.slug,
    required this.name,
    required this.monthlyPriceCents,
    required this.yearlyPriceCents,
    required this.projectSlots,
    required this.storageBytes,
    required this.logoVariants,
    required this.fontFamilies,
    required this.templates,
    required this.includesAllCoreFeatures,
    required this.isAvailable,
  });

  final String slug;
  final String name;
  final int monthlyPriceCents;
  final int yearlyPriceCents;
  final int projectSlots;
  final int storageBytes;
  final int logoVariants;
  final int fontFamilies;
  final int templates;
  final bool includesAllCoreFeatures;
  final bool isAvailable;

  bool get isPaid => monthlyPriceCents > 0;

  /// Der Rabatt wird aus den echten Euro-Cent-Werten bestimmt, nicht beworben.
  int get annualSavingsPercent {
    if (!isPaid || yearlyPriceCents >= monthlyPriceCents * 12) return 0;
    return (((monthlyPriceCents * 12 - yearlyPriceCents) /
                (monthlyPriceCents * 12)) *
            100)
        .round();
  }
}

abstract final class PlanCatalog {
  static const int megabyte = 1024 * 1024;

  static const List<PlanDefinition> publicPlans = [
    PlanDefinition(
      slug: 'free',
      name: 'Free',
      monthlyPriceCents: 0,
      yearlyPriceCents: 0,
      projectSlots: 1,
      storageBytes: 100 * megabyte,
      logoVariants: 1,
      fontFamilies: 0,
      templates: 1,
      includesAllCoreFeatures: true,
      isAvailable: true,
    ),
    PlanDefinition(
      slug: 'creator',
      name: 'Creator',
      monthlyPriceCents: 900,
      yearlyPriceCents: 9000,
      projectSlots: 4,
      storageBytes: 500 * megabyte,
      logoVariants: 3,
      fontFamilies: 1,
      templates: 3,
      includesAllCoreFeatures: true,
      isAvailable: false,
    ),
    PlanDefinition(
      slug: 'studio',
      name: 'Studio',
      monthlyPriceCents: 1900,
      yearlyPriceCents: 19000,
      projectSlots: 12,
      storageBytes: 1536 * megabyte,
      logoVariants: 8,
      fontFamilies: 3,
      templates: 8,
      includesAllCoreFeatures: true,
      isAvailable: false,
    ),
    PlanDefinition(
      slug: 'ultimate',
      name: 'Ultimate',
      monthlyPriceCents: 4900,
      yearlyPriceCents: 49000,
      projectSlots: 25,
      storageBytes: 3072 * megabyte,
      logoVariants: 20,
      fontFamilies: 10,
      templates: 20,
      includesAllCoreFeatures: true,
      // Erst freigeben, wenn EU-Objektspeicher und Kostenkontrolle stehen.
      isAvailable: false,
    ),
  ];
}
