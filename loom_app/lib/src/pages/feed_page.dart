
import 'package:flutter/material.dart';
import 'package:loom_app/src/rust/api/simple.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // Assuming 'greet' function returns an English greeting based on the name
  late final String _greeting = greet(name: 'Creator'); 
  late final List<_Story> _stories = <_Story>[
    const _Story(name: 'You', isCurrentUser: true),
    const _Story(name: 'Ava Chen'),
    const _Story(name: 'Miles Carter'),
    const _Story(name: 'Sasha Park'),
    const _Story(name: 'Diego Luna'),
    const _Story(name: 'Lina Patel'),
  ];
  late final List<_Post> _feed = <_Post>[
    const _Post(
      authorName: 'Ava Chen',
      authorHandle: '@avacreates',
      timeAgo: '12m',
      text:
          'Revamped the onboarding flow for Loom and the completion rate jumped 23%. Iteration pays off.',
      imageUrl:
          'https://images.unsplash.com/photo-1523475472560-d2df97ec485c?auto=format&fit=crop&w=900&q=80',
      likes: 312,
      comments: 54,
      shares: 18,
      tags: <String>['ux', 'design', 'product'],
    ),
    const _Post(
      authorName: 'Miles Carter',
      authorHandle: '@milesloops',
      timeAgo: '1h',
      text:
          'Launch day! Our collab room feature is live for everyone. Drop by and let me know what you think.',
      imageUrl:
          'https://images.unsplash.com/photo-1474631245212-32dc3c8310c6?auto=format&fit=crop&w=900&q=80',
      likes: 512,
      comments: 102,
      shares: 41,
      tags: <String>['launch', 'community'],
    ),
    const _Post(
      authorName: 'Sasha Park',
      authorHandle: '@sashapark',
      timeAgo: '3h',
      text:
          'AMA tomorrow on building healthy online spaces. Collecting questions until 9pm ET!',
      likes: 210,
      comments: 67,
      shares: 9,
      tags: <String>['moderation', 'ama'],
    ),
  ];
  late final List<String> _topics = <String>[
    'Product Design',
    'Playoffs',
    'City Nights',
    'SaaS',
    'Wellness',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: _HomeHeader(greeting: _greeting),
        ),
        SliverToBoxAdapter(
          child: _StoriesSection(stories: _stories),
        ),
        SliverToBoxAdapter(
          child: _TopicsSection(topics: _topics),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index == _feed.length - 1 ? 80 : 16),
                  child: _PostCard(post: _feed[index]),
                );
              },
              childCount: _feed.length,
            ),
          ),
        ),
      ],
    );
  }
}

// --- New Page Templates ---

/// Generic Scaffold for a new page
class _GenericPage extends StatelessWidget {
  const _GenericPage({required this.title, this.content = 'Page content'});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(content, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

void _navigateToPage(BuildContext context, Widget page) {
  Navigator.of(context).push(
    MaterialPageRoute<Widget>(
      builder: (BuildContext _) => page,
    ),
  );
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) => const _GenericPage(title: 'Search', content: 'Search field and results');
}

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});
  @override
  Widget build(BuildContext context) => const _GenericPage(title: 'QR Code Scanner', content: 'Camera view for scanning');
}

class CreateStoryPage extends StatelessWidget {
  const CreateStoryPage({super.key});
  @override
  Widget build(BuildContext context) => const _GenericPage(title: 'Create Story', content: 'Story creation interface with camera/gallery');
}

class ViewStoryPage extends StatelessWidget {
  const ViewStoryPage({super.key, required this.storyName});
  final String storyName;
  @override
  Widget build(BuildContext context) => _GenericPage(title: '$storyName\'s Story', content: 'Viewing the story');
}

class PostOptionsPage extends StatelessWidget {
  const PostOptionsPage({super.key});
  @override
  Widget build(BuildContext context) => const _GenericPage(title: 'Post Options', content: 'Report, Share, Hide, etc.');
}

class PostLikersPage extends StatelessWidget {
  const PostLikersPage({super.key});
  @override
  Widget build(BuildContext context) => const _GenericPage(title: 'Likes', content: 'List of people who liked this post');
}

