import 'package:get/get.dart';
import 'package:loom_app/src/models/profile.dart';

class ProfilesController extends GetxController {
  final RxList<Profile> profiles = <Profile>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    profiles.assignAll(await fetchProfiles());
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

  Future<List<Profile>> fetchProfiles() async {
    return const <Profile>[
      Profile(
        id: 'me',
        name: 'You',
        handle: '@you',
        status: 'Here to build.',
        bio: 'A short vibe line goes here.',
        lastSeenLabel: 'now',
        isCurrentUser: true,
      ),
      Profile(
        id: 'ava',
        name: 'Ava Chen',
        handle: '@avacreates',
        status: 'Sketching new identity for Loom.',
        bio: 'Designing rituals and systems.',
        lastSeenLabel: '19 hours ago',
      ),
      Profile(
        id: 'miles',
        name: 'Miles Carter',
        handle: '@milesloops',
        status: 'Pair programming with community.',
        bio: 'Shipping tiny experiments daily.',
        lastSeenLabel: '15 minutes ago',
      ),
      Profile(
        id: 'sasha',
        name: 'Sasha Park',
        handle: '@sashapark',
        status: 'Collecting Qs for AMA tomorrow.',
        bio: 'Building healthier online spaces.',
        lastSeenLabel: '4 days ago',
      ),
      Profile(
        id: 'lina',
        name: 'Lina Patel',
        handle: '@linapatel',
        status: 'Planning the winter retreat.',
        bio: 'Docs, travel, and cozy vibes.',
        lastSeenLabel: '42 seconds ago',
      ),
    ];
  }
}
