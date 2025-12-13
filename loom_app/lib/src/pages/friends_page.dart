import 'package:flutter/material.dart';
import 'package:loom_app/src/pages/direct_messages_page.dart';
import 'package:loom_app/src/pages/profile_page.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  static const List<_Friend> _friends = <_Friend>[
    _Friend(
      name: 'Ava Chen',
      status: 'Sketching new identity for Loom.',
      last_seen: '19 hours ago',
      vibe: Color(0xFFFF8A80),
      tags: <String>['Design mode', 'Streaming'],
    ),
    _Friend(
      name: 'Miles Carter',
      status: 'Pair programming with community.',
      last_seen: '15 minutes ago',
      vibe: Color(0xFFFFB74D),
      tags: <String>['Live now'],
    ),
    _Friend(
      name: 'Sasha Park',
      status: 'Collecting Qs for AMA tomorrow.',
      last_seen: '4 days ago',
      vibe: Color(0xFF9575CD),
      tags: <String>['Focus', 'Audio'],
    ),
    _Friend(
      name: 'Lina Patel',
      status: 'Planning the winter retreat.',
      last_seen: '42 seconds ago',
      vibe: Color(0xFF4FC3F7),
      tags: <String>['Travel', 'Docs open'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    final ThemeData sectionTheme = base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF8A80),
        brightness: base.brightness,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF5F2),
    );

    return Theme(
      data: sectionTheme,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
        itemCount: _friends.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Friends',
                    style: sectionTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check in, send energy, hop into a room together.',
                    style: sectionTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }
          final _Friend friend = _friends[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    friend.vibe.withOpacity(0.15),
                    friend.vibe.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _openProfile(context, friend),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: friend.vibe.withOpacity(0.25),
                              child: Text(
                                friend.name.substring(0, 1),
                                style: sectionTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    friend.name,
                                    style: sectionTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    friend.last_seen,
                                    style: sectionTheme.textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () => _openDirectMessages(context, friend),
                              icon: const Icon(Icons.message_rounded),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              onPressed: () => _showManageSheet(context, friend),
                              icon: const Icon(Icons.more_horiz_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          friend.status,
                          style: sectionTheme.textTheme.bodyLarge,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: friend.tags
                              .map(
                                (String tag) => Chip(
                                  avatar: const Icon(Icons.bolt_rounded, size: 16),
                                  label: Text(tag),
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openProfile(BuildContext context, _Friend friend) {
    Navigator.of(context).push(
      MaterialPageRoute<ProfilePage>(
        builder: (BuildContext _) => ProfilePage(friendName: friend.name),
      ),
    );
  }

  void _openDirectMessages(BuildContext context, _Friend friend) {
    Navigator.of(context).push(
      MaterialPageRoute<DirectMessagesPage>(
        builder: (BuildContext _) => DirectMessagesPage(friendName: friend.name),
      ),
    );
  }

  void _showManageSheet(BuildContext context, _Friend friend) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openProfile(context, friend);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block_rounded, color: Colors.deepOrange),
                  title: const Text('Block'),
                  textColor: Colors.deepOrange,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Blocked ${friend.name}')), 
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text('Delete'),
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleted ${friend.name}')), 
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Friend {
  const _Friend({
    required this.name,
    required this.status,
    required this.last_seen,
    required this.vibe,
    required this.tags,
  });

  final String name;
  final String status;
  final String last_seen;
  final Color vibe;
  final List<String> tags;
}
