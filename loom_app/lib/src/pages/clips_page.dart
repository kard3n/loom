import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/posts_controller.dart';
import 'package:loom_app/src/controllers/profiles_controller.dart';
import 'package:loom_app/src/models/post.dart';

class ClipsPage extends StatelessWidget {
  const ClipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final postsController = Get.find<PostsController>();
    final profilesController = Get.find<ProfilesController>();
    return Obx(() {
      final clips = postsController.clips();
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
        itemCount: clips.isEmpty ? 2 : clips.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Fresh clips',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            );
          }

          if (clips.isEmpty) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No clips yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            );
          }
          final Post clip = clips[index - 1];
          final author = profilesController.byId(clip.authorId);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          clip.imageUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(Icons.broken_image_outlined, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.inverseSurface.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            clip.clipDurationLabel ?? '',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onInverseSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: IconButton.filled(
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.85),
                            foregroundColor: theme.colorScheme.onSurface,
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          clip.text,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${author?.name ?? 'Unknown'} • ${clip.timeAgoLabel} • ${clip.clipViewsLabel ?? ''}'.trim(),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
