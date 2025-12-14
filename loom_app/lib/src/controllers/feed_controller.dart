import 'package:get/get.dart';

class FeedController extends GetxController {
  final RxString greeting = ''.obs;
  final RxString headerSubtitle = ''.obs;

  final RxList<StoryCard> stories = <StoryCard>[].obs;
  final RxList<PostCard> feed = <PostCard>[].obs;
  final RxList<String> topics = <String>[].obs;

  final RxString trendingTitle = ''.obs;
  final RxString seeAllLabel = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final data = await fetchFeedData();
    greeting.value = data.greeting;
    headerSubtitle.value = data.headerSubtitle;
    trendingTitle.value = data.trendingTitle;
    seeAllLabel.value = data.seeAllLabel;
    stories.assignAll(data.stories);
    feed.assignAll(data.feed);
    topics.assignAll(data.topics);
  }

  Future<FeedData> fetchFeedData() async {
    return FeedData(
      greeting: '',
      headerSubtitle: '',
      trendingTitle: '',
      seeAllLabel: '',
      stories: const <StoryCard>[],
      feed: const <PostCard>[],
      topics: const <String>[],
    );
  }

  Future<String> fetchUserDisplayName() async {
    return '';
  }
}

class StoryCard {
  const StoryCard({required this.name, this.isCurrentUser = false});

  final String name;
  final bool isCurrentUser;
}

class PostCard {
  const PostCard({
    required this.authorName,
    required this.authorHandle,
    required this.timeAgo,
    required this.text,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.tags,
  });

  final String authorName;
  final String authorHandle;
  final String timeAgo;
  final String text;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int shares;
  final List<String> tags;
}

class FeedData {
  FeedData({
    required this.greeting,
    required this.headerSubtitle,
    required this.trendingTitle,
    required this.seeAllLabel,
    required this.stories,
    required this.feed,
    required this.topics,
  });

  final String greeting;
  final String headerSubtitle;
  final String trendingTitle;
  final String seeAllLabel;
  final List<StoryCard> stories;
  final List<PostCard> feed;
  final List<String> topics;
}
