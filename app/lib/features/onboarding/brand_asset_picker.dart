import 'brand_asset_picker_stub.dart'
    if (dart.library.js_interop) 'brand_asset_picker_web.dart'
    as platform;
import 'brand_asset_picker_types.dart';

export 'brand_asset_picker_types.dart';

BrandAssetPicker createBrandAssetPicker() => platform.createBrandAssetPicker();
