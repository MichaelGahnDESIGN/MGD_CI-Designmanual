enum LegalDocument {
  imprint,
  terms,
  privacy,
  payment,
  withdrawal,
  cookies,
  aiPhilosophy,
  accessibility,
}

class LegalSection {
  const LegalSection(this.title, this.body);

  final String title;
  final String body;
}

class LegalSource {
  const LegalSource(this.label, this.url);

  final String label;
  final String url;
}

extension LegalDocumentContent on LegalDocument {
  String get route => switch (this) {
    LegalDocument.imprint => '/impressum',
    LegalDocument.terms => '/agb',
    LegalDocument.privacy => '/datenschutz',
    LegalDocument.payment => '/zahlung',
    LegalDocument.withdrawal => '/widerruf',
    LegalDocument.cookies => '/cookies',
    LegalDocument.aiPhilosophy => '/ai-philosophie',
    LegalDocument.accessibility => '/barrierefreiheit',
  };

  String get title => switch (this) {
    LegalDocument.imprint => 'Impressum',
    LegalDocument.terms => 'Allgemeine Geschäftsbedingungen',
    LegalDocument.privacy => 'Datenschutz',
    LegalDocument.payment => 'Zahlung',
    LegalDocument.withdrawal => 'Widerruf',
    LegalDocument.cookies => 'Cookies & Einstellungen',
    LegalDocument.aiPhilosophy => 'AI-Philosophie',
    LegalDocument.accessibility => 'Barrierefreiheit',
  };

  String get footerLabel => switch (this) {
    LegalDocument.terms => 'AGB',
    LegalDocument.cookies => 'Cookies',
    LegalDocument.aiPhilosophy => 'AI-Philosophie',
    _ => title,
  };

  bool get isDraft =>
      this == LegalDocument.payment || this == LegalDocument.withdrawal;

  String get intro => switch (this) {
    LegalDocument.imprint =>
      'Anbieterkennzeichnung für den Michael Gahn DESIGN CI BUILDER.',
    LegalDocument.terms => 'Vorläufige Nutzungsbedingungen für die kostenlose Entwicklungs- und Testphase. Vor der Freischaltung kostenpflichtiger Funktionen erfolgt eine rechtliche Endprüfung.',
    LegalDocument.privacy => 'Diese Hinweise beschreiben die derzeitige technische Verarbeitung im CI BUILDER. Sie werden vor dem kommerziellen Start rechtlich abschließend geprüft.',
    LegalDocument.payment => 'Nicht verbindlicher Konzeptstand für spätere Einmalkäufe. Derzeit werden im CI BUILDER keine Zahlungen angeboten oder entgegengenommen.',
    LegalDocument.withdrawal => 'Nicht verbindlicher Konzeptstand. Diese Seite ist noch keine Widerrufsbelehrung und wird vor dem ersten kostenpflichtigen Angebot rechtlich vervollständigt.',
    LegalDocument.cookies => 'Der CI BUILDER verwendet derzeit nur technisch notwendige Speicherungen. Analyse, Werbung und externe Medien sind nicht aktiviert.',
    LegalDocument.aiPhilosophy => 'Künstliche Intelligenz soll kreative Arbeit unterstützen, nicht Verantwortung, Urheberschaft oder menschliche Entscheidungen ersetzen.',
    LegalDocument.accessibility => 'Der CI BUILDER wird schrittweise barrierearm und nach anerkannten Standards entwickelt. Eine formale Konformitätsprüfung steht noch aus.',
  };

