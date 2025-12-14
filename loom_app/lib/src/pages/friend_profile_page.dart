import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/posts_controller.dart';
import 'package:loom_app/src/controllers/profiles_controller.dart';
import 'package:loom_app/src/models/post.dart';

class FriendProfilePage extends StatelessWidget {
  const FriendProfilePage({super.key, required this.friendName});

  final String friendName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final profilesController = Get.find<ProfilesController>();
    final postsController = Get.find<PostsController>();

    return Obx(() {
      final profile = profilesController.byName(friendName);
      final bio = profile?.bio ?? '';
      final recent = postsController.posts
          .where((Post p) => p.authorId == (profile?.id ?? ''))
          .take(2)
          .toList(growable: false);

      return Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: cs.surface,
              foregroundColor: cs.onSurface,
              title: Text(friendName),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        cs.primaryContainer,
                        cs.surface,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 72, 16, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: cs.primary.withValues(alpha: 0.15),
                            child: Text(
                              _initial(friendName),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  friendName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile?.status ?? '',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    _StatsRow(
                      items: <_StatItem>[
                        const _StatItem(label: 'Totems', value: '—'),
                        const _StatItem(label: 'Posts', value: '—'),
                        const _StatItem(label: 'Friends', value: '—'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.message_rounded),
                            label: const Text('Message'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text('Follow'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'About',
                      child: Text(
                        bio.isNotEmpty ? bio : 'This user has not added a bio yet.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Pinned',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.bookmarks_outlined),
                            title: const Text('No pinned items'),
                            subtitle: const Text('Pins will show up here when available.'),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Recent posts',
                      child: Column(
                        children: <Widget>[
                          if (recent.isEmpty)
                            const _PostPlaceholderTile(
                              title: 'No posts yet',
                              subtitle: 'Posts will show up here when available.',
                            )
                          else ...<Widget>[
                            _PostPlaceholderTile(
                              title: (recent.first.title.isNotEmpty && recent.first.title != 'Untitled')
                                  ? recent.first.title
                                  : recent.first.text,
                              subtitle: '${recent.first.timeAgoLabel} • ${recent.first.text}'.trim(),
                            ),
                            if (recent.length > 1) ...<Widget>[
                              const Divider(height: 1),
                              _PostPlaceholderTile(
                                title: (recent[1].title.isNotEmpty && recent[1].title != 'Untitled')
                                    ? recent[1].title
                                    : recent[1].text,
                                subtitle: '${recent[1].timeAgoLabel} • ${recent[1].text}'.trim(),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _PostPlaceholderTile extends StatelessWidget {
  const _PostPlaceholderTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.chat_bubble_outline_rounded),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {},
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.items});

  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: items
              .map(
                (_StatItem item) => Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        item.value,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _StatItem {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;
}

String _initial(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}
