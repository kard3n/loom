import 'dart:async';
import 'dart:io';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/network/ble_provisioner.dart';
import 'package:loom_app/src/network/wifi_connector.dart';
import 'package:permission_handler/permission_handler.dart';

enum BleProvisioningPhase {
  idle,
  scanning,
  connecting,
  connected,
  provisioning,
  done,
  error,
}

class BleProvisioningController extends GetxController {
  BleProvisioningController({BleProvisioner? provisioner})
      : _provisioner = provisioner ?? BleProvisioner();

  final BleProvisioner _provisioner;
  final WifiConnector _wifiConnector = WifiConnector();

  final Rx<BleProvisioningPhase> phase = BleProvisioningPhase.idle.obs;
  final RxString error = ''.obs;

  final RxList<DiscoveredDevice> devices = <DiscoveredDevice>[].obs;
  final RxnString connectedDeviceId = RxnString();
  final RxnString connectedDeviceName = RxnString();

  final RxnString totemId = RxnString();
  final RxnString totemName = RxnString();
  final RxnString currentWifiSsid = RxnString();
  final RxnString currentWifiPass = RxnString();

  // Autofill targets for the UI.
  final RxnString suggestedWifiSsid = RxnString();
  final RxnString suggestedWifiPass = RxnString();

  final RxBool wifiConnectInProgress = false.obs;

  final RxList<String> log = <String>[].obs;

  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connSub;

  Future<void> startScan({String? namePrefix}) async {
    stopScan();
    devices.clear();
    error.value = '';

    _append('BLE: startScan(namePrefix=${namePrefix ?? "<none>"})');

    final ok = await _ensureBleScanPermissions();
    if (!ok) {
      phase.value = BleProvisioningPhase.error;
      _append('Missing permissions for BLE scan.');
      return;
    }

    phase.value = BleProvisioningPhase.scanning;
    _append('Scanning...');

    _scanSub = _provisioner
        .scan(
          namePrefix: namePrefix,
          verbose: true,
          onLog: _append,
        )
        .listen(
      (d) {
        final idx = devices.indexWhere((e) => e.id == d.id);
        if (idx == -1) {
          devices.add(d);
          _append('SCAN: add device id=${d.id} name="${d.name}" rssi=${d.rssi}');
        } else {
          devices[idx] = d;
          devices.refresh();
        }
      },
      onError: (e) {
        phase.value = BleProvisioningPhase.error;
        error.value = e.toString();
        _append('Scan error: $e');
      },
    );
  }

