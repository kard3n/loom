import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loom_app/src/rust/api/simple.dart' as rust;
import 'package:path_provider/path_provider.dart';

Future<void> updateUserDatabase() async {
  final dbPath = await _getDatabasePath();
  final db = rust.AppDatabase(path: dbPath);

  // 1. Prepare the comparison request
  final compareUrl = Uri.parse('http://192.168.71.1/users/compare');

  // Get all local users to compare
  final List<rust.User> allUsers = await db.getAllUsers();
  final List<String> localUserIds = allUsers.map((u) => u.uuid).toList();

  final Map<String, dynamic> dataToSend = {
    'user_uuids': localUserIds,
  };

  try {
    // 2. Send the comparison list (POST)
    final response = await http.post(
      compareUrl,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(dataToSend),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // ---------------------------------------------------------
      // EXPECTED SERVER RESPONSE STRUCTURE:
      // {
      //   "client_missing": ["uuid-1", "uuid-2"],  <-- IDs app needs to GET
      //   "totem_missing": ["uuid-3", "uuid-4"]   <-- IDs app needs to POST
      // }
      // ---------------------------------------------------------

      final Map<String, dynamic> result = jsonDecode(response.body);

      // A. HANDLE DOWNLOADS (Server has, App needs)
      final List<String> toDownload = List<String>.from(
          result['client_missing'] ?? []);

      if (toDownload.isNotEmpty) {
        print('Downloading ${toDownload.length} new users...');
        List<Future<Map<String, dynamic>>> fetchFutures = toDownload.map((
            id) async {
          final detailUrl = Uri.parse('http://192.168.71.1/users/$id');
          final resp = await http.get(detailUrl);
          if (resp.statusCode == 200)
            return jsonDecode(resp.body) as Map<String, dynamic>;
          throw Exception('Failed to load user $id');
        }).toList();

        final newUsers = await Future.wait(fetchFutures);

        for (var userJson in newUsers) {
          final rawLastContact = userJson['last_contact'];
          final DateTime lastContact = rawLastContact != null
              ? DateTime.tryParse(rawLastContact) ?? DateTime.now()
              : DateTime.now();

          db.createUser(user: rust.User(
            uuid: userJson['uuid'],
            username: userJson['username'],
            status: userJson['status'],
            bio: userJson['bio'],
            lastContact: lastContact,
          ));
        }
      }

      // B. HANDLE UPLOADS (App has, Server needs)
      final List<String> toUpload = List<String>.from(
          result['totem_missing'] ?? []);

      if (toUpload.isNotEmpty) {
        print('Uploading ${toUpload.length} users to server...');

        // Filter the local user list to find the full objects required
        final usersToPush = allUsers.where((u) => toUpload.contains(u.uuid));

        List<Future<void>> uploadFutures = usersToPush.map((user) async {
          final uploadUrl = Uri.parse(
              'http://192.168.71.1/users/create'); // Adjust endpoint

          final body = {
            'uuid': user.uuid,
            'username': user.username,
            'status': user.status,
            'bio': user.bio,
            'last_contact': user.lastContact.toIso8601String(),
          };

          await http.post(
            uploadUrl,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(body),
          );
        }).toList();

        await Future.wait(uploadFutures);
        print('Successfully uploaded users.');
      }
    } else {
      print('Failed to compare users: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in user sync: $e');
  }
}

Future<void> updatePostDatabase() async {
  final dbPath = await _getDatabasePath();
  final db = rust.AppDatabase(path: dbPath);

  final DateTime now = DateTime.now();
  final DateTime startTime = now.subtract(const Duration(days: 1));
  final DateTime endTime = now.add(const Duration(days: 1));

  final compareUrl = Uri.parse('http://192.168.71.1/posts/compare');

  final List<String> localPostIds = await db.getPostIdsInRange(
      start: startTime, end: endTime);

  final Map<String, dynamic> dataToSend = {
    'time_start': startTime.toIso8601String(),
    'time_end': endTime.toIso8601String(),
    'post_uuids': localPostIds
  };

  try {
    final response = await http.post(
      compareUrl,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(dataToSend),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);

      // A. HANDLE DOWNLOADS
      final List<String> toDownload = List<String>.from(
          result['client_missing'] ?? []);

      if (toDownload.isNotEmpty) {
        List<Future<Map<String, dynamic>>> fetchFutures = toDownload.map((
            id) async {
          final detailUrl = Uri.parse('http://192.168.71.1/posts/$id');
          final resp = await http.get(detailUrl);
          if (resp.statusCode == 200) {
            return jsonDecode(resp.body) as Map<String, dynamic>;
          }
          throw Exception('Failed to load post $id');
        }
        ).toList();

        final newPosts = await Future.wait(fetchFutures);

        for (var post in newPosts) {
          final rawDate = post['timestamp'];
          final DateTime timestamp = rawDate != null
              ? DateTime.tryParse(rawDate) ?? DateTime.now()
              : DateTime.now();

          db.createPost(post: rust.Post(
              uuid: post['uuid'],
              userId: post['user_id'],
              title: post['title'],
              body: post['body'],
              timestamp: timestamp,
              sourceTotem: post['source_totem']
          ));
        }
      }

      // B. HANDLE UPLOADS
      final List<String> toUpload = List<String>.from(
          result['totem_missing'] ?? []);

      if (toUpload.isNotEmpty) {
        print('Uploading ${toUpload.length} posts...');


        final postsInRange = await Future.wait(
            (await db.getPostIdsInRange(start: startTime, end: endTime))
                .map((id) => db.getPostById(uuid: id))
        );
        final postsToPush = postsInRange.where((p) =>
            toUpload.contains(p.uuid));

        List<Future<void>> uploadFutures = postsToPush.map((post) async {
          final uploadUrl = Uri.parse('http://192.168.71.1/posts/create');

          final body = {
            'uuid': post.uuid,
            'user_id': post.userId,
            'title': post.title,
            'body': post.body,
            'timestamp': post.timestamp.toIso8601String(),
            'source_totem': post.sourceTotem,
          };

          await http.post(
            uploadUrl,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(body),
          );
        }).toList();

        await Future.wait(uploadFutures);
        print('Successfully uploaded posts.');
      }
    } else {
      print('Failed to compare posts: ${response.statusCode}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}

Future<String> _getDatabasePath() async {
  final directory = await getApplicationDocumentsDirectory();
  return "${directory.path}/loom_app.db";
}