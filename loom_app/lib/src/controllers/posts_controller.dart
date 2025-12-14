import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/profiles_controller.dart';
import 'package:loom_app/src/models/post.dart';
import 'package:loom_app/src/rust/api/simple.dart' as rust;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PostsController extends GetxController {
  final RxList<Post> posts = <Post>[].obs;

  // In-memory set of post IDs the user has saved.
  // (Not persisted across app restarts.)
  final RxSet<String> savedPostIds = <String>{}.obs;

  // In-memory set of post IDs the user has pinned to their profile.
  // (Not persisted across app restarts.)
  final RxSet<String> pinnedPostIds = <String>{}.obs;

  // Stores the current user's UUID. Default is empty until loaded.
  final RxString currentUserId = "".obs;

  bool isSaved(String postId) => savedPostIds.contains(postId);

  bool isPinned(String postId) => pinnedPostIds.contains(postId);

  void toggleSaved(String postId) {
    if (savedPostIds.contains(postId)) {
      savedPostIds.remove(postId);
    } else {
      savedPostIds.add(postId);
    }
    // RxSet mutations may not always notify listeners unless refreshed.
    savedPostIds.refresh();
  }

  void togglePinned(String postId) {
    if (pinnedPostIds.contains(postId)) {
      pinnedPostIds.remove(postId);
    } else {
      pinnedPostIds.add(postId);
    }
    pinnedPostIds.refresh();
  }

  List<Post> savedPosts({bool includeClips = false}) {
    final ids = savedPostIds;
    return posts
        .where((p) => (includeClips || !p.isClip) && ids.contains(p.id))
        .toList(growable: false);
  }

        List<Post> pinnedPosts({bool includeClips = false}) {
          final ids = pinnedPostIds;
          return posts
          .where((p) => (includeClips || !p.isClip) && ids.contains(p.id))
          .toList(growable: false);
        }

  @override
  void onInit() {
    super.onInit();
    // 1. Check identity first, then load posts
    checkUserIdentity().then((_) => loadPosts());
  }

  /// Checks if a local file containing the user UUID exists.
  /// If not, it triggers the registration flow.
  Future<void> checkUserIdentity() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/user_identity.txt");

      if (await file.exists()) {
        // A. User exists: Read UUID and set state
        final storedUuid = await file.readAsString();
        currentUserId.value = storedUuid.trim();
        debugPrint("Logged in as: $storedUuid");
      } else {
        // B. New User: Generate UUID and show Dialog
        final newUuid = const Uuid().v4();

        // We need a slight delay to ensure the UI is ready for the dialog
        await Future.delayed(const Duration(milliseconds: 500));

        if (Get.context != null) {
          _showRegistrationDialog(Get.context!, newUuid, file);
        }
      }
    } catch (e) {
      debugPrint("Error checking identity: $e");
    }
  }

  /// Shows a dialog asking for details, then saves the user to Rust & File.
  void _showRegistrationDialog(BuildContext context, String newUuid, File identityFile) {
    final nameCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    final statusCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // User must register
      builder: (ctx) => AlertDialog(
        title: const Text("Welcome!"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("It looks like you are new. Please create your profile."),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: statusCtrl,
                decoration: const InputDecoration(labelText: "Status (e.g. Online)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bioCtrl,
                decoration: const InputDecoration(labelText: "Bio", border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                // 1. Create User in Rust DB
                await _registerUserInDb(
                  uuid: newUuid,
                  username: nameCtrl.text,
                  status: statusCtrl.text,
                  bio: bioCtrl.text,
                );

                // 2. Save UUID to local file
                await identityFile.writeAsString(newUuid);

                // 3. Update State
                currentUserId.value = newUuid;

                // 4. Refresh profiles so the current user appears in UI
                try {
                  Get.find<ProfilesController>().refreshProfiles();
                } catch (_) {}

                if (!ctx.mounted) return;
                Navigator.pop(ctx); // Close Dialog
                loadPosts(); // Reload to reflect changes
              }
            },
            child: const Text("Create Profile"),
          ),
        ],
      ),
    );
  }

  Future<void> _registerUserInDb({
    required String uuid,
    required String username,
    required String status,
    required String bio
  }) async {
    final dbPath = await _getDatabasePath();
    final db = rust.AppDatabase(path: dbPath);

    await db.createUser(
        user: rust.User(
          uuid: uuid,
          username: username,
          status: status,
          bio: bio,
          lastContact: DateTime.now().toUtc(),
          profilePicture: null,
        )
    );
  }

  Future<String> _resolveSourceTotemId(rust.AppDatabase db) async {
    try {
      final totems = await db.getAllTotems();
      if (totems.isEmpty) return '';
      return totems.first.uuid;
    } catch (_) {
      return '';
    }
  }

  Future<String> _getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/loom_app.db";
  }

  Future<void> loadPosts() async {
    try {
      final dbPath = await _getDatabasePath();
      final database = rust.AppDatabase(path: dbPath);
      final rustPosts = await database.getAllPosts();

      posts.assignAll(rustPosts.map((p) => p.toFlutterPost()).toList().reversed.toList());
    } catch (e) {
      debugPrint("Error loading posts: $e");
    }
  }

  Future<void> addPost(String title, String body, {String? imagePath}) async {
    // Check if we have a valid user ID before posting
    if (currentUserId.value.isEmpty) {
      Get.snackbar("Error", "You are not logged in.");
      return;
    }

    try {
      final dbPath = await _getDatabasePath();
      final db = rust.AppDatabase(path: dbPath);
      final sourceTotemId = await _resolveSourceTotemId(db);

      final newPost = rust.Post(
        uuid: const Uuid().v4(),
        userId: currentUserId.value,
        title: title,
        body: body,
        timestamp: DateTime.now().toUtc(),
        sourceTotem: sourceTotemId,
        image: imagePath,
      );

      await db.createPost(post: newPost);
      await loadPosts();

      Get.snackbar("Success", "Post created successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to create post: $e");
      debugPrint(e.toString());
    }
  }

  // 👇 ADDED METHOD: Logic to add a fake friend
  /// A debug utility to quickly add a test user (fake friend) to the database.
  Future<void> addFakeFriend() async {
    // Determine the next friend number for a unique name
    final profilesController = Get.isRegistered<ProfilesController>()
        ? Get.find<ProfilesController>()
        : null;

    // Use the current number of profiles + 1 for unique numbering
    final friendNumber = (profilesController?.profiles.length ?? 0) + 1;
    final fakeUuid = const Uuid().v4();
    final fakeUsername = 'Mock Friend $friendNumber';
    final fakeStatus = 'Testing Features';
    final fakeBio = 'This is a test profile created in debug mode.';

    try {
      // 1. Create User in Rust DB using the existing helper method
      await _registerUserInDb(
        uuid: fakeUuid,
        username: fakeUsername,
        status: fakeStatus,
        bio: fakeBio,
      );

      // 2. Refresh profiles so the new friend appears in UI
      if (profilesController != null) {
        await profilesController.refreshProfiles();
      } else {
        debugPrint("ProfilesController not registered, cannot refresh UI.");
      }

      Get.snackbar("Success", "$fakeUsername added successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to add fake friend: $e");
      debugPrint("Error adding fake friend: $e");
    }
  }

  // ... (Trending Tags and Clips helpers remain the same)
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

// ... (Keep your PostMapper extension here)
extension PostMapper on rust.Post {
  Post toFlutterPost() {
    return Post(
      id: uuid,
      authorId: userId,
      title: title,
      text: body,
      imageUrl: image,
      timeAgoLabel: _formatTimeAgo(timestamp),
      likes: 0,
      comments: 0,
      shares: 0,
      tags: _extractTags(body),
      isClip: false,
    );
  }

  List<String> _extractTags(String text) {
    final RegExp regex = RegExp(r"\#(\w+)");
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }

  String _formatTimeAgo(DateTime dt) {
    final localDt = dt.toLocal();
    final diff = DateTime.now().difference(localDt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}