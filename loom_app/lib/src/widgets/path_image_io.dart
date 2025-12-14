import 'dart:io';

import 'package:flutter/material.dart';

class PathImage extends StatelessWidget {
  const PathImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final Uri? uri = Uri.tryParse(path);
    final String scheme = (uri?.scheme ?? '').toLowerCase();

    if (scheme == 'http' || scheme == 'https') {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) return child;
          final double? expectedBytes =
              loadingProgress.expectedTotalBytes?.toDouble();
          final double loadedBytes =
              loadingProgress.cumulativeBytesLoaded.toDouble();
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              value: expectedBytes != null ? loadedBytes / expectedBytes : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Image.file(
      File(path),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
