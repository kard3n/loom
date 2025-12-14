import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'image_store.dart';

class ImageStoreImpl implements ImageStore {
  @override
  Future<String?> saveImageBytes({
    required Uint8List bytes,
    required String extension,
    required String folder,
    required String fileName,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/$folder');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final String sanitizedExt = extension.startsWith('.')
        ? extension.substring(1)
        : extension;

    final String fullPath = '${imagesDir.path}/$fileName.$sanitizedExt';
    final file = File(fullPath);
    await file.writeAsBytes(bytes, flush: true);
    return fullPath;
  }
}
