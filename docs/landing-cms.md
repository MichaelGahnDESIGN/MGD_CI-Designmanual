# Landing-CMS und lokales Designsystem

## Ziel

Die öffentliche Landingpage bleibt eine Flutter-Webapp, ihre veröffentlichte
Struktur wird aber im geschützten Adminbereich bearbeitbar. Dafür liegt
Grapes.js vollständig lokal unter `backend/public/admin/vendor/`; externe CDN-
oder Google-Font-Abhängigkeiten sind nicht vorgesehen.

Der Admin-Editor ist nur eine Bearbeitungsoberfläche. Die Vertrauensgrenze
bleibt die PHP-API: `cms.landing.edit` wird serverseitig geprüft, CSRF ist für
Schreibzugriffe verpflichtend und HTML/CSS werden vor der Speicherung als
verschlüsseltes CMS-Dokument persistiert.

## Sprachen

Deutsch (`de`) ist die Standardlocale, Englisch (`en`) die erste zusätzliche
Locale. Die CMS-Migration enthält sowohl veröffentlichte Landing-Dokumente als
auch einzelne Übersetzungseinträge (`cms_translation_entries`). Damit können
später Dashboard, Assistent, Fehlermeldungen, Hilfe und Adminbereich aus
derselben serverseitigen Übersetzungsquelle gespeist werden.

Fehlt ein veröffentlichtes CMS-Dokument oder ist die API nicht erreichbar,
verwendet die Flutter-Landingpage einen lokal gebündelten, deutschen Fallback.
Das hält die öffentliche Startseite verfügbar, ohne Inhalte oder Secrets in
externen Diensten zu speichern.

## Erscheinungsbilder

Light und Dark nutzen semantische Theme-Rollen. Der CI BUILDER verwendet lokal
gebündeltes Open Sans als Bedien- und Leseschrift. Für Markenprojekte stehen
zusätzlich Lato, Montserrat und Merriweather lokal zur Wahl. Farben sind nach
Rolle benannt; Schriften und andere Design-Assets dürfen nicht von fremden
CDNs nachgeladen werden.

## Editorregeln

- wiederverwendbare Blöcke statt unkontrollierter Inline-Fragmente;
- sichtbare Locale-Auswahl DE/EN mit identischem Strukturmodell;
- veröffentlichen ist eine explizite Aktion und erhöht die Revision;
- jeder Inhalt bleibt sanitisiert, projektbezogen und auditierbar;
- API-Fehler dürfen den Editor nicht mit Datenbank- oder Schlüsselmaterial
  versorgen.

## Öffentliche Rechtstexte und Einwilligungen

Der Landingpage-Footer verlinkt öffentlich erreichbare Seiten für Impressum,
AGB, Datenschutz, Cookies, AI-Philosophie und Barrierefreiheit. Zahlung und
Widerruf sind bis zur rechtlichen und kaufmännischen Freigabe sichtbar als
unverbindliche Entwürfe markiert. Die lokalen Fallbacktexte enthalten keine
Zugangsdaten und müssen vor einem kommerziellen Start rechtlich endgeprüft
werden.

Die Cookie-Einstellungen folgen dem tatsächlichen technischen Stand: Nur für
Sicherheit, Anmeldung, App-Cache und die Speicherung der Auswahl notwendige
Funktionen sind aktiv. Statistik, Marketing und externe Medien sind nicht
vorangekreuzt und werden derzeit nicht eingesetzt. Eine spätere optionale
Integration muss vor dem Laden technisch an die aktive Einwilligung gebunden
werden; ein reines UI-Häkchen reicht nicht aus.

Die zugrunde liegende CMS-Migration ist `004_cms_landing_i18n.sql`. Sie wird
erst nach einem aktuellen Live-Backup und einer dokumentierten Freigabe
angewendet.