  List<LegalSection> get sections => switch (this) {
    LegalDocument.imprint => const [
      LegalSection(
        'Angaben gemäß § 5 DDG',
        'Michael Gahn DESIGN\nMichael Gahn\nDr.-Theodor-Brugsch-Str. 12\n08529 Plauen\nSachsen, Deutschland',
      ),
      LegalSection(
        'Kontakt',
        'Telefon: +49 (0) 151 59156639\nE-Mail: Anfrage@Michael-Gahn.de',
      ),
      LegalSection(
        'Steuerangaben',
        'Steuernummer: 223/222/02451\nUmsatzsteuer-Identifikationsnummer gemäß § 27a UStG: DE288143343',
      ),
    ],
    LegalDocument.terms => const [
      LegalSection(
        '1. Aktueller Geltungsbereich',
        'Diese vorläufigen Bedingungen gelten für die kostenlose Entwicklungs- und Testphase des CI BUILDER. Ein Anspruch auf dauerhafte Verfügbarkeit oder einen bestimmten Funktionsumfang entsteht daraus nicht.',
      ),
      LegalSection(
        '2. Nutzerkonten',
        'Zugangsdaten sind persönlich und geheim zu halten. Automatisierte Angriffe, missbräuchliche Zugriffe sowie die Verarbeitung rechtswidriger Inhalte sind nicht gestattet.',
      ),
      LegalSection(
        '3. Inhalte und Rechte',
        'Nutzende bleiben für hochgeladene Markeninhalte verantwortlich und müssen die erforderlichen Nutzungsrechte besitzen. Eigene Inhalte werden nicht ohne gesonderte Grundlage zu Werbe- oder Trainingszwecken verwendet.',
      ),
      LegalSection(
        '4. Kostenpflichtige Leistungen',
        'Kostenpflichtige Funktionen, Preise und dauerhafte Erweiterungen werden erst nach Veröffentlichung verbindlicher Vertragsbedingungen freigeschaltet. Ein Abonnement ist derzeit nicht vorgesehen.',
      ),
      LegalSection(
        '5. Rechtliche Prüfung',
        'Haftung, Laufzeit, Kündigung, Verbraucherinformationen und Gerichtsstand werden vor dem kommerziellen Start durch eine fachkundige rechtliche Prüfung abschließend geregelt.',
      ),
    ],
    LegalDocument.privacy => const [
      LegalSection(
        '1. Verantwortlicher',
        'Michael Gahn DESIGN, Michael Gahn, Dr.-Theodor-Brugsch-Str. 12, 08529 Plauen. Kontakt: Anfrage@Michael-Gahn.de.',
      ),
      LegalSection(
        '2. Öffentlicher Aufruf und Serverprotokolle',
        'Beim Aufruf verarbeitet der Hosting-Server technisch erforderliche Verbindungsdaten wie IP-Adresse, Zeitpunkt, angeforderte Ressource, Browserkennung und Statuscode. Die Verarbeitung dient dem sicheren Betrieb, der Fehleranalyse und der Abwehr von Angriffen.',
      ),
      LegalSection(
        '3. Konten und Projekte',
        'Für Konten werden insbesondere E-Mail-Adresse, Benutzername, sicherer Passwort-Hash, Rollen, Sitzungen und Sicherheitsereignisse verarbeitet. Projekt- und Manualdaten werden nur für Bereitstellung, Bearbeitung, Speicherung und Export verarbeitet. Berechtigungen werden serverseitig geprüft.',
      ),
      LegalSection(
        '4. Rechtsgrundlagen',
        'Je nach Nutzung erfolgt die Verarbeitung zur Vertragsanbahnung oder Vertragserfüllung, zur Erfüllung gesetzlicher Pflichten, aufgrund berechtigter Interessen am sicheren Betrieb oder auf Grundlage einer Einwilligung. Eine Einwilligung kann mit Wirkung für die Zukunft widerrufen werden.',
      ),
      LegalSection(
        '5. Hosting und Empfänger',
        'Die Anwendung wird bei ALL-INKL.COM in Deutschland betrieben. Daten werden nur an technisch oder rechtlich erforderliche Empfänger übermittelt. Analyse- und Marketingdienste sind derzeit nicht eingebunden; eine Übermittlung in Drittländer ist für den aktuellen Grundbetrieb nicht vorgesehen.',
      ),
      LegalSection(
        '6. Speicherdauer',
        'Daten werden nur so lange gespeichert, wie es für den jeweiligen Zweck, die Kontosicherheit oder gesetzliche Aufbewahrungspflichten erforderlich ist. Konkrete Löschfristen werden vor dem Produktivstart im Löschkonzept festgelegt.',
      ),
      LegalSection(
        '7. Rechte betroffener Personen',
        'Betroffene Personen können im gesetzlichen Rahmen Auskunft, Berichtigung, Löschung, Einschränkung, Datenübertragbarkeit und Widerspruch verlangen. Zudem besteht ein Beschwerderecht bei einer zuständigen Datenschutzaufsichtsbehörde.',
      ),
      LegalSection(
        '8. Sicherheit und Stand',
        'Die Übertragung erfolgt verschlüsselt per HTTPS. Passwörter werden nicht im Klartext gespeichert. Stand dieser technischen Fassung: 21. September 2026.',
      ),
    ],
    LegalDocument.payment => const [
      LegalSection(
        'Geplantes Modell',
        'Erweiterungen sollen später als transparente Einmalkäufe ohne Abonnement angeboten werden. Vor einer Bestellung werden Preis, Steueranteil, Leistungsumfang und dauerhafte Freischaltung eindeutig angezeigt.',
      ),
      LegalSection(
        'Vorgesehener Zahlungsdienst',
        'Geplant ist Stripe Checkout. Zahlungsdaten sollen direkt durch Stripe verarbeitet werden und nicht auf den Servern des CI BUILDER gespeichert werden. Test- und Live-Modus bleiben strikt getrennt.',
      ),
      LegalSection(
        'Noch offen',
        'Preise, Produktkatalog, Rechnungsprozess, Erstattungen, Ausfallbehandlung und verbindliche Zahlungsbedingungen sind noch nicht freigegeben.',
      ),
    ],
    LegalDocument.withdrawal => const [
      LegalSection(
        'Vor Freischaltung erforderlich',
        'Vor dem ersten Verkauf werden Unternehmereigenschaft, Zielgruppe, Art der digitalen Leistung und Beginn der Vertragserfüllung rechtlich eingeordnet. Erst danach kann eine passende Widerrufsbelehrung veröffentlicht werden.',
      ),
      LegalSection(
        'Geplanter Ablauf',
        'Verbraucherinformationen, Widerrufsfrist, Widerrufsformular und Folgen des Widerrufs werden vor dem Kauf dauerhaft abrufbar bereitgestellt. Erforderliche Zustimmungen werden getrennt und nachweisbar eingeholt.',
      ),
    ],
    LegalDocument.cookies => const [
      LegalSection(
        'Technisch notwendige Speicherung',
        'Nach der Anmeldung verwendet der CI BUILDER ein sicheres HttpOnly-Sitzungscookie und ein CSRF-Schutzcookie. Beide sind für Anmeldung und Schutz vor ungewollten Formularaktionen erforderlich. Der Browser kann außerdem lokale App-Ressourcen zwischenspeichern.',
      ),
      LegalSection(
        'Consent-Einstellung',
        'Die Auswahl „nur notwendige“ wird lokal im Browser gespeichert, damit der Hinweis nicht bei jedem Seitenaufruf erneut erscheint. Diese Auswahl wird nicht für Werbung oder Profilbildung verwendet.',
      ),
      LegalSection(
        'Nicht eingesetzt',
        'Derzeit verwendet der CI BUILDER keine Analyse-, Marketing- oder Social-Media-Cookies und lädt keine externen Schrift- oder Icon-Dienste. Spätere optionale Kategorien bleiben bis zu einer aktiven Einwilligung ausgeschaltet.',
      ),
      LegalSection(
        'Browserkontrolle',
        'Lokale Daten und Cookies können zusätzlich in den Einstellungen des Browsers gelöscht werden. Das Entfernen notwendiger Sitzungsdaten führt zur Abmeldung.',
      ),
    ],
    LegalDocument.aiPhilosophy => const [
      LegalSection(
        'Menschliche Kontrolle',
        'AI darf Vorschläge machen, strukturieren und Varianten erzeugen. Veröffentlichungen, Markenentscheidungen und rechtlich relevante Freigaben bleiben bei Menschen.',
      ),
      LegalSection(
        'Transparenz',
        'AI-gestützte Funktionen werden erkennbar benannt. Ergebnisse werden nicht als garantiert richtig dargestellt und müssen prüfbar, bearbeitbar und verwerfbar bleiben.',
      ),
      LegalSection(
        'Datensparsamkeit',
        'Vertrauliche Projektinhalte werden nicht stillschweigend an externe AI-Dienste übertragen. Vor einer externen Verarbeitung werden Zweck, Anbieter, Datenkategorien und Wahlmöglichkeit verständlich erklärt.',
      ),
      LegalSection(
        'Kreativität und Rechte',
        'AI soll Gestaltungsspielräume erweitern, nicht Stile unreflektiert kopieren. Herkunft, Lizenzlage, Markenrechte und mögliche Verzerrungen werden bei jeder produktiven Funktion berücksichtigt.',
      ),
    ],
    LegalDocument.accessibility => const [
      LegalSection(
        'Unser Ziel',
        'Die Anwendung soll mit Tastatur, Vergrößerung, kontrastreichen Darstellungen und assistiven Technologien nutzbar sein. Orientierung geben klare Überschriften, verständliche Beschriftungen und ausreichend große Bedienelemente.',
      ),
      LegalSection(
        'Aktueller Stand',
        'Responsive Ansichten, skalierbare Open-Sans-Typografie, Light- und Darkmode sowie semantische Flutter-Komponenten sind eingerichtet. Eine vollständige Prüfung nach WCAG 2.2 AA und den anwendbaren gesetzlichen Anforderungen steht noch aus.',
      ),
      LegalSection(
        'Bekannte Grenzen',
        'Editor, Exporte und Adminbereich befinden sich im Aufbau. Einzelne Bereiche können deshalb noch unvollständige Tastaturführung, Screenreader-Texte oder Fokuszustände enthalten.',
      ),
      LegalSection(
        'Rückmeldung',
        'Barrieren können per E-Mail an Anfrage@Michael-Gahn.de gemeldet werden. Bitte nenne die betroffene Seite, das verwendete Gerät und – falls möglich – die eingesetzte assistive Technik.',
      ),
    ],
  };

