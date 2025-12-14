import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// UUIDs for the BLE Wi-Fi provisioning GATT service.
///
/// Adjust these to match your firmware.
class BleProvisioningSpec {
  /// Totem info service UUID: e5d63081-6e16-427b-8ae3-66fdffafa604
  static final Uuid service = Uuid.parse('e5d63081-6e16-427b-8ae3-66fdffafa604');

  /// totem_id characteristic UUID: e5d63082-6e16-427b-8ae3-66fdffafa604
  static final Uuid totemId = Uuid.parse('e5d63082-6e16-427b-8ae3-66fdffafa604');

  /// totem_name characteristic UUID: e5d63083-6e16-427b-8ae3-66fdffafa604
  static final Uuid totemName = Uuid.parse('e5d63083-6e16-427b-8ae3-66fdffafa604');

  /// totem_wifi_ssid characteristic UUID: e5d63084-6e16-427b-8ae3-66fdffafa604
  static final Uuid wifiSsid = Uuid.parse('e5d63084-6e16-427b-8ae3-66fdffafa604');

  /// totem_wifi_pass characteristic UUID: e5d63085-6e16-427b-8ae3-66fdffafa604
  static final Uuid wifiPass = Uuid.parse('e5d63085-6e16-427b-8ae3-66fdffafa604');
}
