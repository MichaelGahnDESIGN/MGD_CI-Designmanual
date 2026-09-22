import 'brand_asset_picker_types.dart';

BrandAssetPicker createBrandAssetPicker() => const _UnsupportedAssetPicker();

class _UnsupportedAssetPicker implements BrandAssetPicker {
  const _UnsupportedAssetPicker();

  @override
  Future<BrandAssetSelection?> pick(BrandAssetKind kind) async => null;
}
