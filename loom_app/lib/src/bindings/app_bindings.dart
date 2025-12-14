import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../controllers/images_controller.dart';
import '../controllers/posts_controller.dart';
import '../controllers/profiles_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/totems_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(MainController(), permanent: true);

    Get.put(ProfilesController(), permanent: true);
    Get.put(PostsController(), permanent: true);
    Get.put(TotemsController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put(ImagesController(), permanent: true);

    // Legacy page-specific controllers intentionally not registered.
    // They are replaced by ProfilesController/PostsController/TotemsController.
  }
}
