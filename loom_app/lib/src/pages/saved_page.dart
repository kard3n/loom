import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/saved_controller.dart';

class SavedPage extends GetView<SavedController> {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    return Obx(() {
      final ThemeData sectionTheme = base.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: controller.seedColor.value,
          brightness: base.brightness,
        ),
        scaffoldBackgroundColor: controller.scaffoldBackgroundColor.value,
      );

      final items = controller.items;
      return Theme(
        data: sectionTheme,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
          itemCount: items.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      controller.title.value,
                      style: sectionTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.subtitle.value,
                      style: sectionTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            final SavedItemCard item = items[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                child: Container(
                  decoration: BoxDecoration(
                    color: item.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.title,
                                    style: sectionTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'by ${item.author}',
                                    style: sectionTheme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.more_horiz_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.excerpt,
                          style: sectionTheme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Chip(
                              avatar: const Icon(Icons.bookmark_added_rounded, size: 16),
                              label: Text(item.tag),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                            ),
                            Text(
                              item.savedAgo,
                              style: sectionTheme.textTheme.bodySmall?.copyWith(
                                color: sectionTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
