# Daten, Sicherheit und Datenschutz

> Dieses Dokument ist eine technische Arbeitsgrundlage, keine Rechtsberatung. Vor dem Launch werden Verarbeitungsverzeichnis, Datenschutzerklärung, Auftragsverarbeitungsverträge, Löschkonzept und die konkrete Risikobewertung rechtlich geprüft.

## Datenbankentscheidung

**Für dieses Produkt ist eine relationale Serverdatenbank erforderlich.** MySQL oder MariaDB ist eine passende Wahl – nicht weil Flutter sie benötigt, sondern weil Konten, Rechte, Projekte, Limits, Empfehlungsboni und spätere Käufe zuverlässig, transaktional und revisionsfähig gespeichert werden müssen.

Keine Datenbank wäre nur für einen rein lokalen, anonymen Einzelnutzer-Editor vertretbar. Sie kann weder Login und Passwort-Reset noch E-Mail-Verifikation, 2FA, Adminrechte, Projektslots, Referral-Abuse-Schutz oder Stripe-Entitlements sicher umsetzen.

## Minimales Datenmodell

Alle fachlichen Entitäten erhalten eine serverseitig erzeugte, nicht erratbare **UUIDv7** als primären Schlüssel. Die UUID wird als `BINARY(16)` gespeichert und nur an API-Grenzen im üblichen UUID-Format dargestellt. Laufende numerische IDs, Namen, E-Mail-Adressen und Dateipfade sind keine Berechtigungsnachweise und werden nicht als öffentliche Identifikatoren verwendet.

| Bereich | Serverdaten |
| --- | --- |
| Identity | Konto, normalisierte E-Mail, Passwort-Hash, Verifikationsstatus, Rollen |
| Security | Session-/Refresh-Token-Hashes, 2FA-Secret verschlüsselt, Recovery-Code-Hashes, Rate-Limits, Audit-Events |
| Projects | Eigentümer:in, Projektdaten, Manual-JSON, Versionen, Freigabestatus |
| Files | Asset-Metadaten, Eigentümer:in, Speicherreferenz, MIME-Typ, Größenlimit und Prüfsumme |
| Freemium | Slot-Entitlements, Referral-Code-Hash, Bestätigungs- und Missbrauchsstatus |
| Commerce | Produktkatalog, Kaufreferenz, Stripe-Event-ID, dauerhaftes Entitlement und Erstattungsstatus |
| Privacy | Einwilligungsprotokoll, Löschauftrag, Exportauftrag und Aufbewahrungsfristen |

Dateien liegen außerhalb des Webroots oder in privatem Object Storage. Der Server gibt sie nur nach einer Rechteprüfung aus; direkte Dateipfade werden nie als Berechtigung verwendet.

## Aktueller Stand der Materialauswahl

Der Einrichtungsassistent kann Logo- und Referenzdateien bereits lokal im
Browser auswählen und vorab nach Dateiendung und Größe prüfen. In diesem
Zwischenstand werden nur Dateimetadaten für die laufende Sitzung vorgemerkt;
es findet noch kein dauerhafter Upload statt. Das verhindert, dass die
Oberfläche eine vermeintlich sichere Speicherung verspricht, bevor der private
Upload-Endpunkt mit Projektberechtigung, Signaturprüfung und sicherem Storage
fertiggestellt ist.

Die dauerhafte Speicherung wird erst aktiviert, wenn serverseitig mindestens
Projektmitgliedschaft, tatsächlicher MIME-Typ, Größenlimit, nicht ausführbare
Auslieferung und privater Speicher geprüft sind. Der optionale Schritt darf
übersprungen und später erneut geöffnet werden.

## Verschlüsselung und Hashing

„Alles verschlüsseln“ ist nicht die richtige Sicherheitsregel: Passwörter und Recovery-Codes müssen **gehasht**, nicht entschlüsselbar gespeichert werden. Verschlüsselt werden Daten, die der Dienst später wieder lesen muss und die besonders schützenswert sind.

- Passwörter: Argon2id-Hash mit individuellem Salt; nie verschlüsseln oder im Klartext loggen.
- Sitzungs-, Reset-, E-Mail-Verifikations- und Referral-Tokens: nur als Hash speichern; im Klartext nur einmal an den Browser oder E-Mail-Flow geben.
- 2FA-TOTP-Secret: anwendungsseitig mit AEAD (z. B. AES-256-GCM) verschlüsseln; zugehörige Schlüssel liegen ausschließlich außerhalb von Repository und Datenbank.
- Manual-Inhalte, Firmenangaben und Asset-Metadaten: je nach Sensitivität anwendungsseitig verschlüsseln; für die erste Version mindestens verschlüsselte Datenträger, TLS und strikte Zugriffskontrolle, für sensible Kundenprojekte zusätzlich Feld-/Dokumentverschlüsselung.
- Backups: verschlüsselt, mit getrenntem Schlüssel, Zugriffsliste, Aufbewahrungszeit und regelmäßigem Wiederherstellungstest.

