import 'dart:typed_data';

import 'image_store.dart';

class ImageStoreImpl implements ImageStore {
  @override
  Future<String?> saveImageBytes({
    required Uint8List bytes,
    required String extension,
    required String folder,
    required String fileName,
  }) async {
    // Web has no writable app documents directory.
    return null;
  }
}
