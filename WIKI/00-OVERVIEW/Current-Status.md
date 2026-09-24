# Aktueller Produktstand

Stand: 24. September 2026

## Bereits vorhanden

Die Live-App unter `ci.michael-gahn.de` bietet eine zweisprachige Landingpage,
einen gespeicherten Light-/Dark-Mode, E-Mail-Registrierung und Login,
Passwort-Änderung, Benutzerrollen, einen kostenlosen Projektplatz und einen
geführten Projekteinrichtungsassistenten. Der eingeloggte Header enthält den
Theme-Schalter direkt vor den Benachrichtigungen. Optionale Logo- und
Referenzbilder können privat hochgeladen oder als öffentliche HTTPS-Referenz
eingebettet werden. Die Mediathek ist pro Benutzer und Projekt getrennt.

Die Kontoansicht zeigt den serverseitig berechneten Slot- und
Medienspeicherverbrauch. Die Tarifansicht enthält Free, Creator, Studio und
Ultimate; bei jährlicher Zahlung wird ein rechnerisch echter Preisvorteil
angezeigt. Alle vorhandenen Grundfunktionen bleiben in Free. Keiner der
kostenpflichtigen Tarife ist derzeit buchbar: Erst ein geprüfter Stripe-
Testkatalog, signierte Webhooks und ein serverseitiges Entitlement dürfen
Rechte freischalten oder Kosten auslösen.

Das vorbereitete Backoffice trennt Rollen strikt: Moderator:innen dokumentieren
und bearbeiten Fälle, ohne Zahlungsübersichten, E-Mail-Adressen, Medien oder
Kontorechte zu sehen. Admins erhalten nach Migration zusätzliche,
reauthentifizierte Schnittstellen für Tarife, Zahlungsstatus, Rollen und
Kontostatus; jede privilegierte Handlung wird verschlüsselt auditierbar
protokolliert.

Open Sans sowie die für Flutter Web benötigten Ressourcen werden lokal ausgeliefert. Die öffentlichen Seiten enthalten Impressum, AGB, Datenschutz, Cookie-Einstellungen, AI-Philosophie und Barrierefreiheit. Externes Tracking ist nicht eingebunden.

## Datenschutz und Sicherheit

Zugangsdaten und Infrastruktur-Parameter liegen ausschließlich in einer nicht
versionierten `.env`-Datei. Passwörter werden niemals im Client oder Repository
gespeichert, sondern serverseitig gehasht. Jede Projekt-, Medien- und
Administrationsanfrage braucht eine serverseitige Berechtigungsprüfung.
Uploads werden nach Typ, Größe und tatsächlichem Bildinhalt eingeschränkt und
außerhalb des Webroots gespeichert. Externe Bildreferenzen werden verschlüsselt
gespeichert und nie serverseitig abgerufen.

## Nächste Schritte

1. Designmanual-Editor mit Bereichen für Marke, Farbe, Typografie, Bildwelt, Tonalität und Social Media.
2. Export als eigenständiges HTML-Projekt und als PDF.
3. Administrierbare Landingpage-Inhalte und Übersetzungen.
4. Kontrollierte Live-Migration `007_backoffice_billing_moderation` mit Backup,
   lesendem Vorabcheck und Funktionsprüfung.
5. Stripe-Testkatalog, signierte Webhooks, idempotente Entitlements, Kündigung
   und Erstattung vor Aktivierung von Abonnements.
