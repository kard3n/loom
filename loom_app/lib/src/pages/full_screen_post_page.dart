import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/posts_controller.dart';
import 'package:loom_app/src/controllers/profiles_controller.dart';
import 'package:loom_app/src/models/post.dart';
import 'package:loom_app/src/models/profile.dart';
import 'package:loom_app/src/pages/full_screen_image_page.dart';
import 'package:loom_app/src/widgets/path_image.dart';

class FullScreenPostPage extends StatelessWidget {
  const FullScreenPostPage({super.key, required this.postId});

  final String postId;

  static Future<void> open(BuildContext context, String postId) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FullScreenPostPage(postId: postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PostsController postsController = Get.find<PostsController>();
    final ProfilesController profilesController = Get.find<ProfilesController>();

    return Obx(() {
      Post? post;
      for (final p in postsController.posts) {
        if (p.id == postId) {
          post = p;
          break;
        }
      }

      final Widget content = post == null
          ? Center(
              child: Text(
                'Post not found',
                style: theme.textTheme.titleMedium,
              ),
            )
          : _PostBody(
              post: post,
              author: profilesController.byId(post.authorId),
            );

      final body = SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 72, 16, 24),
          child: content,
        ),
      );

      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Stack(
          children: <Widget>[
            Positioned.fill(child: body),
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PostBody extends StatelessWidget {
  const _PostBody({required this.post, required this.author});

  final Post post;
  final Profile? author;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PostsController postsController = Get.find<PostsController>();

    final String authorName = author?.name ?? 'Unknown';
    final String authorHandle = author?.handle ?? '';
    final String? authorPicture = author?.profilePicture;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: GestureDetector(
                  onTap: (authorPicture != null && authorPicture.trim().isNotEmpty)
                      ? () => FullScreenImagePage.open(context, authorPicture)
                      : null,
                  child: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    child: (authorPicture != null && authorPicture.trim().isNotEmpty)
                        ? ClipOval(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: PathImage(
                                path: authorPicture,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Text(
                            _initial(authorName),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                title: Text(
                  authorName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${authorHandle.isEmpty ? '' : authorHandle} • ${post.timeAgoLabel}'.trim()),
                trailing: Obx(() {
                  final bool isPinned = postsController.isPinned(post.id);
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded),
                    onSelected: (value) {
                      if (value == 'pin') {
                        postsController.togglePinned(post.id);
                        Get.snackbar(
                          'Pinned',
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
              ),
              if (post.title.isNotEmpty && post.title != 'Untitled')
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    post.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              if (post.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(post.text, style: theme.textTheme.bodyLarge),
                ),
              if (post.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: GestureDetector(
                    onTap: () => FullScreenImagePage.open(context, post.imageUrl!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: PathImage(path: post.imageUrl!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              if (post.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: post.tags
                        .map(
                          (String tag) => Chip(
                            label: Text('#$tag'),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _PostStat(icon: Icons.favorite_border_rounded, value: post.likes),
                  _PostStat(icon: Icons.mode_comment_outlined, value: post.comments),
                  _PostStat(icon: Icons.repeat_rounded, value: post.shares),
                  Obx(() {
                    final isSaved = postsController.isSaved(post.id);
                    return IconButton(
                      onPressed: () => postsController.toggleSaved(post.id),
                      icon: Icon(
                        isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_outline_rounded,
                      ),
                      tooltip: isSaved ? 'Unsave' : 'Save',
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostStat extends StatelessWidget {
  const _PostStat({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 20),
        const SizedBox(width: 6),
        Text(value.toString()),
      ],
    );
  }
}

String _initial(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) return '?';
  return trimmed.characters.first.toUpperCase();
}
