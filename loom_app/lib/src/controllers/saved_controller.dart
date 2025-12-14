import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavedController extends GetxController {
  final RxString title = ''.obs;
  final RxString subtitle = ''.obs;
  final Rx<Color> seedColor = const Color(0xFFFFB300).obs;
  final Rx<Color> scaffoldBackgroundColor = const Color(0xFFFFFBF2).obs;

  final RxList<SavedItemCard> items = <SavedItemCard>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final data = await fetchSavedData();
    title.value = data.title;
    subtitle.value = data.subtitle;
    seedColor.value = data.seedColor;
    scaffoldBackgroundColor.value = data.scaffoldBackgroundColor;
    items.assignAll(data.items);
  }

  Future<SavedData> fetchSavedData() async {
    return const SavedData(
      title: '',
      subtitle: '',
      seedColor: Color(0xFFFFB300),
      scaffoldBackgroundColor: Color(0xFFFFFBF2),
      items: <SavedItemCard>[],
    );
  }
}

class SavedItemCard {
  const SavedItemCard({
    required this.title,
    required this.author,
    required this.excerpt,
    required this.tag,
    required this.savedAgo,
    required this.accent,
  });

  final String title;
  final String author;
  final String excerpt;
  final String tag;
  final String savedAgo;
  final Color accent;
}

class SavedData {
  const SavedData({
    required this.title,
    required this.subtitle,
    required this.seedColor,
    required this.scaffoldBackgroundColor,
    required this.items,
  });

  final String title;
  final String subtitle;
  final Color seedColor;
  final Color scaffoldBackgroundColor;
  final List<SavedItemCard> items;
}
