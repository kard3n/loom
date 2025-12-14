import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:loom_app/src/network/ble_provisioning_spec.dart';

class BleProvisioningStatus {
  const BleProvisioningStatus({required this.raw, required this.timestamp});

  final String raw;
  final DateTime timestamp;

  @override
  String toString() => raw;
}

class BleProvisioner {
  BleProvisioner({FlutterReactiveBle? ble}) : _ble = ble ?? FlutterReactiveBle();

  final FlutterReactiveBle _ble;

  static bool _containsAscii(Uint8List data, String needle) {
    if (needle.isEmpty || data.isEmpty) return false;
    final pattern = Uint8List.fromList(ascii.encode(needle));
    if (pattern.length > data.length) return false;

    for (var i = 0; i <= data.length - pattern.length; i++) {
      var match = true;
      for (var j = 0; j < pattern.length; j++) {
        if (data[i + j] != pattern[j]) {
          match = false;
          break;
        }
      }
      if (match) return true;
    }
    return false;
  }

  static String _toPrintableAscii(Uint8List data, {int maxLen = 24}) {
    if (data.isEmpty) return '';
    final take = data.length < maxLen ? data.length : maxLen;
    final codes = List<int>.generate(take, (i) {
      final b = data[i];
      return (b >= 32 && b <= 126) ? b : 46; // '.'
    }, growable: false);
    return String.fromCharCodes(codes);
  }

  static String _toHex(Uint8List data, {int maxBytes = 16}) {
    if (data.isEmpty) return '';
    final take = data.length < maxBytes ? data.length : maxBytes;
    final parts = <String>[];
    for (var i = 0; i < take; i++) {
      parts.add(data[i].toRadixString(16).padLeft(2, '0'));
    }
    final suffix = data.length > take ? '…' : '';
    return '${parts.join(' ')}$suffix';
  }

  static String _manufacturerSummary(Uint8List data) {
    if (data.isEmpty) return 'manufacturerData: <empty>';
    final asciiPreview = _toPrintableAscii(data);
    final hexPreview = _toHex(data);
    return 'manufacturerData: ${data.length}B, ascii="$asciiPreview", hex=$hexPreview';
  }

  Stream<DiscoveredDevice> scan({
    String? namePrefix,
    bool verbose = false,
    void Function(String message)? onLog,
  }) {
    return _ble.scanForDevices(
      withServices: <Uuid>[],
      scanMode: ScanMode.lowLatency,
    ).where((d) {
      final hasTotemMarker =
          _containsAscii(d.manufacturerData, 'Totem') ||
          _containsAscii(d.manufacturerData, 'totem') ||
          _containsAscii(d.manufacturerData, 'TOTEM');
      if (verbose) {
        onLog?.call(
          'SCAN: seen id=${d.id} name="${d.name}" rssi=${d.rssi} '
          '${_manufacturerSummary(d.manufacturerData)} '
          'totemMarker=$hasTotemMarker',
        );
      }

      // Identify the correct device by the advertised manufacturer data marker.
      if (!hasTotemMarker) {
        if (verbose) onLog?.call('SCAN: skip (no "Totem" marker) id=${d.id}');
        return false;
      }

      if (namePrefix == null || namePrefix.isEmpty) return true;
      final ok = d.name.toLowerCase().startsWith(namePrefix.toLowerCase());
      if (verbose && !ok) {
        onLog?.call('SCAN: skip (namePrefix "$namePrefix") id=${d.id} name="${d.name}"');
      }
      return ok;
    });
  }

  Stream<ConnectionStateUpdate> connect(String deviceId) {
    return _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 12),
    );
  }

  Future<void> disconnect(String deviceId) async {
    // flutter_reactive_ble disconnects when the connection stream subscription
    // is cancelled. The controller handles that by cancelling its subscription.
    // This method is kept for API symmetry.
    return;
  }

  QualifiedCharacteristic _qc(String deviceId, Uuid characteristicId) {
    return QualifiedCharacteristic(
      serviceId: BleProvisioningSpec.service,
      characteristicId: characteristicId,
      deviceId: deviceId,
    );
  }

  Future<String> readString(String deviceId, Uuid characteristicId) async {
    final qc = _qc(deviceId, characteristicId);
    final bytes = await _ble.readCharacteristic(qc);
    return utf8.decode(bytes, allowMalformed: true).trim();
  }

  Future<void> writeString(String deviceId, Uuid characteristicId, String value) async {
    await _ble.writeCharacteristicWithResponse(
      _qc(deviceId, characteristicId),
      value: Uint8List.fromList(utf8.encode(value)),
    );
  }

  Future<Map<String, String>> readTotemInfo(String deviceId) async {
    final id = await readString(deviceId, BleProvisioningSpec.totemId);
    final name = await readString(deviceId, BleProvisioningSpec.totemName);
    final ssid = await readString(deviceId, BleProvisioningSpec.wifiSsid);
    final pass = await readString(deviceId, BleProvisioningSpec.wifiPass);
    return <String, String>{
      'totemId': id,
      'totemName': name,
      'wifiSsid': ssid,
      'wifiPass': pass,
    };
  }

  /// Writes Wi‑Fi SSID and password to the Totem Wi‑Fi characteristics.
  ///
  /// Note: your current firmware snippet shows these characteristics as READ-only.
  /// If that remains the case, these writes will fail until firmware is updated
  /// to allow Write/WriteWithoutResponse.
  Future<void> provisionWifi({
    required String deviceId,
    required String ssid,
    required String pass,
  }) async {
    await writeString(deviceId, BleProvisioningSpec.wifiSsid, ssid);
    await writeString(deviceId, BleProvisioningSpec.wifiPass, pass);
  }
}
