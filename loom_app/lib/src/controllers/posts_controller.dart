import 'dart:io';
import 'package:get/get.dart';
import 'package:loom_app/src/models/post.dart';
import 'package:loom_app/src/rust/api/simple.dart' as rust;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PostsController extends GetxController {
  final RxList<Post> posts = <Post>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  /// Helper to get the correct path for the database on the phone
  Future<String> _getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/loom_app.db";
  }

  /// Ensures the 'me' user and 'mobile_app' totem exist to prevent Foreign Key errors.
  Future<void> _bootstrapDatabase(rust.AppDatabase db) async {
    final now = DateTime.now().toUtc();

    // 1. Ensure Default User ("me") exists
    try {
      // Try to find the user first
      await db.getUserById(uuid: "me");
    } catch (_) {
      // If not found (error thrown), create them
      print("Bootstrapping: Creating default user 'me'");
      await db.createUser(
        user: rust.User(
          uuid: "me",
          username: "Creator",
          status: "Active",
          bio: "This is the local user.",
          lastContact: now,
          profilePicture: null,
        ),
      );
    }

    // 2. Ensure Default Totem ("mobile_app") exists
    // Since we don't have getTotemById generated, we try to create it.
    // If it exists, the database will throw a constraint error, which we catch and ignore.
    try {
      await db.createTotem(
        totem: rust.Totem(
          uuid: "mobile_app",
          name: "My Phone",
          location: "Here",
          lastContact: now,
        ),
      );
    } catch (_) {
      // Ignore "Unique constraint failed" errors
    }
  }

  Future<void> loadPosts() async {
    try {
      final dbPath = await _getDatabasePath();
      final database = await rust.AppDatabase(path: dbPath);

      // FIX: Ensure dependencies exist before we try to read/write posts
      await _bootstrapDatabase(database);

      final rustPosts = await database.getAllPosts();

      // Convert and update UI
      // Reversing the list so newest posts appear at the top
      posts.assignAll(
        rustPosts.map((p) => p.toFlutterPost()).toList().reversed.toList(),
      );
    } catch (e) {
      print("Error loading posts: $e");
    }
  }

  Future<void> addPost(String content, String authorId) async {
    try {
      // 1. Construct the Post object
      final newPost = rust.Post(
        uuid: const Uuid().v4(),
        userId: authorId, // Must match "me" or an existing user UUID
        title: "New Post",
        body: content,
        timestamp: DateTime.now().toUtc(),
        sourceTotem: "mobile_app", // Must match the UUID created in _bootstrapDatabase
        image: null,
      );

      // 2. Open DB
      final dbPath = await _getDatabasePath();
      final database = await rust.AppDatabase(path: dbPath);

      // 3. Ensure DB is ready (just in case)
      await _bootstrapDatabase(database);

      // 4. Create the post
      await database.createPost(post: newPost);

      // 5. Refresh the feed
      await loadPosts();

      Get.snackbar("Success", "Post created successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to create post: $e");
      print(e);
    }
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
}

// --- Extensions ---

extension PostMapper on rust.Post {
  Post toFlutterPost() {
    return Post(
      id: uuid,
      authorId: userId,
      text: body,
      imageUrl: image,
      timeAgoLabel: _formatTimeAgo(timestamp),
      likes: 0,
      comments: 0,
      shares: 0,
      // FIX: Extract hashtags from the body text so trending works
      tags: _extractTags(body),
      isClip: false,
    );
  }

  List<String> _extractTags(String text) {
    final RegExp regex = RegExp(r"\#(\w+)");
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }

  String _formatTimeAgo(DateTime dt) {
    // Convert UTC to local time for display
    final localDt = dt.toLocal();
    final diff = DateTime.now().difference(localDt);

    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}