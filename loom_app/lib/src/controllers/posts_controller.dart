import 'package:get/get.dart';
import 'package:loom_app/src/models/post.dart';

class PostsController extends GetxController {
  final RxList<Post> posts = <Post>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    posts.assignAll(await fetchPosts());
  }

  List<String> trendingTags({int limit = 8}) {
    final counts = <String, int>{};
    for (final post in posts) {
      for (final tag in post.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList(growable: false);
  }

  List<Post> clips() => posts.where((p) => p.isClip).toList(growable: false);

  Future<List<Post>> fetchPosts() async {
    return const <Post>[
      Post(
        id: 'p1',
        authorId: 'ava',
        timeAgoLabel: '12m',
        text: 'Revamped the onboarding flow for Loom and the completion rate jumped 23%. Iteration pays off.',
        imageUrl: 'https://images.unsplash.com/photo-1523475472560-d2df97ec485c?auto=format&fit=crop&w=900&q=80',
        tags: <String>['ux', 'design', 'product'],
        likes: 312,
        comments: 54,
        shares: 18,
      ),
      Post(
        id: 'p2',
        authorId: 'miles',
        timeAgoLabel: '1h',
        text: 'Launch day! Our collab room feature is live for everyone. Drop by and let me know what you think.',
        imageUrl: 'https://images.unsplash.com/photo-1474631245212-32dc3c8310c6?auto=format&fit=crop&w=900&q=80',
        tags: <String>['launch', 'community'],
        likes: 512,
        comments: 102,
        shares: 41,
      ),
      Post(
        id: 'p3',
        authorId: 'sasha',
        timeAgoLabel: '3h',
        text: 'AMA tomorrow on building healthy online spaces. Collecting questions until 9pm ET!',
        tags: <String>['moderation', 'ama'],
        likes: 210,
        comments: 67,
        shares: 9,
      ),
      Post(
        id: 'c1',
        authorId: 'ava',
        timeAgoLabel: '7m',
        text: 'Design Sync Highlights',
        imageUrl: 'https://images.unsplash.com/photo-1553877522-43269d4ea984?auto=format&fit=crop&w=900&q=80',
        isClip: true,
        clipViewsLabel: '2.4K views',
        clipDurationLabel: '03:12',
      ),
      Post(
        id: 'c2',
        authorId: 'miles',
        timeAgoLabel: '1h',
        text: 'Community Room AMA',
        imageUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=900&q=80',
        isClip: true,
        clipViewsLabel: '9.1K views',
        clipDurationLabel: '12:47',
      ),
      Post(
        id: 'c3',
        authorId: 'sasha',
        timeAgoLabel: '3h',
        text: 'Storyboarding Next Season',
        imageUrl: 'https://images.unsplash.com/photo-1481277542470-605612bd2d61?auto=format&fit=crop&w=900&q=80',
        isClip: true,
        clipViewsLabel: '4.6K views',
        clipDurationLabel: '08:19',
      ),
    ];
  }
}
