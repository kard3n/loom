import 'package:get/get.dart';

class DirectMessagesController extends GetxController {
  final RxString emptyTitle = ''.obs;
  final RxString emptySubtitle = ''.obs;
  final RxString addTooltip = ''.obs;
  final RxString messageHint = ''.obs;
  final RxString sendTooltip = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final data = await fetchDirectMessagesCopy();
    emptyTitle.value = data.emptyTitle;
    emptySubtitle.value = data.emptySubtitle;
    addTooltip.value = data.addTooltip;
    messageHint.value = data.messageHint;
    sendTooltip.value = data.sendTooltip;
  }

  Future<DirectMessagesCopy> fetchDirectMessagesCopy() async {
    return const DirectMessagesCopy(
      emptyTitle: 'No messages yet',
      emptySubtitle: 'This is a placeholder direct message thread.\nStart a conversation when messaging is implemented.',
      addTooltip: 'Add (placeholder)',
      messageHint: 'Message (placeholder)',
      sendTooltip: 'Send (placeholder)',
    );
  }
}

class DirectMessagesCopy {
  const DirectMessagesCopy({
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.addTooltip,
    required this.messageHint,
    required this.sendTooltip,
  });

  final String emptyTitle;
  final String emptySubtitle;
  final String addTooltip;
  final String messageHint;
  final String sendTooltip;
}
