# Produktanforderungen — Michael Gahn DESIGN CI BUILDER

## Produktversprechen

Ein geführter, ästhetisch kompromissloser Editor erstellt aus Markenwissen ein lebendiges Designmanual und einen Social-Media-Codex. Inhalt, Regeln und Assets bleiben in einem Projekt; Vorschau, HTML-Ausgabe und PDF-Ausgabe zeigen dieselbe Wahrheit.

## Oberflächen

| Bereich | Aufgabe |
| --- | --- |
| Landingpage | Produkt erklären, Beispiele zeigen, Datenschutz/Impressum und Registrierung anbieten |
| Auth | Registrierung, E-Mail-Verifikation, Login, Passwort-Reset und optionale 2FA |
| Dashboard | Projekte, verbleibende Slots, Vorlagen, Empfehlungsstatus und Kaufansprüche |
| Assistent | Projektgrunddaten erfassen und eine editierbare Basis erzeugen |
| Editor | Kapitel, Inhalte, Regeln, Assets und Varianten erstellen |
| Vorschau | Responsives Manual und Druckansicht ohne Editor-Chrome |
| Admin | Nutzer, Rollen, Missbrauch, Entitlements, Vorlagen, Supportfälle und Audit-Events |
| Store (später) | Einmalige Erweiterungen kaufen und dauerhaft als Entitlement freischalten |

## Onboarding-Assistent

Der Assistent fragt nach Projektname, Firmenname, relevanten Firmendaten, Kurzbeschreibung, Logo und optionalem Referenzbild beziehungsweise Screenshot. Er erzeugt danach nur editierbare Vorschläge:

1. Farbpalette aus Logo/Referenzbild extrahieren und Kontraste bewerten.
2. Primär-, Sekundär- und Funktionsfarben als editierbare Tokens anlegen.
3. Eine geeignete lokale Typografie-Kombination aus der lizenzierten Font-Bibliothek vorschlagen.
4. Startstruktur und Kapitel passend zu Marke, digitalem Produkt oder Social Media auswählen.
5. Unsichere oder nicht ausreichende Kontrastwerte sichtbar markieren.

Die erste Ausbaustufe arbeitet ohne externe KI-Übertragung: Bildanalyse und Farbextraktion laufen lokal im Browser oder im eigenen Backend. Jede spätere KI-Funktion braucht eine separate Datenschutz-, Vertrags- und Transferprüfung.

## Freemium ohne Abo

- Jedes bestätigte Konto erhält genau einen kostenlosen Projektslot.
- Ein zweiter Slot wird erst nach einer bestätigten, missbrauchsgeprüften Empfehlung gewährt.
- Käufe sind dauerhafte, einzeln buchbare Entitlements – keine Abonnementrechte.
- Die Slots und Entitlements prüft ausschließlich der Server.

Ein Empfehlungslink enthält einen zufälligen, nicht erratbaren Code. Die Belohnung wird erst nach E-Mail-Verifikation des neu registrierten Kontos vergeben und durch Limits, Audit-Events und Missbrauchsregeln geschützt.

## Nichtziele für Version 1

- Kein frei zugänglicher Projekt- oder Asset-Link.
- Kein externer CDN-Zwang für Fonts oder Icons.
- Keine Zahlungskartendaten im eigenen System.
- Keine KI-Analyse von Kundendaten ohne gesonderte, verständliche Wahlmöglichkeit.
