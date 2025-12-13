import 'package:get/get.dart';

class MainController extends GetxController {
	final RxInt selectedIndex = 0.obs;

	void selectTab(int index) {
		if (index == selectedIndex.value) return;
		selectedIndex.value = index;
	}
}

