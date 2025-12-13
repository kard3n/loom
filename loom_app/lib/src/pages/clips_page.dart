import 'package:flutter/material.dart';

class ClipsPage extends StatelessWidget {
  const ClipsPage({super.key});

  static const List<_Clip> _clips = <_Clip>[
    _Clip(
      title: 'Design Sync Highlights',
      author: 'Ava Chen',
      timeAgo: '7m',
      views: '2.4K views',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1553877522-43269d4ea984?auto=format&fit=crop&w=900&q=80',
      duration: '03:12',
    ),
    _Clip(
      title: 'Community Room AMA',
      author: 'Miles Carter',
      timeAgo: '1h',
      views: '9.1K views',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=900&q=80',
      duration: '12:47',
    ),
    _Clip(
      title: 'Storyboarding Next Season',
      author: 'Sasha Park',
      timeAgo: '3h',
      views: '4.6K views',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1481277542470-605612bd2d61?auto=format&fit=crop&w=900&q=80',
      duration: '08:19',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
      itemCount: _clips.length + 1,
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
        final _Clip clip = _clips[index - 1];
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
                        clip.thumbnailUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          clip.duration,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: IconButton.filled(
                        onPressed: () {},
                        style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.85)),
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
                        clip.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${clip.author} • ${clip.timeAgo} • ${clip.views}',
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
  }
}

class _Clip {
  const _Clip({
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.views,
    required this.thumbnailUrl,
    required this.duration,
  });

  final String title;
  final String author;
  final String timeAgo;
  final String views;
  final String thumbnailUrl;
  final String duration;
}
