import 'package:get/get.dart';

class TotemsController extends GetxController {
  final RxString greeting = ''.obs;
  final RxList<TotemCard> totems = <TotemCard>[].obs;

  final RxString connectLabel = ''.obs;
  final RxString nameLabel = ''.obs;
  final RxString descriptionLabel = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final data = await fetchTotemsData();
    greeting.value = data.greeting;
    connectLabel.value = data.connectLabel;
    nameLabel.value = data.nameLabel;
    descriptionLabel.value = data.descriptionLabel;
    totems.assignAll(data.totems);
  }

  Future<TotemsData> fetchTotemsData() async {
    return const TotemsData(
      greeting: 'These are the available Totems:',
      connectLabel: 'Connect',
      nameLabel: 'Name',
      descriptionLabel: 'Description',
      totems: <TotemCard>[
        TotemCard(name: 'xy', description: 'desc', signalStrength: 3),
        TotemCard(name: 'ab', description: 'hello', signalStrength: 4),
      ],
    );
  }
}

class TotemCard {
  const TotemCard({required this.name, required this.description, required this.signalStrength});

  final String name;
  final String description;
  final int signalStrength;
}

class TotemsData {
  const TotemsData({
    required this.greeting,
    required this.connectLabel,
    required this.nameLabel,
    required this.descriptionLabel,
    required this.totems,
  });

  final String greeting;
  final String connectLabel;
  final String nameLabel;
  final String descriptionLabel;
  final List<TotemCard> totems;
}