  List<LegalSource> get sources => switch (this) {
    LegalDocument.imprint => const [
      LegalSource(
        'Öffentliches Impressum von Michael Gahn DESIGN',
        'https://michael-gahn.de/impressum/',
      ),
    ],
    LegalDocument.privacy => const [
      LegalSource(
        'Datenschutz-Grundverordnung',
        'https://eur-lex.europa.eu/eli/reg/2016/679/oj',
      ),
      LegalSource(
        '§ 25 TDDDG',
        'https://www.gesetze-im-internet.de/ttdsg/__25.html',
      ),
    ],
    LegalDocument.cookies => const [
      LegalSource(
        '§ 25 TDDDG',
        'https://www.gesetze-im-internet.de/ttdsg/__25.html',
      ),
    ],
    LegalDocument.accessibility => const [
      LegalSource(
        'Web Content Accessibility Guidelines 2.2',
        'https://www.w3.org/TR/WCAG22/',
      ),
    ],
    _ => const [],
  };

  static LegalDocument? fromRoute(String? route) {
    for (final document in LegalDocument.values) {
      if (document.route == route) return document;
    }
    return null;
  }

  /// Unterstützt sowohl direkte Pfade als auch Flutters Hash-Routen, damit
  /// öffentliche Rechtstexte nach einem Neuladen erreichbar bleiben.
  static LegalDocument? fromUri(Uri uri) {
    final direct = fromRoute(uri.path);
    if (direct != null) return direct;
    final fragmentPath = Uri.tryParse(uri.fragment)?.path;
    return fromRoute(fragmentPath);
  }
}