  void stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
    if (phase.value == BleProvisioningPhase.scanning) {
      phase.value = BleProvisioningPhase.idle;
    }
    _append('BLE: stopScan()');
  }

  Future<bool> _ensureBleScanPermissions() async {
    if (!Platform.isAndroid) return true;

    _append('BLE: requesting Android runtime permissions (location + bluetooth scan/connect)');

    // Android BLE scanning typically requires location permission on many devices/OS versions.
    // Android 12+ also requires BLUETOOTH_SCAN/CONNECT runtime permissions.
    final Map<Permission, PermissionStatus> statuses = await <Permission>[
      Permission.locationWhenInUse,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    final summary = statuses.entries
        .map((e) => '${e.key}=${e.value}')
        .join(', ');
    _append('BLE: permission results: $summary');

    final denied = statuses.entries.where((e) => !e.value.isGranted).toList(growable: false);
    if (denied.isEmpty) return true;

    final permanentlyDenied = statuses.entries.any((e) => e.value.isPermanentlyDenied);
    error.value = permanentlyDenied
        ? 'Permissions permanently denied. Enable Location/Bluetooth permissions in Settings.'
        : 'Permissions denied. Please allow Location/Bluetooth permissions.';
    _append('BLE: permissions denied (permanentlyDenied=$permanentlyDenied)');
    return false;
  }

  Future<void> connect(DiscoveredDevice device) async {
    await disconnect();
    stopScan();

    phase.value = BleProvisioningPhase.connecting;
    error.value = '';
    _append('Connecting to ${device.name.isEmpty ? device.id : device.name}...');

    final completer = Completer<void>();

    _connSub = _provisioner.connect(device.id).listen(
      (update) {
        _append('CONN: state=${update.connectionState} id=${update.deviceId} failure=${update.failure}');
        if (update.connectionState == DeviceConnectionState.connected) {
          connectedDeviceId.value = device.id;
          connectedDeviceName.value = device.name;
          phase.value = BleProvisioningPhase.connected;
          _append('Connected.');

          _provisioner.readTotemInfo(device.id).then(
            (info) {
              totemId.value = info['totemId'];
              totemName.value = info['totemName'];
              currentWifiSsid.value = info['wifiSsid'];
              currentWifiPass.value = info['wifiPass'];

              // Fill blanks in UI.
              suggestedWifiSsid.value = info['wifiSsid'];
              suggestedWifiPass.value = info['wifiPass'];

              _append('Totem: ${totemName.value ?? ''} (${totemId.value ?? ''})');
              if ((currentWifiSsid.value ?? '').isNotEmpty) {
                _append('Current Wi‑Fi SSID: ${currentWifiSsid.value}');
              }

              // Auto-connect phone to the provided Wi‑Fi.
              final ssid = (info['wifiSsid'] ?? '').trim();
              final pass = info['wifiPass'] ?? '';
              if (ssid.isNotEmpty) {
                _append('Wi‑Fi: attempting auto-connect (ssid="$ssid", passLen=${pass.length})');
                connectToWifi(ssid: ssid, pass: pass);
              } else {
                _append('Wi‑Fi: no SSID provided by Totem; skipping auto-connect');
              }
            },
            onError: (e) {
              _append('Read totem info failed: $e');
            },
          );

          if (!completer.isCompleted) completer.complete();
        }

        if (update.connectionState == DeviceConnectionState.disconnected) {
          _append('Disconnected.');
          if (connectedDeviceId.value == device.id) {
            connectedDeviceId.value = null;
            connectedDeviceName.value = null;
          }
          if (!completer.isCompleted) completer.complete();
        }
      },
      onError: (e) {
        phase.value = BleProvisioningPhase.error;
        error.value = e.toString();
        _append('Connect error: $e');
        if (!completer.isCompleted) completer.completeError(e);
      },
    );

    return completer.future;
  }

  Future<void> disconnect() async {
    await _connSub?.cancel();
    _connSub = null;

    final id = connectedDeviceId.value;
    if (id != null) {
      try {
        await _provisioner.disconnect(id);
      } catch (_) {}
    }

    connectedDeviceId.value = null;
    connectedDeviceName.value = null;
    totemId.value = null;
    totemName.value = null;
    currentWifiSsid.value = null;
    currentWifiPass.value = null;
    suggestedWifiSsid.value = null;
    suggestedWifiPass.value = null;
    if (phase.value != BleProvisioningPhase.scanning) {
      phase.value = BleProvisioningPhase.idle;
    }

    _append('BLE: disconnect() done');
  }

  Future<void> provision({
    required String ssid,
    required String pass,
  }) async {
    final id = connectedDeviceId.value;
    if (id == null) {
      Get.snackbar('BLE', 'Not connected to a device');
      return;
    }

    phase.value = BleProvisioningPhase.provisioning;
    error.value = '';
    _append('Provisioning Wi‑Fi (ssid="${ssid.trim()}", passLen=${pass.length})...');

    try {
      await _provisioner.provisionWifi(deviceId: id, ssid: ssid, pass: pass);
      _append('Wi‑Fi credentials written over BLE.');
      if (phase.value == BleProvisioningPhase.provisioning) {
        phase.value = BleProvisioningPhase.connected;
      }
    } catch (e) {
      phase.value = BleProvisioningPhase.error;
      error.value = e.toString();
      _append('Provision error: $e');
    }
  }

  Future<void> connectToWifi({
    required String ssid,
    required String pass,
  }) async {
    if (wifiConnectInProgress.value) {
      _append('Wi‑Fi: connect already in progress; skipping');
      return;
    }

    wifiConnectInProgress.value = true;
    try {
      final ok = await _wifiConnector.connect(ssid: ssid, password: pass);
      _append('Wi‑Fi: connect result = $ok');
      if (ok) {
        Get.snackbar('Wi‑Fi', 'Connected to "$ssid"');
      } else {
        Get.snackbar('Wi‑Fi', 'Failed to connect to "$ssid"');
      }
    } catch (e) {
      _append('Wi‑Fi: connect error: $e');
      Get.snackbar('Wi‑Fi', 'Connect error: $e');
    } finally {
      wifiConnectInProgress.value = false;
    }
  }

  void clearLog() => log.clear();

  void _append(String line) {
    final stamped = '[${DateTime.now().toIso8601String()}] $line';
    log.add(stamped);
  }

  @override
  void onClose() {
    _scanSub?.cancel();
    _connSub?.cancel();
    super.onClose();
  }
}
