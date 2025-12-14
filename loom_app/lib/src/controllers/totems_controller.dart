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
      final dbPath = await _getDatabasePath();
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

  Future<void> upsertTotem({
    required String id,
    required String name,
    String location = '',
  }) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return;

    final trimmedName = name.trim().isEmpty ? trimmedId : name.trim();
    final now = DateTime.now();

    final dbPath = await _getDatabasePath();
    final db = rust.AppDatabase(path: dbPath);

    try {
      await db.createTotem(
        totem: rust.Totem(
          uuid: trimmedId,
          name: trimmedName,
          location: location,
          lastContact: now,
        ),
      );
    } catch (_) {
      // If the totem already exists, at least update last contact.
      try {
        await db.updateTotemLastContact(uuid: trimmedId, lastContact: now);
      } catch (_) {}
    }

    await loadTotems();
  }

  Future<String> _getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/loom_app.db';
  }

  Totem? byId(String id) {
    for (final t in totems) {
      if (t.id == id) return t;
    }
    return null;
  }

  Totem? byName(String name) {
    for (final t in totems) {
      if (t.name == name) return t;
    }
    return null;
  }

  Totem? resolveTotemFromScan(String scanned) {
    final String raw = scanned.trim();
    if (raw.isEmpty) return null;

    // Accept raw UUID, name, or URLs that embed UUID.
    final RegExp uuidRe = RegExp(
      r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b',
    );
    final Match? uuidMatch = uuidRe.firstMatch(raw);
    final String candidateId = uuidMatch?.group(0) ?? raw;

    final Totem? byIdResult = byId(candidateId);
    if (byIdResult != null) return byIdResult;

    final Totem? byNameResult = byName(raw);
    if (byNameResult != null) return byNameResult;

    final String normalized = raw.toLowerCase();
    for (final Totem t in totems) {
      if (t.name.toLowerCase() == normalized) return t;
    }

    return null;
  }
}
