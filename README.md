# Michael Gahn DESIGN – CI BUILDER

[Live-App öffnen](https://ci.michael-gahn.de/)

Der CI BUILDER ist eine Flutter-Webanwendung für Agenturen, Teams und Marken. Er führt durch die Erstellung eines klaren, erweiterbaren Designmanuals und eines Social-Media-Codex. Die Anwendung wird auf deutschem Hosting betrieben und ist von Beginn an auf Datenschutz, lokale Assets und sichere Zugriffssteuerung ausgelegt.

## Aktueller Produktstand

- Deutsch und Englisch als Plattformsprachen, Deutsch als Standard
- Landingpage mit Dark- und Light-Mode; die Wahl wird lokal im Browser gespeichert
- Registrierung, Login, Passwort-Änderung sowie rollenbasierte Administration
- Ein kostenloser Projektplatz und ein geführter Einrichtungsassistent
- Projektgrunddaten sowie optionale private Uploads oder externe HTTPS-Bildreferenzen
- Benutzergetrennte Projekt-Mediathek mit geschütztem API-Zugriff
- Kontoansicht mit serverseitig berechneten Slots und Medienspeicher
- informative Tarifübersicht für Slot+, Studio und Agentur; noch kein aktiver Kauf
- Lokal ausgelieferte Open-Sans-Schrift und lokale Flutter-/CanvasKit-Ressourcen
- Öffentliche Rechtstexte, Cookie-Einstellungen und kein externes Tracking

Die nächsten Produktstufen sind der vollständige Manual-Editor, HTML-/PDF-Export, ein editierbarer Landingpage-Bereich für Administratoren sowie eine Stripe-gesicherte Abrechnung für Einmalkäufe und optionale Tarife.

## Datenschutz und Sicherheit

Passwörter werden ausschließlich serverseitig gehasht verarbeitet. Berechtigungen und Medienzugriffe werden serverseitig geprüft; Konfiguration und Zugangsdaten gehören in eine nicht versionierte `.env`-Datei. Personenbezogene Daten werden auf das notwendige Maß beschränkt.

## Dokumentation

Die versionierte technische Projektdokumentation befindet sich in [`WIKI/`](WIKI/Home.md). Die veröffentlichte Kurzfassung ist im [GitHub-Wiki](https://github.com/MichaelGahnDESIGN/MGD_CI-Designmanual/wiki) verfügbar.
