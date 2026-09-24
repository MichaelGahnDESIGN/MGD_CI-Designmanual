# Changelog

Alle nennenswerten Änderungen an diesem Projekt werden hier dokumentiert. Das Format orientiert sich an [Keep a Changelog](https://keepachangelog.com/de/1.1.0/) und Semantic Versioning.

## [Unreleased]

### Added

- Tarifkatalog Free, Creator, Studio und Ultimate mit echtem Jahresvorteil;
  alle bestehenden Grundfunktionen bleiben im kostenlosen Tarif
- versionierte Backoffice-/Billing-/Moderationsmigration 007 am 24. September
  2026 nach verschlüsselter Sicherung, lesendem Vorabcheck und
  Funktionsprüfung produktiv angewendet; mit
  HMAC-gehashten Providerreferenzen, verschlüsseltem Audit und ohne
  Speicherung von Zahlungsinstrumenten oder Rechnungsdaten
- capability-geschütztes Backoffice für Admin und Moderation; kritische
  Kontostatus-, Rollen- und Tarifänderungen verlangen zusätzlich das aktuelle
  Admin-Kennwort und einen protokollierten Grund
- klickbare Desktop-Navigation sowie ein serverseitig freigeschalteter
  Backoffice-Einstieg für berechtigte Konten

- externe HTTPS-Bildreferenzen als verschlüsselte, speichersparende Alternative
  zum privaten Markenmaterial-Upload; ohne serverseitigen Abruf oder Proxy
- Kontoübersicht mit serverseitig berechneten Projektslots und Mediennutzung
- informative Tarifübersicht für Extra-Slots, Studio und Agentur ohne
  Kaufaktion oder Berechtigungsfreischaltung vor Stripe-Integration
- Passwort-Reset über kurzlebige, einmal verwendbare und ausschließlich
  gehashte Tokens; bestehende Sitzungen werden nach einem Reset widerrufen
- Konto- und Sicherheitsbereich mit Kennwortänderung und reauthentifizierter
  Kontolöschung inklusive projekt- und medienbezogenem Rückbau
- öffentlicher Produktstatus in README und Wiki: Live-Funktionen,
  Datenschutz-Kurzfassung und nächste Ausbaustufen

- initiale Projekt-, Dokumentations- und Wiki-Struktur
- Architekturprinzip für gemeinsame Renderer von Vorschau und Export
- grundlegendes, portables Datenmodell für Manuals
- Flutter-first-Zielarchitektur mit privatem API-Backend und MySQL/MariaDB
- Produkt-, Sicherheits-, Datenschutz- und Recherchegrundlage
- projektspezifische Security Policy und risikobasierte Release-Gates
- erste produktive Flutter-Webapp mit Landingpage, Login-Shell und Live-Smoke-Test
- Security-Header für Flutter-Frontend und PHP-API ergänzt
- lokales Grapes.js-Landing-CMS mit DE/EN-Struktur und verschlüsseltem API-Vertrag vorbereitet
- lokale Inter- und Space-Grotesk-Schriften sowie Light-/Dark-Theme ergänzt
- CMS-Migration 004 für Landingpage-Revisionen und Übersetzungseinträge produktiv
  angewendet; vorheriges Live-Backup und anschließender Tabellen-/Migrationscheck
  dokumentiert
- produktiver API-Konfigurationspfad außerhalb des Webroots abgesichert und
  `/api/health` erfolgreich geprüft
- Open Sans als vollständig lokal ausgelieferte UI-Schrift eingerichtet
- lokale Standardschrift-Auswahl mit Open Sans, Lato, Montserrat und
  Merriweather im Projektassistenten und Grapes.js-Stilbereich ergänzt
- kostenpflichtigen eigenen Font-Upload als gesperrte Pro-Erweiterung
  vorbereitet und die Sicherheitsanforderungen dokumentiert
- öffentlicher Landingpage-Footer mit Impressum, AGB, Datenschutz, Cookies,
  AI-Philosophie und Barrierefreiheit sowie klar markierten Entwürfen für
  Zahlung und Widerruf
- lokale Cookie-Einstellungen ohne Analyse- oder Marketing-Vorauswahl
- bedienbare Logo- und Referenzbildauswahl im Einrichtungsassistenten mit
  Dateiformat- und Größenprüfung
- sichtbare Möglichkeit, den optionalen Materialschritt zu überspringen und
  ihn später im Projektassistenten erneut zu öffnen

### Changed

- Flutter-Web-Releases bündeln CanvasKit nun verbindlich lokal und verwenden
  keine externe Renderer-CDN mehr
- Interaktionsfeedback verwendet nun den shader-unabhängigen Material-Ripple;
  dadurch bleiben Klickrückmeldungen in Light- und Darkmode sichtbar und die
  Flutter-Webtests laufen ohne GPU-Shader-Abhängigkeit zuverlässig durch
- Assistent, Projekt-Mediathek und Workflow-Karten verwenden für Light- und
  Darkmode ausschließlich semantische Theme-Farben; der eingeloggte Header hat
  einen eigenen Theme-Schalter vor den Benachrichtigungen
- Projektübersicht kennzeichnet gespeicherte externe Bildreferenzen
- Theme-Schalter leitet Icon und Beschriftung nun immer aus dem tatsächlich
  aktiven Flutter-Theme ab; die lokale Auswahl bleibt gerätebezogen gespeichert
- mobile Navigation rendert für „Konto“ einen eigenen Bereich statt des
  Projektassistenten
- Landingpage für Tablet- und Smartphone-Breiten neu skaliert: obere
  Ausrichtung, ruhigere Open-Sans-Typografie, lesbarere Zeilenhöhe und kompakte
  Vorteilsliste
- Projektübersicht und Einrichtungsassistent für schmale Smartphone-Ansichten
  ohne horizontale Überläufe angepasst
- nicht freigegebene Entwurfslinks für Zahlung und Widerruf aus dem
  öffentlichen Landingpage-Footer ausgeblendet

### Planned

- Editor-Shell mit Modulnavigator und Live-Vorschau
- erste Corporate-Design- und Social-Media-Module
- HTML- und PDF-Export
