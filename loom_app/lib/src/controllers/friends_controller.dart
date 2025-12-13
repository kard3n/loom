import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendsController extends GetxController {
  final RxString title = ''.obs;
  final RxString subtitle = ''.obs;
  final Rx<Color> seedColor = const Color(0xFFFF8A80).obs;
  final Rx<Color> scaffoldBackgroundColor = const Color(0xFFFFF5F2).obs;

  final RxList<FriendCard> friends = <FriendCard>[].obs;

  final RxString manageProfileLabel = ''.obs;
  final RxString manageBlockLabel = ''.obs;
  final RxString manageDeleteLabel = ''.obs;
  final RxString blockedSnackbarTemplate = ''.obs;
  final RxString deletedSnackbarTemplate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final data = await fetchFriendsData();
    title.value = data.title;
    subtitle.value = data.subtitle;
    seedColor.value = data.seedColor;
    scaffoldBackgroundColor.value = data.scaffoldBackgroundColor;
    manageProfileLabel.value = data.manageProfileLabel;
    manageBlockLabel.value = data.manageBlockLabel;
    manageDeleteLabel.value = data.manageDeleteLabel;
    blockedSnackbarTemplate.value = data.blockedSnackbarTemplate;
    deletedSnackbarTemplate.value = data.deletedSnackbarTemplate;
    friends.assignAll(data.friends);
  }

  String blockedSnackbar(String name) => blockedSnackbarTemplate.value.replaceAll('{name}', name);
  String deletedSnackbar(String name) => deletedSnackbarTemplate.value.replaceAll('{name}', name);

  Future<FriendsData> fetchFriendsData() async {
    return const FriendsData(
      title: 'Friends',
      subtitle: 'Check in, send energy, hop into a room together.',
      seedColor: Color(0xFFFF8A80),
      scaffoldBackgroundColor: Color(0xFFFFF5F2),
      manageProfileLabel: 'Profile',
      manageBlockLabel: 'Block',
      manageDeleteLabel: 'Delete',
      blockedSnackbarTemplate: 'Blocked {name}',
      deletedSnackbarTemplate: 'Deleted {name}',
      friends: <FriendCard>[
        FriendCard(
          name: 'Ava Chen',
          status: 'Sketching new identity for Loom.',
          lastSeen: '19 hours ago',
          vibe: Color(0xFFFF8A80),
          tags: <String>['Design mode', 'Streaming'],
        ),
        FriendCard(
          name: 'Miles Carter',
          status: 'Pair programming with community.',
          lastSeen: '15 minutes ago',
          vibe: Color(0xFFFFB74D),
          tags: <String>['Live now'],
        ),
        FriendCard(
          name: 'Sasha Park',
          status: 'Collecting Qs for AMA tomorrow.',
          lastSeen: '4 days ago',
          vibe: Color(0xFF9575CD),
          tags: <String>['Focus', 'Audio'],
        ),
        FriendCard(
          name: 'Lina Patel',
          status: 'Planning the winter retreat.',
          lastSeen: '42 seconds ago',
          vibe: Color(0xFF4FC3F7),
          tags: <String>['Travel', 'Docs open'],
        ),
      ],
    );
  }
}

class FriendCard {
  const FriendCard({
    required this.name,
    required this.status,
    required this.lastSeen,
    required this.vibe,
    required this.tags,
  });

  final String name;
  final String status;
  final String lastSeen;
  final Color vibe;
  final List<String> tags;
}

class FriendsData {
  const FriendsData({
    required this.title,
    required this.subtitle,
    required this.seedColor,
    required this.scaffoldBackgroundColor,
    required this.manageProfileLabel,
    required this.manageBlockLabel,
    required this.manageDeleteLabel,
    required this.blockedSnackbarTemplate,
    required this.deletedSnackbarTemplate,
    required this.friends,
  });

  final String title;
  final String subtitle;
  final Color seedColor;
  final Color scaffoldBackgroundColor;
  final String manageProfileLabel;
  final String manageBlockLabel;
  final String manageDeleteLabel;
  final String blockedSnackbarTemplate;
  final String deletedSnackbarTemplate;
  final List<FriendCard> friends;
}