Schlüsselrotation wird von Anfang an ermöglicht: verschlüsselte Daten tragen eine Schlüsselversion, sodass sie kontrolliert neu verschlüsselt werden können. Ein Schlüssel gehört nie in Flutter, SQL-Migrationen, Git oder die MariaDB selbst.

## Authentifizierung und Rechte

- Passwörter ausschließlich mit einem modernen, absichtlich langsamen Passwort-Hash speichern; niemals reversible Verschlüsselung oder Klartext.
- E-Mail-Adresse vor voller Nutzung verifizieren; Passwort-Reset- und Verifikations-Tokens nur gehasht, kurzlebig und einmalig speichern.
- Sitzungen mit sicheren, HttpOnly-, Secure- und SameSite-Cookies führen; Tokens nicht dauerhaft in `localStorage` speichern.
- 2FA als TOTP/WebAuthn anbieten, Recovery-Codes nur gehasht ablegen und für Admins verpflichtend machen. Das BSI empfiehlt 2FA ausdrücklich, insbesondere bei weitreichenden Konten. [BSI: Zwei-Faktor-Authentisierung](https://www.bsi.bund.de/DE/Themen/Verbraucherinnen-und-Verbraucher/Informationen-und-Empfehlungen/Cyber-Sicherheitsempfehlungen/Accountschutz/Zwei-Faktor-Authentisierung/zwei-faktor-authentisierung.html)
- Jede private API serverseitig mit Account- und Rollenprüfung absichern; Adminrechte niemals aus einem Flutter-Flag ableiten.
- Login, Reset, Referral und Export rate-limitieren; Audit-Events datensparsam und manipulationsarm erfassen.

### Kennwort-Reset

Der Reset-Antrag antwortet unabhängig vom Kontostatus gleich, um keine
E-Mail-Adressen zu bestätigen. Für existierende aktive Konten wird ein
kryptographisch zufälliger Token erzeugt, nur als HMAC-Hash gespeichert und
nach 30 Minuten oder der ersten Verwendung ungültig. Ein erfolgreicher Reset
widerruft alle bestehenden Sitzungen. Der Link selbst gehört ausschließlich in
eine E-Mail; weder Token noch Zieladresse erscheinen in Browserantworten oder
Anwendungslogs.

## Sichere Live-Migration

Die erste Migration wird idempotent und in einer `schema_migrations`-Tabelle protokolliert. Vor dem ersten produktiven Lauf gelten: verschlüsseltes Backup, lesender Verbindungscheck, dry-run der Migration, dokumentierter Rückweg und ausdrückliche Freigabe. Es werden keine Testkonten oder Beispieldaten in der Live-Datenbank angelegt.

## Datenschutz by design

Die DSGVO verlangt unter anderem Zweckbindung, Datenminimierung und Speicherbegrenzung sowie geeignete technische und organisatorische Maßnahmen. Datenschutz durch Technikgestaltung und datenschutzfreundliche Voreinstellungen sind ausdrücklich vorgesehen. [DSGVO Art. 5, 25 und 32](https://eur-lex.europa.eu/legal-content/EN/ALL/?uri=celex%3A32016R0679)

Für CI BUILDER heißt das: private Projekte standardmäßig privat, keine Analyse- oder Marketing-Cookies vor Einwilligung, klare Zwecke pro Datenkategorie, Lösch-/Exportfunktion, dokumentierte Auftragsverarbeiter und getrennte Umgebungen für Entwicklung und Produktion. Der Zugriff auf nicht zwingend erforderliche Browser-Speichertechniken ist nach § 25 TDDDG grundsätzlich einwilligungspflichtig; technisch notwendige Speicherung ist ausgenommen. [§ 25 TDDDG](https://www.gesetze-im-internet.de/ttdsg/__25.html)

## Betriebsschutz

- HTTPS/TLS überall, HSTS, restriktive Content-Security-Policy, sichere Header und keine fremden Script-CDNs.
- Uploads per Dateigröße, MIME-Signatur und Malware-Scan prüfen; keine Nutzerdatei ausführbar ausliefern.
- Verschlüsselte Backups, Wiederherstellungstests, getrennte Secrets und regelmäßige Dependency-Updates.
- Sicherheitslogs ohne Manual-Inhalte oder Zugangsdaten; definierte Incident- und 72-Stunden-Bewertungskette.
- Vor produktiver KI-Funktion eine separate Datenschutz-Folgenabschätzung prüfen, wenn die Risikobewertung dies nahelegt.

## Stripe später

Für Einmalkäufe verwenden wir Stripe Checkout, damit Kartendaten direkt bei Stripe verarbeitet werden und nicht durch App oder Server fließen. Stripe verlangt trotzdem eine eigene PCI-Betrachtung; der Server verifiziert jede Webhook-Signatur und schreibt Entitlements erst nach bestätigtem Ereignis. [Stripe Security Guide](https://docs.stripe.com/security/guide) · [Stripe Webhook-Signaturen](https://docs.stripe.com/webhooks/signature)
