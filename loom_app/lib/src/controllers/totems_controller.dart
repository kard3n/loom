import 'package:get/get.dart';
import 'package:loom_app/src/models/totem.dart';

class TotemsController extends GetxController {
  final RxList<Totem> totems = <Totem>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    totems.assignAll(await fetchTotems());
  }

  Future<List<Totem>> fetchTotems() async {
    return const <Totem>[
      Totem(id: 't1', name: 'xy', description: 'desc', signalStrength: 3),
      Totem(id: 't2', name: 'ab', description: 'hello', signalStrength: 4),
    ];
  }
}
