import 'package:flutter/material.dart';

/// Kompakte, rein lokale Wort-Bild-Marke der Anwendung.
class CiBrandMark extends StatelessWidget {
  const CiBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.onSurface,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: SizedBox(
            width: 31,
            height: 31,
            child: Center(
              child: Text(
                'M',
                style: TextStyle(
                  color: colors.surface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'CI BUILDER',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .7),
        ),
      ],
    );
  }
}
