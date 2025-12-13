import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/posts_controller.dart';
import 'package:loom_app/src/controllers/profiles_controller.dart';
import 'package:loom_app/src/models/post.dart';
import 'package:loom_app/src/models/profile.dart';
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
          final me = profilesController.currentUser();
          if (me != null) {
            _showSophisticatedPostSheet(context, me.id);
          }
        },
        icon: const Icon(Icons.edit_rounded),
        label: const Text("New Post"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Obx(() {
        final Profile me = profilesController.currentUser() ??
            const Profile(
              id: 'me',
              name: 'Creator',
              handle: '@creator',
              status: '',
              bio: '',
              lastSeenLabel: '',
              isCurrentUser: true,
            );

        final greeting = rust.greet(name: me.name);

        final stories = <Profile>[
          me,
          ...profilesController.profiles.where((p) => !p.isCurrentUser)
        ];
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
              child: _StoriesSection(stories: stories),
            ),
            SliverToBoxAdapter(
              child: _TopicsSection(
                topics: topics,
                title: 'Trending circles',
                seeAllLabel: 'See all',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: index == allPosts.length - 1 ? 80 : 16),
                      child: _PostCard(
                          post: allPosts[index],
                          author: profilesController
                              .byId(allPosts[index].authorId)),
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
      isScrollControlled: true, // Full screen capability
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CreatePostSheetContent(authorId: authorId),
    );
  }
}

// --- UPDATED SHEET CONTENT ---
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
    // Check if at least one field has text
    if (_titleController.text.trim().isNotEmpty ||
        _bodyController.text.trim().isNotEmpty) {

      Get.find<PostsController>().addPost(
          _titleController.text,
          _bodyController.text,
          widget.authorId
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
          // --- Header ---
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

          // --- Title Input ---
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

          // --- Body Input ---
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

          // --- Actions Row (Images, Tags) ---
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Placeholder for Image Picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Open image picker...')),
                  );
                },
                icon: Icon(Icons.image_outlined, color: theme.colorScheme.primary),
                tooltip: "Add Image",
              ),
              IconButton(
                onPressed: () {
                  // Placeholder for Tag Editor
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Open tag editor...')),
                  );
                },
                icon: Icon(Icons.tag, color: theme.colorScheme.primary),
                tooltip: "Add Tags",
              ),
              const Spacer(),
              Text(
                "0/280", // You can wire this up to _bodyController.text.length later
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ... (Keep existing _HomeHeader, _StoriesSection, etc.)
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
            child: const Center(
              child: Icon(Icons.bolt_rounded, color: Colors.white),
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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.qr_code_scanner_rounded),
          ),
        ],
      ),
    );
  }
}

class _StoriesSection extends StatelessWidget {
  const _StoriesSection({required this.stories});

  final List<Profile> stories;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final Profile story = stories[index];

          return GestureDetector(
            onTap: () {
              // Note: You can also open the new sheet from here if you want
              if (story.isCurrentUser) {
                // _showSophisticatedPostSheet(context, story.id); // Optional: Trigger from avatar too
              } else {
                print("View story for ${story.name}");
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: story.isCurrentUser
                        ? LinearGradient(
                      colors: <Color>[
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    )
                        : const LinearGradient(
                      colors: <Color>[Color(0xFFFA709A), Color(0xFFFEE140)],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: story.isCurrentUser
                          ? theme.colorScheme.primary
                          : const Color(0xFFE0E6F5),
                      child: story.isCurrentUser
                          ? const Icon(Icons.add_rounded, color: Colors.white)
                          : Text(
                        _initial(story.name),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 72,
                  child: Text(
                    story.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
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
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton(onPressed: () {}, child: Text(seeAllLabel)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topics
                .map(
                  (String topic) => Chip(
                label: Text('#$topic'),
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            )
                .toList(),
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
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
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

          // --- NEW: Title Section ---
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

          // ... (Rest of the widget: images, tags, stats button row) ...
          if (post.imageUrl != null)
          // ... [existing image code] ...

            if (post.tags.isNotEmpty)
            // ... [existing tags code] ...

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _PostStat(icon: Icons.favorite_border_rounded, value: post.likes),
                    _PostStat(icon: Icons.mode_comment_outlined, value: post.comments),
                    _PostStat(icon: Icons.repeat_rounded, value: post.shares),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark_outline_rounded),
                    ),
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
  if (trimmed.isEmpty) {
    return '?';
  }
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}