import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  static const List<_SavedItem> _items = <_SavedItem>[
    _SavedItem(
      title: 'Creator Rituals Playbook',
      author: 'Ava Chen',
      excerpt: 'Step-by-step prompt kits to keep async rituals lively for distributed teams.',
      tag: 'Playbook',
      savedAgo: 'Saved 12m ago',
      accent: Color(0xFFFFD54F),
    ),
    _SavedItem(
      title: 'Collab Room Launch Metrics',
      author: 'Miles Carter',
      excerpt: 'North-star metrics and fallback levers for the collab room GA rollout.',
      tag: 'Insights',
      savedAgo: 'Saved 1h ago',
      accent: Color(0xFFFFAB40),
    ),
    _SavedItem(
      title: 'Healthy Communities AMA',
      author: 'Sasha Park',
      excerpt: 'Top 5 questions to ask when shaping kinder spaces on Loom.',
      tag: 'Panel',
      savedAgo: 'Saved yesterday',
      accent: Color(0xFFFFCC80),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    final ThemeData sectionTheme = base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFB300),
        brightness: base.brightness,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFBF2),
    );

    return Theme(
      data: sectionTheme,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
        itemCount: _items.length + 1,
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
                    'Library of threads, posts, and rituals you pinned for later.',
                    style: sectionTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }
          final _SavedItem item = _items[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              child: Container(
                decoration: BoxDecoration(
                  color: item.accent.withOpacity(0.12),
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
                                  item.title,
                                  style: sectionTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'by ${item.author}',
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
                        item.excerpt,
                        style: sectionTheme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Chip(
                            avatar: const Icon(Icons.bookmark_added_rounded, size: 16),
                            label: Text(item.tag),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          Text(
                            item.savedAgo,
                            style: sectionTheme.textTheme.bodySmall?.copyWith(color: sectionTheme.colorScheme.onSurfaceVariant),
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
  }
}

class _SavedItem {
  const _SavedItem({
    required this.title,
    required this.author,
    required this.excerpt,
    required this.tag,
    required this.savedAgo,
    required this.accent,
  });

  final String title;
  final String author;
  final String excerpt;
  final String tag;
  final String savedAgo;
  final Color accent;
}
