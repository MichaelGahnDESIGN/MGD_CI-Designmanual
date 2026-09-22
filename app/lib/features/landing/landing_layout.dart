import 'package:flutter/widgets.dart';

/// Bündelt die responsiven Maße der öffentlichen Landingpage.
///
/// Die Werte orientieren sich an der tatsächlich verfügbaren Browserbreite.
/// Dadurch bleibt die visuelle Hierarchie auch auf Tablets und kleinen
/// Smartphones erhalten, ohne die Schriftgröße des Browsers zu begrenzen.
@immutable
class LandingLayout {
  const LandingLayout({
    required this.pagePadding,
    required this.heroSpacing,
    required this.eyebrowSize,
    required this.headlineSize,
    required this.headlineLetterSpacing,
    required this.headlineHeight,
    required this.bodySize,
    required this.benefitSpacing,
    required this.compactHeader,
    required this.iconOnlyLogin,
  });

  final EdgeInsets pagePadding;
  final double heroSpacing;
  final double eyebrowSize;
  final double headlineSize;
  final double headlineLetterSpacing;
  final double headlineHeight;
  final double bodySize;
  final double benefitSpacing;
  final bool compactHeader;
  final bool iconOnlyLogin;

  /// Liefert bewusst nur wenige stabile Layoutstufen. Das vermeidet sprunghafte
  /// Größenwechsel und macht die Darstellung leichter testbar.
  factory LandingLayout.forWidth(double width) {
    if (width < 420) {
      return const LandingLayout(
        pagePadding: EdgeInsets.fromLTRB(20, 20, 20, 32),
        heroSpacing: 44,
        eyebrowSize: 14,
        headlineSize: 38,
        headlineLetterSpacing: -1.2,
        headlineHeight: 1.02,
        bodySize: 16,
        benefitSpacing: 48,
        compactHeader: true,
        iconOnlyLogin: true,
      );
    }

    if (width < 600) {
      return const LandingLayout(
        pagePadding: EdgeInsets.fromLTRB(22, 22, 22, 36),
        heroSpacing: 48,
        eyebrowSize: 14,
        headlineSize: 46,
        headlineLetterSpacing: -1.6,
        headlineHeight: 1,
        bodySize: 16,
        benefitSpacing: 52,
        compactHeader: true,
        iconOnlyLogin: false,
      );
    }

    if (width < 900) {
      return const LandingLayout(
        pagePadding: EdgeInsets.fromLTRB(28, 28, 28, 40),
        heroSpacing: 54,
        eyebrowSize: 15,
        headlineSize: 56,
        headlineLetterSpacing: -2.2,
        headlineHeight: .98,
        bodySize: 17,
        benefitSpacing: 60,
        compactHeader: true,
        iconOnlyLogin: false,
      );
    }

    return const LandingLayout(
      pagePadding: EdgeInsets.fromLTRB(36, 32, 36, 48),
      heroSpacing: 76,
      eyebrowSize: 16,
      headlineSize: 68,
      headlineLetterSpacing: -2.8,
      headlineHeight: .96,
      bodySize: 18,
      benefitSpacing: 72,
      compactHeader: false,
      iconOnlyLogin: false,
    );
  }
}
