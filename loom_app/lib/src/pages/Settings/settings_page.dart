import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ThemeData base = Theme.of(context);
      final ThemeData sectionTheme = base.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: controller.seedColor.value,
          brightness: base.brightness,
        ),
        scaffoldBackgroundColor: controller.scaffoldBackgroundColor.value,
      );

      return Theme(
        data: sectionTheme,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
          children: <Widget>[
            Text(
              controller.title.value,
              style: sectionTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              controller.subtitle.value,
              style: sectionTheme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _SettingsCard(
              title: controller.notificationsTitle.value,
              children: <Widget>[
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: controller.pushEnabled.value,
                  title: Text(controller.pushAlertsTitle.value),
                  subtitle: Text(controller.pushAlertsSubtitle.value),
                  onChanged: controller.setPushEnabled,
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: controller.weeklyDigest.value,
                  title: Text(controller.weeklyDigestTitle.value),
                  subtitle: Text(controller.weeklyDigestSubtitle.value),
                  onChanged: controller.setWeeklyDigest,
                ),
              ],
            ),
            _SettingsCard(
              title: controller.focusWindowsTitle.value,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(controller.focusHoursTitle.value),
                  subtitle: Text(controller.focusHoursSubtitle()),
                ),
                Slider(
                  min: 1,
                  max: 4,
                  divisions: 6,
                  value: controller.focusHours.value,
                  label: '${controller.focusHours.value.toStringAsFixed(1)} hrs',
                  onChanged: controller.setFocusHours,
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: controller.darkHeaders.value,
                  title: Text(controller.dimHeadersTitle.value),
                  subtitle: Text(controller.dimHeadersSubtitle.value),
                  onChanged: controller.setDarkHeaders,
                ),
              ],
            ),
            _SettingsCard(
              title: controller.themePresetTitle.value,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: controller.selectedTheme.value.isEmpty ? null : controller.selectedTheme.value,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: controller.themePresets
                      .map(
                        (ThemePreset preset) => DropdownMenuItem<String>(
                          value: preset.value,
                          child: Text(preset.label),
                        ),
                      )
                      .toList(),
                  onChanged: controller.setTheme,
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.palette_rounded),
                  label: Text(controller.previewThemeLabel.value),
                ),
              ],
            ),
            _SettingsCard(
              title: controller.accountTitle.value,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(controller.connectedEmailTitle.value),
                  subtitle: Text(controller.connectedEmailValue.value),
                  trailing: TextButton(onPressed: () {}, child: Text(controller.changeLabel.value)),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(controller.billingPlanTitle.value),
                  subtitle: Text(controller.billingPlanValue.value),
                  trailing: OutlinedButton(onPressed: () {}, child: Text(controller.manageLabel.value)),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
