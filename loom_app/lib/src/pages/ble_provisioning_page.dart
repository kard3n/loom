import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/ble_provisioning_controller.dart';

class BleProvisioningPage extends StatefulWidget {
  const BleProvisioningPage({super.key});

  @override
  State<BleProvisioningPage> createState() => _BleProvisioningPageState();
}

class _BleProvisioningPageState extends State<BleProvisioningPage> {
  final BleProvisioningController controller = Get.find<BleProvisioningController>();

  final TextEditingController ssidCtrl = TextEditingController();
  final TextEditingController pskCtrl = TextEditingController();
  final TextEditingController prefixCtrl = TextEditingController(text: '');

  late final Worker _ssidWorker;
  late final Worker _passWorker;

  @override
  void initState() {
    super.initState();

    _ssidWorker = ever<String?>(controller.suggestedWifiSsid, (v) {
      final next = (v ?? '').trim();
      if (next.isEmpty) return;
      // Only fill blank fields; don't clobber user edits.
      if (ssidCtrl.text.trim().isEmpty) {
        ssidCtrl.text = next;
      }
    });

    _passWorker = ever<String?>(controller.suggestedWifiPass, (v) {
      final next = v ?? '';
      if (next.isEmpty) return;
      if (pskCtrl.text.isEmpty) {
        pskCtrl.text = next;
      }
    });
  }

  @override
  void dispose() {
    _ssidWorker.dispose();
    _passWorker.dispose();
    ssidCtrl.dispose();
    pskCtrl.dispose();
    prefixCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Wi-Fi Provisioning'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear log',
            onPressed: controller.clearLog,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: Obx(() {
        final phase = controller.phase.value;
        final deviceId = controller.connectedDeviceId.value;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: <Widget>[
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('Phase: $phase'),
                    if (deviceId != null) Text('Connected: ${controller.connectedDeviceName.value ?? deviceId}'),
                    if ((controller.totemName.value ?? '').isNotEmpty || (controller.totemId.value ?? '').isNotEmpty)
                      Text('Totem: ${controller.totemName.value ?? ''} (${controller.totemId.value ?? ''})'),
                    if ((controller.currentWifiSsid.value ?? '').isNotEmpty)
                      Text('Current SSID: ${controller.currentWifiSsid.value}'),
                    if (controller.error.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          controller.error.value,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        FilledButton.icon(
                          onPressed: phase == BleProvisioningPhase.scanning
                              ? controller.stopScan
                              : () => controller.startScan(namePrefix: prefixCtrl.text.trim()),
                          icon: Icon(phase == BleProvisioningPhase.scanning ? Icons.stop_rounded : Icons.search_rounded),
                          label: Text(phase == BleProvisioningPhase.scanning ? 'Stop scan' : 'Scan'),
                        ),
                        OutlinedButton.icon(
                          onPressed: deviceId == null ? null : controller.disconnect,
                          icon: const Icon(Icons.link_off_rounded),
                          label: const Text('Disconnect'),
                        ),
                        if (controller.wifiConnectInProgress.value)
                          const Padding(
                            padding: EdgeInsets.only(left: 4, top: 10),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: prefixCtrl,
              decoration: const InputDecoration(
                labelText: 'Optional device name prefix',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text('Devices', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...controller.devices.map(
              (d) => Card(
                elevation: 0,
                child: ListTile(
                  title: Text(d.name.isEmpty ? 'Unnamed' : d.name),
                  subtitle: Text('${d.id}\nRSSI: ${d.rssi}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => controller.connect(d),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Wi‑Fi credentials', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextField(
              controller: ssidCtrl,
              decoration: const InputDecoration(labelText: 'SSID', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pskCtrl,
              decoration: const InputDecoration(labelText: 'Password / PSK', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: deviceId == null
                  ? null
                  : () => controller.provision(
                        ssid: ssidCtrl.text.trim(),
                        pass: pskCtrl.text,
                      ),
              child: const Text('Send provisioning request'),
            ),
            const SizedBox(height: 16),
            Text('Log', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Obx(() {
                  final lines = controller.log;
                  if (lines.isEmpty) return const Text('No log lines yet.');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: lines
                        .take(80)
                        .map((l) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(l, style: theme.textTheme.bodySmall),
                            ))
                        .toList(growable: false),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}
