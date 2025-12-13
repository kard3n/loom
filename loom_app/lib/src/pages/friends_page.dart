import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/friends_controller.dart';
import 'package:loom_app/src/pages/direct_messages_page.dart';
import 'package:loom_app/src/pages/profile_page.dart';

class FriendsPage extends GetView<FriendsController> {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    return Obx(() {
      final ThemeData sectionTheme = base.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: controller.seedColor.value,
          brightness: base.brightness,
        ),
        scaffoldBackgroundColor: controller.scaffoldBackgroundColor.value,
      );

      final friends = controller.friends;

      return Theme(
        data: sectionTheme,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
          itemCount: friends.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      controller.title.value,
                      style: sectionTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.subtitle.value,
                      style: sectionTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            final FriendCard friend = friends[index - 1];
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
                                      friend.lastSeen,
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
    });
  }

  void _openProfile(BuildContext context, FriendCard friend) {
    Navigator.of(context).push(
      MaterialPageRoute<ProfilePage>(
        builder: (BuildContext _) => ProfilePage(friendName: friend.name),
      ),
    );
  }

  void _openDirectMessages(BuildContext context, FriendCard friend) {
    Navigator.of(context).push(
      MaterialPageRoute<DirectMessagesPage>(
        builder: (BuildContext _) => DirectMessagesPage(friendName: friend.name),
      ),
    );
  }

  void _showManageSheet(BuildContext context, FriendCard friend) {
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
                  title: Text(controller.manageProfileLabel.value),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openProfile(context, friend);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block_rounded, color: Colors.deepOrange),
                  title: Text(controller.manageBlockLabel.value),
                  textColor: Colors.deepOrange,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(controller.blockedSnackbar(friend.name))),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: Text(controller.manageDeleteLabel.value),
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(controller.deletedSnackbar(friend.name))),
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
