import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../util/image_store.dart';
import '../util/image_store_impl.dart';

class ImagesController extends GetxController {
  final ImageStore _store = ImageStoreImpl();

  Future<String?> pickAndStoreImage({
    String folder = 'images',
    String? preferredExtension,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final PlatformFile file = result.files.first;
    final Uint8List? bytes = file.bytes;

    if (bytes == null) {
      // Some platforms may not return bytes unless explicitly requested.
      // (We request withData:true, but still guard.)
      return null;
    }

    final String extension = (preferredExtension ?? _inferExtension(file)) ?? 'jpg';
    final String name = const Uuid().v4();

    final String? saved = await _store.saveImageBytes(
      bytes: bytes,
      extension: extension,
      folder: folder,
      fileName: name,
    );

    if (saved == null && kIsWeb) {
      // Can’t persist on web; keep it explicit.
      Get.snackbar('Unsupported', 'Saving images is not supported on web');
    }

    return saved;
  }

  String? _inferExtension(PlatformFile file) {
    final String? ext = file.extension;
    if (ext != null && ext.trim().isNotEmpty) return ext.trim();

    final String name = file.name;
    final int dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return null;
    return name.substring(dot + 1).trim();
  }
}
