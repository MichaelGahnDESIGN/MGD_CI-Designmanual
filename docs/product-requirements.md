# Produktanforderungen — Michael Gahn DESIGN CI BUILDER

## Produktversprechen

Ein geführter, ästhetisch kompromissloser Editor erstellt aus Markenwissen ein lebendiges Designmanual und einen Social-Media-Codex. Inhalt, Regeln und Assets bleiben in einem Projekt; Vorschau, HTML-Ausgabe und PDF-Ausgabe zeigen dieselbe Wahrheit.

## Oberflächen

| Bereich | Aufgabe |
| --- | --- |
| Landingpage | Produkt erklären, Beispiele zeigen, Datenschutz/Impressum und Registrierung anbieten |
| Auth | Registrierung, E-Mail-Verifikation, Login, Passwort-Reset und optionale 2FA |
| Dashboard | Eigene Projekte, verbleibende Slots, Mediathek und Einstieg in den Assistenten |
| Assistent | Projektgrunddaten erfassen und eine editierbare Basis erzeugen |
| Editor | Kapitel, Inhalte, Regeln, Assets und Varianten erstellen |
| Vorschau | Responsives Manual und Druckansicht ohne Editor-Chrome |
| Admin | Nutzer, Rollen, Missbrauch, Entitlements, Vorlagen, Supportfälle und Audit-Events |
| Tarife & Store | Slots, Speicher und Funktionen transparent erklären; Freischaltung nur serverseitig nach Zahlung |

## Onboarding-Assistent

Der Assistent fragt nach Projektname, Firmenname, relevanten Firmendaten, Kurzbeschreibung, Logo und optionalem Referenzbild beziehungsweise Screenshot. Er erzeugt danach nur editierbare Vorschläge:

1. Farbpalette aus Logo/Referenzbild extrahieren und Kontraste bewerten.
2. Primär-, Sekundär- und Funktionsfarben als editierbare Tokens anlegen.
3. Eine geeignete lokale Typografie-Kombination aus der lizenzierten Font-Bibliothek vorschlagen.
4. Startstruktur und Kapitel passend zu Marke, digitalem Produkt oder Social Media auswählen.
5. Unsichere oder nicht ausreichende Kontrastwerte sichtbar markieren.

Die erste Ausbaustufe arbeitet ohne externe KI-Übertragung: Bildanalyse und Farbextraktion laufen lokal im Browser oder im eigenen Backend. Jede spätere KI-Funktion braucht eine separate Datenschutz-, Vertrags- und Transferprüfung.

## Freemium, Slots und geplante Tarife

Jedes bestätigte Konto erhält einen kostenlosen Projektslot mit 100 MB privatem
Medienspeicher. Ein zweiter kostenloser Slot kann nach einer bestätigten,
missbrauchsgeprüften Empfehlung gewährt werden. Ist kein Slot mehr frei,
erklärt die Plattform die verfügbaren Optionen statt ein Projekt nur still
abzuweisen.

| Angebot | Preis (Entwurf) | Enthalten |
| --- | ---: | --- |
| Kostenlos | 0 € | 1 Slot, 100 MB, Assistent, private Mediathek, Kern-Export |
| Slot+ | 19 € einmalig | +1 dauerhafter Slot und +100 MB privater Speicher |
| Studio | 12 €/Monat oder 120 €/Jahr | 5 Slots, 500 MB, Vorlagen und erweiterter Export |
| Agentur | 29 €/Monat oder 290 €/Jahr | 20 Slots, 1,5 GB, Teamzugänge und Vorlagenbibliothek |

Das ist ein Preisentwurf, kein aktives Verkaufsangebot. Die Kapazität bleibt
hart begrenzt: Bei ungefähr 6 GB Gesamtspeicher werden keine unbegrenzten
Medienpakete verkauft; mindestens 1 GB bleibt für Betrieb, Sicherungen und
Updates reserviert. Alle Limits und Entitlements werden ausschließlich auf dem
Server berechnet. Eine Clientanzeige oder ein Stripe-Rückgabewert allein kann
niemals Zugang freischalten.

Die wiederkehrenden Tarife und der Einmalkauf werden erst nach einer
Stripe-Integration mit Checkout, signierten Webhooks, idempotenter
Eventverarbeitung, Kündigung und Erstattungsprozess aktiviert. Bis dahin ist
die Tarifansicht rein informativ und erzeugt keine Kosten.

Ein Empfehlungslink enthält einen zufälligen, nicht erratbaren Code. Die Belohnung wird erst nach E-Mail-Verifikation des neu registrierten Kontos vergeben und durch Limits, Audit-Events und Missbrauchsregeln geschützt.

## Nichtziele für Version 1

- Kein frei zugänglicher Projekt- oder Asset-Link.
- Kein externer CDN-Zwang für Fonts oder Icons.
- Keine Zahlungskartendaten im eigenen System.
- Keine KI-Analyse von Kundendaten ohne gesonderte, verständliche Wahlmöglichkeit.