class PostCommentsPage extends StatelessWidget {
  const PostCommentsPage({super.key});
  @override
  Widget build(BuildContext context) => const _GenericPage(title: 'Comments', content: 'List of comments and input field');
}

class PostSharePage extends StatelessWidget {
  const PostSharePage({super.key});
  @override
  Widget build(BuildContext context) => const _GenericPage(title: 'Share', content: 'Options for sharing the post');
}

class PostBookmarkPage extends StatelessWidget {
  const PostBookmarkPage({super.key});
  @override
  Widget build(BuildContext context) => const _GenericPage(title: 'Bookmark', content: 'Post added to bookmarks');
}

// Window for trending topics when see all is pressed

class SeeAllTopicsWindow extends StatelessWidget {
  const SeeAllTopicsWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> allTopics = <String>[
      'Product Design',
      'Playoffs',
      'City Nights',
      'SaaS',
      'Wellness',
      'Tech News',
      'Startups',
      'Remote Work',
      'Mental Health',
      'Travel',
      'Photography',
      'Music',
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Trending Circles'), // Changed text
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allTopics
              .map(
                (String topic) => Chip(
                  label: Text('#$topic'),
                  backgroundColor: theme.colorScheme.surface,
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// Opens a new page showing all topics when see all is pressed

void _SeeAllTopicsPage (BuildContext context) {
  _navigateToPage(context, const SeeAllTopicsWindow());
}

// --- Components with added actions (all text is now English) ---

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.greeting});

  final String greeting;

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
                  'Here is what your circles are sharing today.', // Changed text
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _navigateToPage(context, const SearchPage()), 
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () => _navigateToPage(context, const QrScannerPage()), 
            icon: const Icon(Icons.qr_code_scanner_rounded),
          ),
        ],
      ),
    );
  }
}

class _StoriesSection extends StatelessWidget {
  const _StoriesSection({required this.stories});

  final List<_Story> stories;

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
          final _Story story = stories[index];

          void onStoryTap() {
            if (story.isCurrentUser) {
              _navigateToPage(context, const CreateStoryPage()); 
            } else {
              _navigateToPage(context, ViewStoryPage(storyName: story.name)); 
            }
          }

          return InkWell( 
            onTap: onStoryTap,
            borderRadius: BorderRadius.circular(50),
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
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: stories.length,
      ),
    );
  }
}

class _TopicsSection extends StatelessWidget {
  const _TopicsSection({required this.topics});

  final List<String> topics;
  
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
                'Trending Circles', // Changed text
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton(onPressed: () => _SeeAllTopicsPage(context), child: const Text('See all')), // Changed text
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

  final _Post post;

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
              onPressed: () => _navigateToPage(context, const PostOptionsPage()), 
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
                _PostStat(
                  icon: Icons.favorite_border_rounded, 
                  value: post.likes, 
                  onPressed: () => _navigateToPage(context, const PostLikersPage()), 
                ),
                _PostStat(
                  icon: Icons.mode_comment_outlined, 
                  value: post.comments, 
                  onPressed: () => _navigateToPage(context, const PostCommentsPage()), 
                ),
                _PostStat(
                  icon: Icons.repeat_rounded, 
                  value: post.shares, 
                  onPressed: () => _navigateToPage(context, const PostSharePage()), 
                ),
                IconButton(
                  onPressed: () => _navigateToPage(context, const PostBookmarkPage()), 
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
  const _PostStat({required this.icon, required this.value, required this.onPressed});

  final IconData icon;
  final int value;
  final VoidCallback onPressed; 

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextButton.icon(
      onPressed: onPressed, 
      icon: Icon(icon, size: 20),
      label: Text(value.toString(), style: theme.textTheme.labelLarge),
    );
  }
}

class _Story {
  const _Story({required this.name, this.isCurrentUser = false});

  final String name;
  final bool isCurrentUser;
}

class _Post {
  const _Post({
    required this.authorName,
    required this.authorHandle,
    required this.timeAgo,
    required this.text,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.tags,
  });

  final String authorName;
  final String authorHandle;
  final String timeAgo;
  final String text;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int shares;
  final List<String> tags;
}

String _initial(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}