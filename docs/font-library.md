# Lokale Schriftbibliothek und Font-Upload

## Grundsatz

Die Bedienoberfläche des CI BUILDER verwendet **Open Sans**. Die benötigten
WOFF2-Dateien werden mit der Anwendung ausgeliefert; der Browser lädt keine
Schriften von Google Fonts, Adobe Fonts oder einem anderen CDN. Das vermeidet
unnötige Verbindungen zu Dritten und hält Vorschau sowie Export reproduzierbar.

Für Markenprojekte stehen zunächst vier lokal eingebettete Familien zur Wahl:

- Open Sans als zugänglicher und vielseitiger Standard,
- Lato als freundliche sachliche Alternative,
- Montserrat für geometrische Display-Anwendungen,
- Merriweather für redaktionelle Serif-Anwendungen.

Alle vier Familien stammen aus dem Fontsource-Paketstand 5.3.0 und stehen unter
der SIL Open Font License 1.1. Die zugehörigen Lizenztexte liegen unter
`assets/fonts/licenses/`.

## Einheitliches Schriftmodell

Eine gewählte Standardschrift wird später als stabile interne Schrift-ID im
Projekt gespeichert. Editor, responsive Vorschau, HTML-Export und PDF-Export
müssen dieselbe ID und dieselben lokal gespeicherten Dateien verwenden. Eine
Schrift darf nicht nur über ihren sichtbaren Namen oder eine externe URL
referenziert werden.

## Kostenpflichtiger Upload

Der Upload eigener Schriften ist als optionale Erweiterung mit Einmalkauf
vorgesehen. Die aktuelle Oberfläche kündigt ihn transparent an, nimmt aber noch
keine Datei entgegen. Vor der Aktivierung sind mindestens erforderlich:

1. serverseitig geprüftes Store-Entitlement für das betreffende Konto,
2. bestätigte Nutzungs- und Einbettungsrechte durch den hochladenden Nutzer,
3. erlaubte Formate und Größenlimits; bevorzugt WOFF2, keine ausführbaren Inhalte,
4. Prüfung von Dateisignatur, MIME-Typ, Font-Metadaten und schädlichen Inhalten,
5. privater projektbezogener Speicher außerhalb frei erratbarer Webpfade,
6. Berechtigungsprüfung bei Vorschau, Download und Export,
7. dokumentierte Löschung, Exportfähigkeit und Aufbewahrung nach DSGVO-Grundsätzen.

Zahlungsdaten werden nicht selbst gespeichert. Das spätere Stripe-Entitlement
wird ausschließlich serverseitig aus signierten und idempotent verarbeiteten
Webhook-Ereignissen abgeleitet.

## Datenschutz und Sicherheit

Schriften und Font-Metadaten bleiben projektbezogen. Originaldateien dürfen nie
in Git, öffentliche Build-Artefakte oder ungeschützte Webverzeichnisse gelangen.
Dateinamen sind keine Berechtigung. Protokolle enthalten nur technische
Ereignisse und niemals den Font-Inhalt oder unnötige personenbezogene Daten.
