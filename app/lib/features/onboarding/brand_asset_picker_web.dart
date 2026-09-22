import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'brand_asset_picker_types.dart';

BrandAssetPicker createBrandAssetPicker() => const _WebBrandAssetPicker();

class _WebBrandAssetPicker implements BrandAssetPicker {
  const _WebBrandAssetPicker();

  // SVG wird bewusst nicht direkt verarbeitet: nicht vertrauenswürdige SVGs
  // können aktive Inhalte enthalten. Für den Start nur serverseitig geprüfte Rasterbilder.
  static const _logoExtensions = {'png', 'jpg', 'jpeg', 'webp'};
  static const _referenceExtensions = {'png', 'jpg', 'jpeg', 'webp'};
  static const _logoLimitBytes = 5 * 1024 * 1024;
  static const _referenceLimitBytes = 10 * 1024 * 1024;

  @override
  Future<BrandAssetSelection?> pick(BrandAssetKind kind) async {
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..multiple = false
      ..accept = kind == BrandAssetKind.logo
          ? '.png,.jpg,.jpeg,.webp,image/png,image/jpeg,image/webp'
          : '.png,.jpg,.jpeg,.webp,image/png,image/jpeg,image/webp';

    // Wir warten auf eine echte Auswahl oder einen expliziten Abbruch. Ein
    // Zeitlimit wäre hier ein Bedienfehler: Menschen brauchen regelmäßig
    // länger als wenige hundert Millisekunden, um eine Datei auszuwählen.
    final completed = Completer<void>();
    final listener = ((web.Event _) {
      if (!completed.isCompleted) completed.complete();
    }).toJS;
    input.addEventListener('change', listener);
    input.addEventListener('cancel', listener);
    input.click();
    await completed.future;
    input.removeEventListener('change', listener);
    input.removeEventListener('cancel', listener);

    final file = input.files?.item(0);
    if (file == null) return null;

    final extension = file.name.contains('.')
        ? file.name.split('.').last.toLowerCase()
        : '';
    final allowed = kind == BrandAssetKind.logo
        ? _logoExtensions
        : _referenceExtensions;
    final limit = kind == BrandAssetKind.logo
        ? _logoLimitBytes
        : _referenceLimitBytes;

    if (!allowed.contains(extension)) {
      throw const BrandAssetPickerException(
        'Dieses Dateiformat wird hier noch nicht unterstützt.',
      );
    }
    if (file.size > limit) {
      throw BrandAssetPickerException(
        kind == BrandAssetKind.logo
            ? 'Das Logo darf höchstens 5 MB groß sein.'
            : 'Das Referenzbild darf höchstens 10 MB groß sein.',
      );
    }

    final buffer = await file.arrayBuffer().toDart;
    return BrandAssetSelection(
      name: file.name,
      sizeBytes: file.size,
      mimeType: file.type,
      bytes: Uint8List.view(buffer.toDart),
    );
  }
}
