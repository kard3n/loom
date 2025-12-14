import 'dart:io';

import 'package:loom_app/src/network/networker.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiConnector {
  Future<String?> getCurrentSsid() async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;

    // wifi_iot may return null/empty/"<unknown ssid>" depending on platform/state.
    final ssid = (await WiFiForIoTPlugin.getSSID())?.trim();
    if (ssid == null || ssid.isEmpty) return null;
    if (ssid.toLowerCase() == '<unknown ssid>') return null;
    return ssid;
  }

  Future<bool> disconnectCurrent() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError(
        'Wi-Fi disconnect is only supported on Android/iOS',
      );
    }
    // Best-effort: on newer Android versions this may be limited by OS.
    return WiFiForIoTPlugin.disconnect();
  }

  /// Disconnects if currently connected to a different SSID.
  ///
  /// Returns true if we disconnected (or were already disconnected), false if
  /// disconnect failed.
  Future<bool> disconnectIfConnectedToOther({
    required String targetSsid,
  }) async {
    final target = targetSsid.trim();
    if (target.isEmpty) throw ArgumentError('targetSsid is empty');

    final current = await getCurrentSsid();
    if (current == null) return true;
    if (current == target) return true;

    return disconnectCurrent();
  }

  Future<bool> connect({required String ssid, required String password}) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError('Wi-Fi connect is only supported on Android/iOS');
    }

    final trimmedSsid = ssid.trim();
    if (trimmedSsid.isEmpty) {
      throw ArgumentError('SSID is empty');
    }

    final security = password.isEmpty
        ? NetworkSecurity.NONE
        : NetworkSecurity.WPA;

    // Note: On Android 10+ this may still fail if Location services are OFF.
    final ok = await WiFiForIoTPlugin.connect(
      trimmedSsid,
      password: password,
      security: security,
      joinOnce: true,
      withInternet: true,
    );

    await updateUserDatabase();
    await updatePostDatabase();

    return ok;
  }
}
