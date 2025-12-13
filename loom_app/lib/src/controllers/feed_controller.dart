import 'package:get/get.dart';
import 'package:loom_app/src/rust/api/simple.dart';

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
    final name = await fetchUserDisplayName();
    return FeedData(
      greeting: greet(name: name),
      headerSubtitle: 'Here is what your circles are sharing today.',
      trendingTitle: 'Trending circles',
      seeAllLabel: 'See all',
      stories: const <StoryCard>[
        StoryCard(name: 'You', isCurrentUser: true),
        StoryCard(name: 'Ava Chen'),
        StoryCard(name: 'Miles Carter'),
        StoryCard(name: 'Sasha Park'),
        StoryCard(name: 'Diego Luna'),
        StoryCard(name: 'Lina Patel'),
      ],
      feed: const <PostCard>[
        PostCard(
          authorName: 'Ava Chen',
          authorHandle: '@avacreates',
          timeAgo: '12m',
          text: 'Revamped the onboarding flow for Loom and the completion rate jumped 23%. Iteration pays off.',
          imageUrl: 'https://images.unsplash.com/photo-1523475472560-d2df97ec485c?auto=format&fit=crop&w=900&q=80',
          likes: 312,
          comments: 54,
          shares: 18,
          tags: <String>['ux', 'design', 'product'],
        ),
        PostCard(
          authorName: 'Miles Carter',
          authorHandle: '@milesloops',
          timeAgo: '1h',
          text: 'Launch day! Our collab room feature is live for everyone. Drop by and let me know what you think.',
          imageUrl: 'https://images.unsplash.com/photo-1474631245212-32dc3c8310c6?auto=format&fit=crop&w=900&q=80',
          likes: 512,
          comments: 102,
          shares: 41,
          tags: <String>['launch', 'community'],
        ),
        PostCard(
          authorName: 'Sasha Park',
          authorHandle: '@sashapark',
          timeAgo: '3h',
          text: 'AMA tomorrow on building healthy online spaces. Collecting questions until 9pm ET!',
          likes: 210,
          comments: 67,
          shares: 9,
          tags: <String>['moderation', 'ama'],
        ),
      ],
      topics: const <String>['Product Design', 'Playoffs', 'City Nights', 'SaaS', 'Wellness'],
    );
  }

  Future<String> fetchUserDisplayName() async {
    return 'Creator';
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
