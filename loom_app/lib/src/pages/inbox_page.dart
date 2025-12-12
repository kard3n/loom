import 'package:flutter/material.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final List<_Conversation> _conversations = <_Conversation>[
    const _Conversation(
      name: 'Ava Chen',
      handle: '@avacreates',
      lastMessage: 'Locked the new onboarding flow. Launching the experiment tonight.',
      timeAgo: '1m',
      unread: 3,
    ),
    const _Conversation(
      name: 'Miles Carter',
      handle: '@milesloops',
      lastMessage: 'Sending you the collaboration notes right after this standup.',
      timeAgo: '18m',
      unread: 0,
    ),
    const _Conversation(
      name: 'Creators Lab',
      handle: 'Circle chat',
      lastMessage: 'Pinned Sofia’s prototype walk-through for feedback.',
      timeAgo: '1h',
      unread: 7,
    ),
    const _Conversation(
      name: 'Lina Patel',
      handle: '@linapatel',
      lastMessage: 'Would love your eyes on the schedule for next week.',
      timeAgo: 'Yesterday',
      unread: 0,
    ),
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_Conversation> filtered = _conversations
        .where(
          (_Conversation conversation) =>
              conversation.name.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
          child: TextField(
            onChanged: (String value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search inbox',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => setState(() => _query = ''),
                      icon: const Icon(Icons.close_rounded),
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            itemCount: filtered.length,
            itemBuilder: (BuildContext context, int index) {
              final _Conversation conversation = filtered[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                      child: Text(
                        conversation.name.substring(0, 1).toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    title: Text(
                      conversation.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 4),
                        Text(conversation.handle),
                        const SizedBox(height: 8),
                        Text(
                          conversation.lastMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          conversation.timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        if (conversation.unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              conversation.unread.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {},
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Conversation {
  const _Conversation({
    required this.name,
    required this.handle,
    required this.lastMessage,
    required this.timeAgo,
    required this.unread,
  });

  final String name;
  final String handle;
  final String lastMessage;
  final String timeAgo;
  final int unread;
}
