import 'dart:io';

import 'package:wifi_iot/wifi_iot.dart';

class WifiConnector {
  Future<bool> connect({
    required String ssid,
    required String password,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError('Wi-Fi connect is only supported on Android/iOS');
    }

    final trimmedSsid = ssid.trim();
    if (trimmedSsid.isEmpty) {
      throw ArgumentError('SSID is empty');
    }

    final security = password.isEmpty ? NetworkSecurity.NONE : NetworkSecurity.WPA;

    // Note: On Android 10+ this may still fail if Location services are OFF.
    final ok = await WiFiForIoTPlugin.connect(
      trimmedSsid,
      password: password,
      security: security,
      joinOnce: true,
      withInternet: true,
    );

    return ok;
  }
}
