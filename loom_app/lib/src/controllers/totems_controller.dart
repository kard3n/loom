import 'dart:io';
import 'package:get/get.dart';
import 'package:loom_app/src/models/totem.dart';
import 'package:loom_app/src/rust/api/simple.dart' as rust;
import 'package:path_provider/path_provider.dart';

class TotemsController extends GetxController {
  final RxList<Totem> totems = <Totem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTotems();
  }

  Future<void> loadTotems() async {
    try {
      final dbPath = _getDatabasePath();
      final db = rust.AppDatabase(path: dbPath);
      final rustTotems = await db.getAllTotems();

      totems.assignAll(
        rustTotems
            .map(
              (t) => Totem(
                id: t.uuid,
                name: t.name,
                description: t.location,
                signalStrength: 0,
              ),
            )
            .toList(growable: false),
      );
    } catch (_) {
      totems.assignAll(const <Totem>[]);
    }
  }

  String _getDatabasePath() {
    final directory = Directory.current;
    return '${directory.path}/loom_app.db';
  }
}
