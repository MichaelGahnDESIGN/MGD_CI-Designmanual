# AGENTS.md

## Mission

Der MGD CI Designmanual Editor soll Agenturen helfen, zugängliche, hochwertige und exportierbare Markenhandbücher zu erstellen. Das Projekt ist ein Produkt, keine Sammlung kundenspezifischer Manual-Daten.

## Zuerst lesen

1. `README.md`
2. `ROADMAP.md`
3. `WIKI/README.md`
4. die für die Änderung passende Seite unter `WIKI/`

## Source of truth

- Repository-Dateien: aktueller technischer Stand
- `CHANGELOG.md`: bereits umgesetzte, erwähnenswerte Änderungen
- `ROADMAP.md`: geplante Richtung
- `WIKI/`: vertiefende Produkt- und Architekturentscheidungen
- Issues und Pull Requests: Vorschläge und laufende Zusammenarbeit

## Verbindliche Regeln

- Keine Kundendaten, Zugangsdaten, Tokens oder lizenzpflichtigen Marken-Assets einchecken.
- Fachliche IDs sind serverseitig erzeugte UUIDv7; Namen, E-Mail-Adressen und Pfade dürfen keine Autorisierung ersetzen.
- Passwörter und Einmal-Tokens werden gehasht; reversible Verschlüsselung ist nur für Daten erlaubt, die der Dienst tatsächlich wieder lesen muss.
- Datenbankmigrationen sind idempotent, versioniert und brauchen vor dem Live-Lauf Backup, lesenden Check und klare Freigabe.
- Manual-Inhalte müssen vom Editor, der Vorschau und der Exportlogik getrennt bleiben.
- HTML- und PDF-Export rendern aus denselben Dokumentmodulen.
- Jede neue Funktion berücksichtigt responsive Darstellung, Druckansicht und Barrierefreiheit.
- Änderungen an Datenstrukturen aktualisieren Dokumentation, Beispielvorlagen und Validierung gemeinsam.
- Änderungen klein, nachvollziehbar und testbar halten.

## Änderungsablauf

1. Betroffenes Modul und Auswirkungen auf Editor, Vorschau und Export bestimmen.
2. Die kleinste stimmige Änderung implementieren.
3. Dokumentation und Beispielinhalte mitziehen.
4. Linting, Tests und einen Export-Smoke-Test ausführen, sobald die Toolchain eingerichtet ist.

Alles, was committed wird, muss für ein öffentliches Repository geeignet sein.
