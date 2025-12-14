import 'package:get/get.dart';
import 'package:loom_app/src/models/totem.dart';
import 'package:loom_app/src/network/wifi_connector.dart';
import 'package:loom_app/src/storage/totem_wifi_store.dart';
import 'package:loom_app/src/rust/api/simple.dart' as rust;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class TotemsController extends GetxController {
  final RxList<Totem> totems = <Totem>[].obs;

  final TotemWifiStore _wifiStore = TotemWifiStore();
  final WifiConnector _wifiConnector = WifiConnector();

  final RxBool wifiConnectInProgress = false.obs;

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

      final wifiById = await _wifiStore.readAll();

      totems.assignAll(
        rustTotems
            .map(
              (t) => Totem(
                id: t.uuid,
                name: t.name,
                description: t.location,
                signalStrength: 0,
                wifiSsid: wifiById[t.uuid]?.ssid,
                wifiPassword: wifiById[t.uuid]?.password,
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
    String? wifiSsid,
    String? wifiPassword,
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

    final ssid = (wifiSsid ?? '').trim();
    if (ssid.isNotEmpty) {
      try {
        await _wifiStore.writeForTotemId(
          totemId: trimmedId,
          ssid: ssid,
          password: wifiPassword ?? '',
        );
      } catch (_) {}
    }

    await loadTotems();
  }

  Future<bool> connectToTotemWifi(Totem totem) async {
    final ssid = (totem.wifiSsid ?? '').trim();
    final password = totem.wifiPassword ?? '';

    if (ssid.isEmpty) {
      Get.snackbar('Wi‑Fi', 'No saved SSID for "${totem.name}"');
      return false;
    }

    if (wifiConnectInProgress.value) return false;
    wifiConnectInProgress.value = true;

    try {
      if (Platform.isAndroid) {
        final status = await Permission.locationWhenInUse.request();
        if (!status.isGranted) {
          Get.snackbar(
            'Wi‑Fi',
            'Location permission required to connect to Wi‑Fi',
          );
          return false;
        }
      }

      await _wifiConnector.disconnectIfConnectedToOther(targetSsid: ssid);

      final ok = await _wifiConnector.connect(ssid: ssid, password: password);
      Get.snackbar('Wi‑Fi', ok ? 'Connected to "$ssid"' : 'Failed to connect');
      return ok;
    } catch (e) {
      Get.snackbar('Wi‑Fi', 'Connect error: $e');
      return false;
    } finally {
      wifiConnectInProgress.value = false;
    }
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
