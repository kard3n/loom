import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxString bio = ''.obs;
  final RxString aboutTitle = ''.obs;
  final RxString aboutBody = ''.obs;
  final RxString pinnedTitle = ''.obs;
  final RxString pinnedThreadTitle = ''.obs;
  final RxString pinnedThreadSubtitle = ''.obs;
  final RxString pinnedTotemTitle = ''.obs;
  final RxString pinnedTotemSubtitle = ''.obs;
  final RxString recentPostsTitle = ''.obs;

  final RxString statTotemsLabel = ''.obs;
  final RxString statPostsLabel = ''.obs;
  final RxString statFriendsLabel = ''.obs;

  final RxString messageLabel = ''.obs;
  final RxString followLabel = ''.obs;

  final RxString recentPost1Title = ''.obs;
  final RxString recentPost1Subtitle = ''.obs;
  final RxString recentPost2Title = ''.obs;
  final RxString recentPost2Subtitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final data = await fetchProfileCopy();
    bio.value = data.bio;
    aboutTitle.value = data.aboutTitle;
    aboutBody.value = data.aboutBody;
    pinnedTitle.value = data.pinnedTitle;
    pinnedThreadTitle.value = data.pinnedThreadTitle;
    pinnedThreadSubtitle.value = data.pinnedThreadSubtitle;
    pinnedTotemTitle.value = data.pinnedTotemTitle;
    pinnedTotemSubtitle.value = data.pinnedTotemSubtitle;
    recentPostsTitle.value = data.recentPostsTitle;

    statTotemsLabel.value = data.statTotemsLabel;
    statPostsLabel.value = data.statPostsLabel;
    statFriendsLabel.value = data.statFriendsLabel;

    messageLabel.value = data.messageLabel;
    followLabel.value = data.followLabel;

    recentPost1Title.value = data.recentPost1Title;
    recentPost1Subtitle.value = data.recentPost1Subtitle;
    recentPost2Title.value = data.recentPost2Title;
    recentPost2Subtitle.value = data.recentPost2Subtitle;
  }

  Future<ProfileCopy> fetchProfileCopy() async {
    return const ProfileCopy(
      bio: 'Placeholder bio: short vibe line goes here.',
      aboutTitle: 'About',
      aboutBody: 'Placeholder: interests, location, and a couple of links would appear here.',
      pinnedTitle: 'Pinned',
      pinnedThreadTitle: 'Pinned thread (placeholder)',
      pinnedThreadSubtitle: 'A saved highlight you can open later.',
      pinnedTotemTitle: 'Totem ritual (placeholder)',
      pinnedTotemSubtitle: 'A ritual or prompt this user is known for.',
      recentPostsTitle: 'Recent posts',
      statTotemsLabel: 'Totems',
      statPostsLabel: 'Posts',
      statFriendsLabel: 'Friends',
      messageLabel: 'Message',
      followLabel: 'Follow',
      recentPost1Title: 'A recent post title (placeholder)',
      recentPost1Subtitle: 'Short excerpt goes here — tap to open.',
      recentPost2Title: 'Another post (placeholder)',
      recentPost2Subtitle: 'This list will populate from the feed later.',
    );
  }
}

class ProfileCopy {
  const ProfileCopy({
    required this.bio,
    required this.aboutTitle,
    required this.aboutBody,
    required this.pinnedTitle,
    required this.pinnedThreadTitle,
    required this.pinnedThreadSubtitle,
    required this.pinnedTotemTitle,
    required this.pinnedTotemSubtitle,
    required this.recentPostsTitle,
    required this.statTotemsLabel,
    required this.statPostsLabel,
    required this.statFriendsLabel,
    required this.messageLabel,
    required this.followLabel,
    required this.recentPost1Title,
    required this.recentPost1Subtitle,
    required this.recentPost2Title,
    required this.recentPost2Subtitle,
  });

  final String bio;
  final String aboutTitle;
  final String aboutBody;
  final String pinnedTitle;
  final String pinnedThreadTitle;
  final String pinnedThreadSubtitle;
  final String pinnedTotemTitle;
  final String pinnedTotemSubtitle;
  final String recentPostsTitle;

  final String statTotemsLabel;
  final String statPostsLabel;
  final String statFriendsLabel;

  final String messageLabel;
  final String followLabel;

  final String recentPost1Title;
  final String recentPost1Subtitle;
  final String recentPost2Title;
  final String recentPost2Subtitle;
}
