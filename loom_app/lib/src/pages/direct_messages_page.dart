import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/direct_messages_controller.dart';

class DirectMessagesPage extends GetView<DirectMessagesController> {
  const DirectMessagesPage({super.key, required this.friendName});

  final String friendName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: Text(friendName),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 56,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            controller.emptyTitle.value,
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.emptySubtitle.value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const _PlaceholderComposer(),
            ],
          ),
        ),
      );
    });
  }
}

class _PlaceholderComposer extends StatelessWidget {
  const _PlaceholderComposer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<DirectMessagesController>();
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
            children: [
              Obx(
                () => IconButton(
                  onPressed: null,
                  icon: const Icon(Icons.add),
                  tooltip: controller.addTooltip.value,
                ),
              ),
              Expanded(
                child: Obx(
                  () => TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: controller.messageHint.value,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => IconButton.filled(
                  onPressed: null,
                  icon: const Icon(Icons.send),
                  tooltip: controller.sendTooltip.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
