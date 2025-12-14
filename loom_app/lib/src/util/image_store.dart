import 'dart:typed_data';

/// Saves image bytes and returns a persistent path string (or `null` if unsupported).
abstract interface class ImageStore {
  Future<String?> saveImageBytes({
    required Uint8List bytes,
    required String extension,
    required String folder,
    required String fileName,
  });
}
