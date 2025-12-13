import 'package:flutter/material.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  static const List<_Alert> _alerts = <_Alert>[
    _Alert(
      title: 'New request to join Product Ops',
      detail: 'Jess Vega added a note about growth experiments.',
      timeAgo: '2m ago',
      isUrgent: true,
    ),
    _Alert(
      title: 'Weekly digest is ready',
      detail: 'Catch the highlights from your top five circles.',
      timeAgo: '1h ago',
      isUrgent: false,
    ),
    _Alert(
      title: 'Creator spotlight is live',
      detail: 'Sasha featured your clip in this week’s roundup.',
      timeAgo: '3h ago',
      isUrgent: false,
    ),
    _Alert(
      title: 'Security log-in',
      detail: 'New login from Chrome on macOS was approved.',
      timeAgo: 'Yesterday',
      isUrgent: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
      itemCount: _alerts.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Alerts',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          );
        }
        final _Alert alert = _alerts[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              leading: CircleAvatar(
                backgroundColor: alert.isUrgent
                    ? theme.colorScheme.error.withOpacity(0.12)
                    : theme.colorScheme.primary.withOpacity(0.12),
                child: Icon(
                  alert.isUrgent ? Icons.priority_high_rounded : Icons.notifications_active_rounded,
                  color: alert.isUrgent ? theme.colorScheme.error : theme.colorScheme.primary,
                ),
              ),
              title: Text(
                alert.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 6),
                  Text(alert.detail),
                  const SizedBox(height: 8),
                  Text(
                    alert.timeAgo,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Alert {
  const _Alert({
    required this.title,
    required this.detail,
    required this.timeAgo,
    required this.isUrgent,
  });

  final String title;
  final String detail;
  final String timeAgo;
  final bool isUrgent;
}
