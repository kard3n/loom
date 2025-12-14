import 'dart:async';
import 'dart:io';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

enum TotemProximityState {
  none,
  nearby,
  connected,
}

class TotemProximityController extends GetxController {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  final Rx<TotemProximityState> state = TotemProximityState.none.obs;

  StreamSubscription<DiscoveredDevice>? _scanSub;
  Timer? _connectivityCheckTimer;
  Timer? _deviceExpiryTimer;

  final Map<String, DateTime> _nearbyDevices = {};
  static const Duration _deviceExpiryDuration = Duration(seconds: 10);
  static const Duration _connectivityCheckInterval = Duration(seconds: 10);
  static const String _totemCheckUrl = 'http://192.168.71.1/is_totem';

  bool get isNearby => state.value == TotemProximityState.nearby;
  bool get isConnected => state.value == TotemProximityState.connected;

  @override
  void onInit() {
    super.onInit();
    _startMonitoring();
  }

  @override
  void onClose() {
    _stopMonitoring();
    super.onClose();
  }

  Future<void> _startMonitoring() async {
    await _startBleScan();
    _startConnectivityCheck();
    _startDeviceExpiryCheck();
  }

  void _stopMonitoring() {
    _scanSub?.cancel();
    _scanSub = null;
    _connectivityCheckTimer?.cancel();
    _connectivityCheckTimer = null;
    _deviceExpiryTimer?.cancel();
    _deviceExpiryTimer = null;
  }

  Future<bool> _ensurePermissions() async {
    if (!Platform.isAndroid) return true;

    final statuses = await [
      Permission.locationWhenInUse,
      Permission.bluetoothScan,
    ].request();

    return statuses.values.every((s) => s.isGranted);
  }

  Future<void> _startBleScan() async {
    final hasPermissions = await _ensurePermissions();
    if (!hasPermissions) return;

    _scanSub = _ble
        .scanForDevices(
          withServices: [],
          scanMode: ScanMode.lowPower,
        )
        .where((d) => _containsTotemMarker(d.manufacturerData))
        .listen(
          (device) {
            _nearbyDevices[device.id] = DateTime.now();
            _updateState();
          },
          onError: (_) {},
        );
  }

  bool _containsTotemMarker(List<int> data) {
    if (data.isEmpty) return false;
    final dataStr = String.fromCharCodes(data).toLowerCase();
    return dataStr.contains('totem');
  }

  void _startConnectivityCheck() {
    _checkConnectivity();
    _connectivityCheckTimer = Timer.periodic(
      _connectivityCheckInterval,
      (_) => _checkConnectivity(),
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse(_totemCheckUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        state.value = TotemProximityState.connected;
      } else {
        _updateStateBasedOnProximity();
      }
    } catch (_) {
      _updateStateBasedOnProximity();
    }
  }

  void _startDeviceExpiryCheck() {
    _deviceExpiryTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _expireOldDevices(),
    );
  }

  void _expireOldDevices() {
    final now = DateTime.now();
    _nearbyDevices.removeWhere(
      (_, lastSeen) => now.difference(lastSeen) > _deviceExpiryDuration,
    );
    _updateState();
  }

  void _updateState() {
    if (state.value == TotemProximityState.connected) return;
    _updateStateBasedOnProximity();
  }

  void _updateStateBasedOnProximity() {
    if (state.value == TotemProximityState.connected) {
      state.value = _nearbyDevices.isNotEmpty
          ? TotemProximityState.nearby
          : TotemProximityState.none;
    } else {
      state.value = _nearbyDevices.isNotEmpty
          ? TotemProximityState.nearby
          : TotemProximityState.none;
    }
  }
}
