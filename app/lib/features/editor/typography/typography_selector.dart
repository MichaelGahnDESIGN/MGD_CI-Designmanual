import 'package:flutter/material.dart';

import 'font_catalog.dart';

/// Auswahl für die Typografie einer Marke.
///
/// Der kostenpflichtige Upload wird hier nur transparent angekündigt. Eine
/// Dateiannahme darf erst aktiviert werden, wenn serverseitige Dateiprüfung,
/// Lizenzbestätigung, Projektberechtigung und das Store-Entitlement vorhanden
/// sind. So suggeriert die Oberfläche keine Sicherheit, die das Backend noch
/// nicht gewährleisten kann.
class BrandTypographySelector extends StatelessWidget {
  const BrandTypographySelector({
    super.key,
    required this.selectedFamily,
    required this.onChanged,
    required this.onUploadInfo,
  });

  final String selectedFamily;
  final ValueChanged<String> onChanged;
  final VoidCallback onUploadInfo;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Welche Schrift passt zur Marke?',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      const Text(
        'Alle Standardschriften sind lokal eingebettet. Open Sans ist vorausgewählt.',
      ),
      const SizedBox(height: 14),
      LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth >= 720
              ? (constraints.maxWidth - 12) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: standardBrandFonts
                .map(
                  (font) => SizedBox(
                    width: cardWidth,
                    child: _FontCard(
                      font: font,
                      selected: font.family == selectedFamily,
                      onTap: () => onChanged(font.family),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
      const SizedBox(height: 12),
      Semantics(
        button: true,
        label: 'Eigene Schrift hochladen, kostenpflichtige Erweiterung',
        child: InkWell(
          onTap: onUploadInfo,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD9D6DF)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.upload_file_outlined),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eigene Schrift hochladen',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 3),
                      Text('Pro-Erweiterung · Einmalkauf · später verfügbar'),
                    ],
                  ),
                ),
                _ProBadge(),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _FontCard extends StatelessWidget {
  const _FontCard({
    required this.font,
    required this.selected,
    required this.onTap,
  });

  final BrandFontOption font;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '${font.family}: ${font.description}',
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF111114) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF111114) : const Color(0xFFD9D6DF),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    font.sample,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF111114),
                      fontFamily: font.family,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${font.family} · ${font.description}',
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFFDAD8DE)
                          : const Color(0xFF686670),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? Colors.white : const Color(0xFF9A979F),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFF111114),
      borderRadius: BorderRadius.circular(999),
    ),
    child: const Text(
      'PRO',
      style: TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: .8,
      ),
    ),
  );
}
