# Manual-Datenmodell

Ein Projekt besteht aus Metadaten, einem Theme und einer sortierten Liste von Modulen.

```json
{
  "version": "0.1",
  "project": { "name": "Beispielmarke", "client": "Musterkunde", "locale": "de-DE" },
  "theme": { "primaryColor": "#121212", "accentColor": "#C8FF00" },
  "modules": [{ "id": "brand-core", "type": "brandCore", "title": "Markenkern", "content": {} }]
}
```

Die konkrete Schema-Validierung wird mit dem Application-Scaffold ergänzt. Projekte und Module erhalten eine stabile UUIDv7 als `id`, einen Typ und ausschließlich typspezifische Inhalte in `content`.
