# Architektur

## Zielarchitektur

Der CI BUILDER ist eine **Flutter-Webapp mit privatem Server-Backend**. Flutter liefert Landingpage, Auth, Dashboard, Editor, Vorschau und Admin-Oberfläche. Das Backend erzwingt Zugriff, Rechte, Limits und Kaufansprüche; die Datenbank ist nie aus dem Browser erreichbar.

```text
Browser → Flutter Webapp → HTTPS / Same-Origin API → privates Backend
                                                   ├─ MySQL/MariaDB
                                                   └─ privater Datei-Storage
```

## Leitprinzipien

- **Content first:** Ein Manual ist strukturierte, portable Daten statt fest eingebauter Seiten.
- **Ein Renderer:** Vorschau, HTML-Export und PDF-Export verwenden dieselben Dokumentmodule.
- **Erweiterbar:** Neue Kapitel können ohne Umbau des Editors ergänzt werden.
- **Print-aware:** Layouts funktionieren auf Bildschirm und im definierten Druckformat.
- **Server entscheidet:** Berechtigungen, Projektslots und Käufe prüft ausschließlich das Backend.
- **Local assets:** Produkt-Fonts, Icons und eigene Medien werden lokal ausgeliefert. Keine Google-Font- oder Icon-CDNs.
- **Privacy by default:** Nur notwendige Daten erheben, standardmäßig privat halten und feste Löschfristen definieren.
- **Least Privilege:** Backoffice-Rollen sind serverseitige Capability-Bundles;
  Moderation sieht weder Zahlungsdaten noch private Projektmedien.
- **Entitlements statt Client-Flags:** Tarife und Speicherquoten werden nur
  aus einer serverseitigen, zeitlich begrenzten Berechtigung abgeleitet.

## Schichten

| Schicht | Verantwortung |
| --- | --- |
| `modules` | Definition und Rendering einzelner Manual-Kapitel |
| `editor` | Eingabe, Validierung, Sortierung und Projektverwaltung |
| `preview` | Bildschirm- und Druckansicht des Dokuments |
| `export` | Erzeugt autarke HTML-Dateien und PDF-Ausgaben |
| `shared` | Datenmodell, Tokens, Utilities und wiederverwendbare UI |

## Flutter und URLs

Die App erhält eine schlanke öffentliche Einstiegs-URL und eine Flutter-Shell. Sicherheit entsteht nicht durch das Verbergen von Routen, Dateinamen oder API-Aufrufen: Alles, was an einen Browser ausgeliefert wird, kann technisch eingesehen werden. Deshalb liegen keine Geheimnisse, Zugangsdaten, Preisentscheidungen oder Autorisierungsregeln im Flutter-Bundle. Der Server akzeptiert nur autorisierte Requests und liefert private Dateien ausschließlich nach Berechtigungsprüfung.

Flutter eignet sich besonders für die komplexe Single-Page-Editor-Erfahrung. Für eine rein textlastige, SEO-orientierte Marketingseite ist Flutter laut eigener Web-Dokumentation weniger ideal; die Landingpage wird daher bewusst schlank, schnell und semantisch geplant. [Flutter Web support](https://docs.flutter.dev/platform-integration/web)
