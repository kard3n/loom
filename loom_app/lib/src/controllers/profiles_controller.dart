import 'dart:io';

import 'package:get/get.dart';
import 'package:loom_app/src/models/profile.dart';
import 'package:loom_app/src/rust/api/simple.dart' as rust;
import 'package:path_provider/path_provider.dart';

class ProfilesController extends GetxController {
  final RxList<Profile> profiles = <Profile>[].obs;
  final RxString currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadIdentity().then((_) => loadProfiles());
  }

  Future<void> refreshProfiles() async {
    await _loadIdentity();
    await loadProfiles();
  }

  Future<void> _loadIdentity() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/user_identity.txt');
      if (await file.exists()) {
        currentUserId.value = (await file.readAsString()).trim();
      } else {
        currentUserId.value = '';
      }
    } catch (_) {
      currentUserId.value = '';
    }
  }

  Future<String> _getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/loom_app.db';
  }

  Future<void> loadProfiles() async {
    try {
      final dbPath = await _getDatabasePath();
      final database = rust.AppDatabase(path: dbPath);
      final rustUsers = await database.getAllUsers();

      profiles.assignAll(
        rustUsers
            .map(
              (u) => Profile(
                id: u.uuid,
                name: u.username,
                handle: _handleFromUsername(u.username),
                status: u.status,
                bio: u.bio,
                lastSeenLabel: _formatTimeAgo(u.lastContact),
                isCurrentUser: u.uuid == currentUserId.value,
              ),
            )
            .toList(growable: false),
      );
    } catch (_) {
      profiles.assignAll(const <Profile>[]);
    }
  }

  Profile? byId(String id) {
    for (final p in profiles) {
      if (p.id == id) return p;
    }
    return null;
  }

  Profile? byName(String name) {
    for (final p in profiles) {
      if (p.name == name) return p;
    }
    return null;
  }

  Profile? currentUser() {
    for (final p in profiles) {
      if (p.isCurrentUser) return p;
    }
    return null;
  }
}

String _handleFromUsername(String username) {
  final trimmed = username.trim();
  if (trimmed.isEmpty) return '@user';
  final normalized = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  return normalized.startsWith('@') ? normalized : '@$normalized';
}

String _formatTimeAgo(DateTime dt) {
  final localDt = dt.toLocal();
  final diff = DateTime.now().difference(localDt);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}
