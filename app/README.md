# CI BUILDER Flutter Webapp

Die App ist die öffentliche Landingpage, Authentifizierungsoberfläche und
Workspace-Shell des Michael Gahn DESIGN CI BUILDER.

## Lokal prüfen

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Die HTTP-Aufrufe nutzen absichtlich relative `/api/...`-Pfade. Dadurch bleiben
API-Host, Datenbank und Verschlüsselungsschlüssel außerhalb des Flutter-Bundles.
Die API- und Berechtigungslogik liegt ausschließlich unter `../backend/`.
