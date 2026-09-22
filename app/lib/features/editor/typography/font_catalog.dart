/// Beschreibt eine lokal gebündelte Schrift, die ohne externe Anfrage in
/// Vorschau, Editor und späteren Exporten verwendet werden darf.
class BrandFontOption {
  const BrandFontOption({
    required this.family,
    required this.description,
    required this.sample,
  });

  final String family;
  final String description;
  final String sample;
}

/// Bewusst kleine Startbibliothek: Alle Familien liegen als WOFF2-Dateien im
/// Projekt. Dadurch werden keine Texte, IP-Adressen oder Nutzungsdaten an
/// externe Font-Dienste übertragen.
const standardBrandFonts = <BrandFontOption>[
  BrandFontOption(
    family: 'Open Sans',
    description: 'Klar, zugänglich und vielseitig',
    sample: 'Marke mit Haltung',
  ),
  BrandFontOption(
    family: 'Lato',
    description: 'Freundlich und sachlich',
    sample: 'Nahbar und präzise',
  ),
  BrandFontOption(
    family: 'Montserrat',
    description: 'Geometrisch und präsent',
    sample: 'Stark im Auftritt',
  ),
  BrandFontOption(
    family: 'Merriweather',
    description: 'Editorial und charaktervoll',
    sample: 'Geschichten mit Substanz',
  ),
];
