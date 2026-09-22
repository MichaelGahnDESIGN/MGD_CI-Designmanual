# Aktueller Produktstand

Stand: 22. September 2026

## Bereits vorhanden

Die Live-App unter `ci.michael-gahn.de` bietet eine zweisprachige Landingpage, einen gespeicherten Light-/Dark-Mode, E-Mail-Registrierung und Login, Passwort-Änderung, Benutzerrollen, einen kostenlosen Projektplatz und einen geführten Projekteinrichtungsassistenten. Optionale Logo- und Referenzbilder werden geprüft und projektbezogen verwaltet. Die Mediathek ist pro Benutzer und Projekt getrennt.

Open Sans sowie die für Flutter Web benötigten Ressourcen werden lokal ausgeliefert. Die öffentlichen Seiten enthalten Impressum, AGB, Datenschutz, Cookie-Einstellungen, AI-Philosophie und Barrierefreiheit. Externes Tracking ist nicht eingebunden.

## Datenschutz und Sicherheit

Zugangsdaten und Infrastruktur-Parameter liegen ausschließlich in einer nicht versionierten `.env`-Datei. Passwörter werden niemals im Client oder Repository gespeichert, sondern serverseitig gehasht. Jede Projekt-, Medien- und Administrationsanfrage braucht eine serverseitige Berechtigungsprüfung. Uploads werden nach Typ und Größe eingeschränkt.

## Nächste Schritte

1. Designmanual-Editor mit Bereichen für Marke, Farbe, Typografie, Bildwelt, Tonalität und Social Media.
2. Export als eigenständiges HTML-Projekt und als PDF.
3. Administrierbare Landingpage-Inhalte und Übersetzungen.
4. Erweiterbare Store-Architektur für einmalig kaufbare Funktionen; Stripe erst nach separater Sicherheits- und Rechtsprüfung.
