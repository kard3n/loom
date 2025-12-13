import 'package:get/get.dart';

import '../controllers/clips_controller.dart';
import '../controllers/direct_messages_controller.dart';
import '../controllers/feed_controller.dart';
import '../controllers/friends_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/saved_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/totems_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(MainController(), permanent: true);

    Get.put(FeedController(), permanent: true);
    Get.put(FriendsController(), permanent: true);
    Get.put(TotemsController(), permanent: true);
    Get.put(SavedController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put(ClipsController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    Get.put(DirectMessagesController(), permanent: true);
  }
}
