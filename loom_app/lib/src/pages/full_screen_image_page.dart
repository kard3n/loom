import 'package:flutter/material.dart';
import 'package:loom_app/src/widgets/path_image.dart';

class FullScreenImagePage extends StatelessWidget {
  const FullScreenImagePage({super.key, required this.path});

  final String path;

  static void open(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FullScreenImagePage(path: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: SizedBox.expand(
                child: PathImage(path: path, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.75),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: theme.colorScheme.onSurface,
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Close',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
