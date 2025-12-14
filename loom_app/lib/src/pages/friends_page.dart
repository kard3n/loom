import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/profiles_controller.dart';
import 'package:loom_app/src/models/profile.dart';
import 'package:loom_app/src/pages/direct_messages_page.dart';
import 'package:loom_app/src/pages/profile_page.dart';

class FriendsPage extends GetView<ProfilesController> {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    return Obx(() {
      final ThemeData sectionTheme = base;

      final friends = controller.profiles.where((p) => !p.isCurrentUser).toList(growable: false);

      return Theme(
        data: sectionTheme,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
          itemCount: friends.isEmpty ? 2 : friends.length + 1,
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

            if (friends.isEmpty) {
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No friends yet.',
                    style: sectionTheme.textTheme.bodyMedium?.copyWith(color: sectionTheme.colorScheme.onSurfaceVariant),
                  ),
                ),
              );
            }

            final Profile friend = friends[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      sectionTheme.colorScheme.primary.withValues(alpha: 0.12),
                      sectionTheme.colorScheme.primary.withValues(alpha: 0.04),
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
                                backgroundColor: sectionTheme.colorScheme.primary.withValues(alpha: 0.15),
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
                                      friend.lastSeenLabel,
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
    });
  }

  void _openProfile(BuildContext context, Profile friend) {
    Navigator.of(context).push(
      MaterialPageRoute<ProfilePage>(
        builder: (BuildContext _) => ProfilePage(friendName: friend.name),
      ),
    );
  }

  void _openDirectMessages(BuildContext context, Profile friend) {
    Navigator.of(context).push(
      MaterialPageRoute<DirectMessagesPage>(
        builder: (BuildContext _) => DirectMessagesPage(friendName: friend.name),
      ),
    );
  }

  void _showManageSheet(BuildContext context, Profile friend) {
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