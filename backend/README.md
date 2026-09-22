# Backend

Das Backend ist die alleinige Vertrauensgrenze für Identität, Rechte, Freemium-Limits, Projektzugriff, Uploads, Exporte und spätere Stripe-Entitlements. Flutter kommuniziert nur per HTTPS mit diesem API; es erhält keine Datenbank- oder Verschlüsselungsschlüssel.

## Migrationen

Die SQL-Migrationen sind fortlaufend nummeriert und idempotent. Vor jedem Lauf auf Live gilt:

1. Datenbankstruktur lesend prüfen.
2. Verschlüsseltes Backup erstellen oder bei leerer Datenbank den leeren Ausgangszustand dokumentieren.
3. Migration lokal auf Syntax und Inhalt prüfen.
4. SQL exakt einmal ausführen und `schema_migrations` kontrollieren.
5. Keine Test-Accounts oder Testdaten auf Live anlegen.
