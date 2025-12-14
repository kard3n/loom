import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/posts_controller.dart';
import 'package:loom_app/src/controllers/profiles_controller.dart';
import 'package:loom_app/src/models/post.dart';
import 'package:loom_app/src/models/profile.dart';
import 'package:loom_app/src/pages/profile_page.dart';
import 'package:loom_app/src/rust/api/simple.dart' as rust;

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profilesController = Get.find<ProfilesController>();
    final postsController = Get.find<PostsController>();
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Use the real ID from the controller
          final currentUserId = postsController.currentUserId.value;
          if (currentUserId.isNotEmpty) {
            _showSophisticatedPostSheet(context, currentUserId);
          } else {
            Get.snackbar("Error", "Please wait for login to finish");
          }
        },
        icon: const Icon(Icons.edit_rounded),
        label: const Text("New Post"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      // We wrap the body in Obx to listen for changes in currentUserId
      body: Obx(() {
        final currentUuid = postsController.currentUserId.value;

        // Try to resolve the current user profile from the controller.
        final Profile? me = currentUuid.isEmpty ? null : profilesController.byId(currentUuid);

        // If we don't have an ID yet, show loading
        if (currentUuid.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (me == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.person_outline_rounded, size: 56, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text('No profile found', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                    'Create a profile to start posting and seeing your feed.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final greeting = rust.greet(name: me.name);

        final profiles = profilesController.profiles.toList(growable: false);
        profiles.sort((a, b) => b.lastSeenAt.compareTo(a.lastSeenAt));

        final allPosts = postsController.posts;
        final topics = postsController.trendingTags(limit: 6);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: _HomeHeader(
                greeting: greeting,
                subtitle: 'Here is what your circles are sharing today.',
              ),
            ),
            SliverToBoxAdapter(
              child: _ProfilesSection(profiles: profiles),
            ),
            SliverToBoxAdapter(
              child: _TopicsSection(
                topics: topics,
                title: 'Billboard',
                seeAllLabel: 'See all',
              ),
            ),
            if (allPosts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No posts yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == allPosts.length - 1 ? 80 : 16),
                        child: _PostCard(
                          post: allPosts[index],
                          author: profilesController.byId(allPosts[index].authorId),
                        ),
                      );
                    },
                    childCount: allPosts.length,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  void _showSophisticatedPostSheet(BuildContext context, String authorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CreatePostSheetContent(authorId: authorId),
    );
  }
}

// --- SHEET CONTENT (Unchanged) ---
class _CreatePostSheetContent extends StatefulWidget {
  final String authorId;
  const _CreatePostSheetContent({required this.authorId});

  @override
  State<_CreatePostSheetContent> createState() => _CreatePostSheetContentState();
}

class _CreatePostSheetContentState extends State<_CreatePostSheetContent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  void _handlePost() {
    if (_titleController.text.trim().isNotEmpty ||
        _bodyController.text.trim().isNotEmpty) {
      Get.find<PostsController>().addPost(
          _titleController.text,
          _bodyController.text
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: bottomPadding + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              Text(
                "Create New Post",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              FilledButton.tonal(
                onPressed: _handlePost,
                child: const Text("Post"),
              ),
            ],
          ),
          const Divider(height: 30),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Title (optional)',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: theme.textTheme.titleMedium,
          ),
          const Divider(),
          Expanded(
            flex: 0,
            child: TextField(
              controller: _bodyController,
              autofocus: true,
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              minLines: 3,
              style: theme.textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'What would you like to post?',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Open image picker...')),
                  );
                },
                icon: Icon(Icons.image_outlined, color: theme.colorScheme.primary),
                tooltip: "Add Image",
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Open tag editor...')),
                  );
                },
                icon: Icon(Icons.tag, color: theme.colorScheme.primary),
                tooltip: "Add Tags",
              ),
              const Spacer(),
              Text(
                "0/280",
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ... (Keep existing _HomeHeader, _StoriesSection, _TopicsSection, _PostStat, _initial)

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.greeting, required this.subtitle});
  final String greeting;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Center(
              child: Icon(Icons.bolt_rounded, color: theme.colorScheme.onPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  greeting,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code_scanner_rounded)),
        ],
      ),
    );
  }
}

class _ProfilesSection extends StatelessWidget {
  const _ProfilesSection({required this.profiles});
  final List<Profile> profiles;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: 128,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: profiles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final Profile profile = profiles[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<ProfilePage>(
                  builder: (BuildContext _) => ProfilePage(friendName: profile.name),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: <Color>[theme.colorScheme.tertiary, theme.colorScheme.secondary],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface,
                      border: Border.all(color: theme.colorScheme.surface, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: profile.isCurrentUser
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Text(
                        _initial(profile.name),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: profile.isCurrentUser ? theme.colorScheme.onPrimary : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        profile.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.lastSeenLabel,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopicsSection extends StatelessWidget {
  const _TopicsSection({required this.topics, required this.title, required this.seeAllLabel});
  final List<String> topics;
  final String title;
  final String seeAllLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              TextButton(onPressed: () {}, child: Text(seeAllLabel)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topics.map((String topic) => Chip(label: Text('#$topic'), backgroundColor: theme.colorScheme.surface, side: BorderSide(color: theme.colorScheme.outlineVariant))).toList(),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.author});
  final Post post;
  final Profile? author;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final postsController = Get.find<PostsController>();
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Text(
                _initial(author?.name ?? '?'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(
              author?.name ?? 'Unknown',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('${author?.handle ?? ''} • ${post.timeAgoLabel}'.trim()),
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz_rounded),
            ),
          ),
          if (post.title.isNotEmpty && post.title != "Untitled")
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                post.text,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      final double? expectedBytes = loadingProgress.expectedTotalBytes?.toDouble();
                      final double loadedBytes = loadingProgress.cumulativeBytesLoaded.toDouble();
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(value: expectedBytes != null ? loadedBytes / expectedBytes : null),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Icon(Icons.broken_image_outlined, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            ),
          if (post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.tags.map((String tag) => Chip(label: Text('#$tag'), padding: const EdgeInsets.symmetric(horizontal: 4))).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Row(
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
          ),
        ],
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
    final ThemeData theme = Theme.of(context);
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20),
      label: Text(value.toString(), style: theme.textTheme.labelLarge),
    );
  }
}

String _initial(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) return '?';
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}