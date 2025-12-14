import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TotemWifiCredentials {
  const TotemWifiCredentials({required this.ssid, required this.password});

  final String ssid;
  final String password;

  Map<String, Object?> toJson() => <String, Object?>{
    'ssid': ssid,
    'password': password,
  };

  static TotemWifiCredentials? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final ssid = (raw['ssid'] ?? '').toString().trim();
    final password = (raw['password'] ?? '').toString();
    if (ssid.isEmpty) return null;
    return TotemWifiCredentials(ssid: ssid, password: password);
  }
}

class TotemWifiStore {
  static const String _fileName = 'totem_wifi.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, TotemWifiCredentials>> readAll() async {
    final file = await _file();
    if (!await file.exists()) return <String, TotemWifiCredentials>{};

    try {
      final text = await file.readAsString();
      if (text.trim().isEmpty) return <String, TotemWifiCredentials>{};
      final decoded = jsonDecode(text);
      if (decoded is! Map) return <String, TotemWifiCredentials>{};

      final out = <String, TotemWifiCredentials>{};
      for (final entry in decoded.entries) {
        final id = entry.key.toString().trim();
        if (id.isEmpty) continue;
        final creds = TotemWifiCredentials.tryFromJson(entry.value);
        if (creds != null) out[id] = creds;
      }
      return out;
    } catch (_) {
      return <String, TotemWifiCredentials>{};
    }
  }

  Future<TotemWifiCredentials?> readForTotemId(String totemId) async {
    final id = totemId.trim();
    if (id.isEmpty) return null;
    final all = await readAll();
    return all[id];
  }

  Future<void> writeForTotemId({
    required String totemId,
    required String ssid,
    required String password,
  }) async {
    final id = totemId.trim();
    final trimmedSsid = ssid.trim();
    if (id.isEmpty) throw ArgumentError('totemId is empty');
    if (trimmedSsid.isEmpty) throw ArgumentError('ssid is empty');

    final all = await readAll();
    all[id] = TotemWifiCredentials(ssid: trimmedSsid, password: password);

    final file = await _file();
    final tmp = File('${file.path}.tmp');

    await tmp.writeAsString(
      jsonEncode(all.map((k, v) => MapEntry(k, v.toJson()))),
    );

    if (await file.exists()) {
      await file.delete();
    }
    await tmp.rename(file.path);
  }
}
