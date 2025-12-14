import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/posts_controller.dart';
import 'package:loom_app/src/controllers/profiles_controller.dart';
import 'package:loom_app/src/models/post.dart';
import 'package:loom_app/src/pages/full_screen_post_page.dart';
import 'package:loom_app/src/widgets/expandable_text.dart';
import 'package:loom_app/src/widgets/path_image.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    final postsController = Get.find<PostsController>();
    final profilesController = Get.find<ProfilesController>();
    return Obx(() {
      final ThemeData sectionTheme = base;

      final items = postsController.savedPosts(includeClips: false);
      return Theme(
        data: sectionTheme,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
          itemCount: items.isEmpty ? 2 : items.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Saved',
                      style: sectionTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Library of posts you pinned for later.',
                      style: sectionTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            if (items.isEmpty) {
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No saved posts yet.',
                    style: sectionTheme.textTheme.bodyMedium?.copyWith(color: sectionTheme.colorScheme.onSurfaceVariant),
                  ),
                ),
              );
            }

            final Post post = items[index - 1];
            final author = profilesController.byId(post.authorId);
            final tag = post.tags.isNotEmpty ? post.tags.first : 'Saved';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                child: InkWell(
                  onTap: () => FullScreenPostPage.open(context, post.id),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sectionTheme.colorScheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      post.title,
                                      style: sectionTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'by ${author?.name ?? 'Unknown'}',
                                      style: sectionTheme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Obx(() {
                                final bool isPinned = postsController.isPinned(post.id);
                                return PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_horiz_rounded),
                                  onSelected: (value) {
                                    if (value == 'pin') {
                                      postsController.togglePinned(post.id);
                                      Get.snackbar(
                                        isPinned ? 'Unpinned' : 'Pinned',
                                        isPinned
                                            ? 'Post unpinned from your profile.'
                                            : 'Post pinned to your profile.',
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'pin',
                                      child: Text(isPinned ? 'Unpin' : 'Pin'),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (post.text.isNotEmpty)
                            ExpandableText(
                              text: post.text,
                              style: sectionTheme.textTheme.bodyLarge,
                              trimLines: 5,
                            ),
                          if (post.imageUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: PathImage(
                                    path: post.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Chip(
                                avatar: const Icon(Icons.bookmark_added_rounded, size: 16),
                                label: Text(tag),
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                              ),
                              Text(
                                'Saved ${post.timeAgoLabel}',
                                style: sectionTheme.textTheme.bodySmall?.copyWith(
                                  color: sectionTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}