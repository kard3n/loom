class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.text,
    required this.timeAgoLabel,
    this.imageUrl,
    this.tags = const <String>[],
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isClip = false,
    this.clipDurationLabel,
    this.clipViewsLabel,
  });

  final String id;
  final String authorId;
  final String text;
  final String timeAgoLabel;
  final String? imageUrl;
  final List<String> tags;

  final int likes;
  final int comments;
  final int shares;

  final bool isClip;
  final String? clipDurationLabel;
  final String? clipViewsLabel;
}
