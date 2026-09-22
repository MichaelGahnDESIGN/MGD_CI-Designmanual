import 'dart:typed_data';

/// Die beiden optionalen Materialarten des Einrichtungsassistenten.
enum BrandAssetKind { logo, referenceImage }

/// Datenschutzfreundliche Metadaten einer lokal ausgewählten Datei.
///
/// Die Datei wird in diesem Zwischenstand weder hochgeladen noch dauerhaft im
/// Browser gespeichert. So kann die UI bereits bedient werden, ohne einen noch
/// nicht vorhandenen privaten Upload-Endpunkt vorzutäuschen.
class BrandAssetSelection {
  const BrandAssetSelection({
    required this.name,
    required this.sizeBytes,
    required this.mimeType,
    required this.bytes,
  });

  final String name;
  final int sizeBytes;
  final String mimeType;
  /// Nur im Arbeitsspeicher bis zum geschützten Projekt-Upload vorhanden.
  final Uint8List bytes;
}

/// Austauschbare Schnittstelle, damit Widget-Tests keinen echten Dateidialog
/// öffnen müssen und ein späterer geschützter Upload ergänzt werden kann.
abstract interface class BrandAssetPicker {
  Future<BrandAssetSelection?> pick(BrandAssetKind kind);
}

/// Erwarteter, nutzerverständlich anzuzeigender Fehler der Dateiauswahl.
class BrandAssetPickerException implements Exception {
  const BrandAssetPickerException(this.message);

  final String message;

  @override
  String toString() => message;
}
