import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/feed_controller.dart';

class FeedPage extends GetView<FeedController> {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final posts = controller.feed;
      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _HomeHeader(greeting: controller.greeting.value, subtitle: controller.headerSubtitle.value),
          ),
          SliverToBoxAdapter(
            child: _StoriesSection(stories: controller.stories.toList()),
          ),
          SliverToBoxAdapter(
            child: _TopicsSection(
              topics: controller.topics.toList(),
              title: controller.trendingTitle.value,
              seeAllLabel: controller.seeAllLabel.value,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == posts.length - 1 ? 80 : 16),
                    child: _PostCard(post: posts[index]),
                  );
                },
                childCount: posts.length,
              ),
            ),
          ),
        ],
      );
    });
  }
}

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

  final List<StoryCard> stories;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final StoryCard story = stories[index];
          return Column(
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
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: stories.length,
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
  const _PostCard({required this.post});

  final PostCard post;

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
                _initial(post.authorName),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(
              post.authorName,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('${post.authorHandle} • ${post.timeAgo}'),
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz_rounded),
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
                      if (loadingProgress == null) {
                        return child;
                      }
                      final double? expectedBytes = loadingProgress.expectedTotalBytes?.toDouble();
                      final double? loadedBytes = loadingProgress.cumulativeBytesLoaded.toDouble();
                      return Container(
                        color: theme.colorScheme.surfaceVariant,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(value: expectedBytes != null ? loadedBytes! / expectedBytes : null),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceVariant,
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
