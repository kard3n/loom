import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/posts_controller.dart';
import 'package:loom_app/src/controllers/profiles_controller.dart';
import 'package:loom_app/src/models/post.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    final postsController = Get.find<PostsController>();
    final profilesController = Get.find<ProfilesController>();
    return Obx(() {
      final ThemeData sectionTheme = base;

      final items = postsController.posts.where((p) => !p.isClip).toList(growable: false);
      return Theme(
        data: sectionTheme,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
          itemCount: items.length + 1,
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

            final Post post = items[index - 1];
            final author = profilesController.byId(post.authorId);
            final tag = post.tags.isNotEmpty ? post.tags.first : 'Saved';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                child: Container(
                  decoration: BoxDecoration(
                    color: sectionTheme.colorScheme.primary.withOpacity(0.06),
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
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.more_horiz_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          post.text,
                          style: sectionTheme.textTheme.bodyLarge,
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
                              'Saved ${post.timeAgoLabel} ago',
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
            );
          },
        ),
      );
    });
  }
}