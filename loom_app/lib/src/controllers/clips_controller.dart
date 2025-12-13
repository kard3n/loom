import 'package:get/get.dart';

class ClipsController extends GetxController {
  final RxString title = ''.obs;
  final RxList<ClipCard> clips = <ClipCard>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final data = await fetchClipsData();
    title.value = data.title;
    clips.assignAll(data.clips);
  }

  Future<ClipsData> fetchClipsData() async {
    return const ClipsData(
      title: 'Fresh clips',
      clips: <ClipCard>[
        ClipCard(
          title: 'Design Sync Highlights',
          author: 'Ava Chen',
          timeAgo: '7m',
          views: '2.4K views',
          thumbnailUrl: 'https://images.unsplash.com/photo-1553877522-43269d4ea984?auto=format&fit=crop&w=900&q=80',
          duration: '03:12',
        ),
        ClipCard(
          title: 'Community Room AMA',
          author: 'Miles Carter',
          timeAgo: '1h',
          views: '9.1K views',
          thumbnailUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=900&q=80',
          duration: '12:47',
        ),
        ClipCard(
          title: 'Storyboarding Next Season',
          author: 'Sasha Park',
          timeAgo: '3h',
          views: '4.6K views',
          thumbnailUrl: 'https://images.unsplash.com/photo-1481277542470-605612bd2d61?auto=format&fit=crop&w=900&q=80',
          duration: '08:19',
        ),
      ],
    );
  }
}

class ClipCard {
  const ClipCard({
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.views,
    required this.thumbnailUrl,
    required this.duration,
  });

  final String title;
  final String author;
  final String timeAgo;
  final String views;
  final String thumbnailUrl;
  final String duration;
}

class ClipsData {
  const ClipsData({required this.title, required this.clips});

  final String title;
  final List<ClipCard> clips;
}
