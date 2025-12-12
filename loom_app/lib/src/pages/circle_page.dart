import 'package:flutter/material.dart';

class CirclePage extends StatelessWidget {
  const CirclePage({super.key});

  static const List<_Circle> _circles = <_Circle>[
    _Circle(
      title: 'Product Ops',
      description: 'Daily standups, async updates, and retros for the product org.',
      onlineCount: 18,
      totalCount: 42,
      tags: <String>['product', 'ops'],
    ),
    _Circle(
      title: 'Creators Lab',
      description: 'Share experiments, give feedback, and show your latest drops.',
      onlineCount: 52,
      totalCount: 108,
      tags: <String>['design', 'community'],
    ),
    _Circle(
      title: 'Growth Collective',
      description: 'Campaign tests, channel analytics, and weekly performance sync.',
      onlineCount: 9,
      totalCount: 27,
      tags: <String>['marketing', 'analytics'],
    ),
    _Circle(
      title: 'Founders Lane',
      description: 'Discuss roadmap bets, fundraising, and hiring in a trusted space.',
      onlineCount: 6,
      totalCount: 15,
      tags: <String>['founders', 'strategy'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
      itemCount: _circles.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Your circles',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          );
        }
        final _Circle circle = _circles[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.12),
                        ),
                        child: Icon(Icons.groups_rounded, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          circle.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () {},
                        child: const Text('Open'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(circle.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: circle.tags
                        .map((String tag) => Chip(label: Text('#$tag'), padding: const EdgeInsets.symmetric(horizontal: 4)))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${circle.onlineCount} online • ${circle.totalCount} members',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Circle {
  const _Circle({
    required this.title,
    required this.description,
    required this.onlineCount,
    required this.totalCount,
    required this.tags,
  });

  final String title;
  final String description;
  final int onlineCount;
  final int totalCount;
  final List<String> tags;
}
