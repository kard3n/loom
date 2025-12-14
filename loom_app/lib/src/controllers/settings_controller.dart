import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RxString title = ''.obs;
  final RxString subtitle = ''.obs;
  final Rx<Color> seedColor = const Color(0xFF1F2D3D).obs;
  final Rx<Color> scaffoldBackgroundColor = const Color(0xFFF4F6FB).obs;

  final RxBool pushEnabled = false.obs;
  final RxBool weeklyDigest = false.obs;
  final RxBool darkHeaders = false.obs;
  final RxDouble focusHours = 0.0.obs;
  final RxString selectedTheme = ''.obs;

  final RxString notificationsTitle = ''.obs;
  final RxString pushAlertsTitle = ''.obs;
  final RxString pushAlertsSubtitle = ''.obs;
  final RxString weeklyDigestTitle = ''.obs;
  final RxString weeklyDigestSubtitle = ''.obs;

  final RxString focusWindowsTitle = ''.obs;
  final RxString focusHoursTitle = ''.obs;
  final RxString focusHoursSubtitleTemplate = ''.obs;
  final RxString dimHeadersTitle = ''.obs;
  final RxString dimHeadersSubtitle = ''.obs;

  final RxString themePresetTitle = ''.obs;
  final RxList<ThemePreset> themePresets = <ThemePreset>[].obs;
  final RxString previewThemeLabel = ''.obs;

  final RxString accountTitle = ''.obs;
  final RxString connectedEmailTitle = ''.obs;
  final RxString connectedEmailValue = ''.obs;
  final RxString changeLabel = ''.obs;
  final RxString billingPlanTitle = ''.obs;
  final RxString billingPlanValue = ''.obs;
  final RxString manageLabel = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final data = await fetchSettingsData();

    title.value = data.title;
    subtitle.value = data.subtitle;
    seedColor.value = data.seedColor;
    scaffoldBackgroundColor.value = data.scaffoldBackgroundColor;

    pushEnabled.value = data.pushEnabled;
    weeklyDigest.value = data.weeklyDigest;
    darkHeaders.value = data.darkHeaders;
    focusHours.value = data.focusHours;
    selectedTheme.value = data.selectedTheme;

    notificationsTitle.value = data.notificationsTitle;
    pushAlertsTitle.value = data.pushAlertsTitle;
    pushAlertsSubtitle.value = data.pushAlertsSubtitle;
    weeklyDigestTitle.value = data.weeklyDigestTitle;
    weeklyDigestSubtitle.value = data.weeklyDigestSubtitle;

    focusWindowsTitle.value = data.focusWindowsTitle;
    focusHoursTitle.value = data.focusHoursTitle;
    focusHoursSubtitleTemplate.value = data.focusHoursSubtitleTemplate;
    dimHeadersTitle.value = data.dimHeadersTitle;
    dimHeadersSubtitle.value = data.dimHeadersSubtitle;

    themePresetTitle.value = data.themePresetTitle;
    themePresets.assignAll(data.themePresets);
    previewThemeLabel.value = data.previewThemeLabel;

    accountTitle.value = data.accountTitle;
    connectedEmailTitle.value = data.connectedEmailTitle;
    connectedEmailValue.value = data.connectedEmailValue;
    changeLabel.value = data.changeLabel;
    billingPlanTitle.value = data.billingPlanTitle;
    billingPlanValue.value = data.billingPlanValue;
    manageLabel.value = data.manageLabel;
  }

  void setPushEnabled(bool value) => pushEnabled.value = value;
  void setWeeklyDigest(bool value) => weeklyDigest.value = value;
  void setDarkHeaders(bool value) => darkHeaders.value = value;
  void setFocusHours(double value) => focusHours.value = value;
  void setTheme(String? value) {
    if (value == null) return;
    selectedTheme.value = value;
  }

  String focusHoursSubtitle() {
    return focusHoursSubtitleTemplate.value.replaceAll('{hours}', focusHours.value.toStringAsFixed(1));
  }

  Future<SettingsData> fetchSettingsData() async {
    return const SettingsData(
      title: 'Settings',
      subtitle: 'Tune your notifications, focus windows, and vibe presets.',
      seedColor: Color(0xFF1F2D3D),
      scaffoldBackgroundColor: Color(0xFFF4F6FB),
      pushEnabled: false,
      weeklyDigest: false,
      darkHeaders: false,
      focusHours: 0,
      selectedTheme: '',
      notificationsTitle: 'Notifications',
      pushAlertsTitle: 'Push alerts',
      pushAlertsSubtitle: 'Trending totems, mentions, invites',
      weeklyDigestTitle: 'Weekly digest',
      weeklyDigestSubtitle: 'Sent Mondays 9am local time',
      focusWindowsTitle: 'Focus windows',
      focusHoursTitle: 'Focus hours',
      focusHoursSubtitleTemplate: '{hours} hrs protected each day',
      dimHeadersTitle: 'Dim noisy headers',
      dimHeadersSubtitle: 'Mute banner colors during focus spans',
      themePresetTitle: 'Theme preset',
      themePresets: <ThemePreset>[
        ThemePreset(value: 'Aurora', label: 'Aurora (teal + mint)'),
        ThemePreset(value: 'Sunset', label: 'Sunset (peach + coral)'),
        ThemePreset(value: 'Noir', label: 'Noir (charcoal + lilac)'),
      ],
      previewThemeLabel: 'Preview theme',
      accountTitle: 'Account',
      connectedEmailTitle: 'Connected email',
      connectedEmailValue: '',
      changeLabel: 'Change',
      billingPlanTitle: 'Billing plan',
      billingPlanValue: '',
      manageLabel: 'Manage',
    );
  }
}

class ThemePreset {
  const ThemePreset({required this.value, required this.label});

  final String value;
  final String label;
}

class SettingsData {
  const SettingsData({
    required this.title,
    required this.subtitle,
    required this.seedColor,
    required this.scaffoldBackgroundColor,
    required this.pushEnabled,
    required this.weeklyDigest,
    required this.darkHeaders,
    required this.focusHours,
    required this.selectedTheme,
    required this.notificationsTitle,
    required this.pushAlertsTitle,
    required this.pushAlertsSubtitle,
    required this.weeklyDigestTitle,
    required this.weeklyDigestSubtitle,
    required this.focusWindowsTitle,
    required this.focusHoursTitle,
    required this.focusHoursSubtitleTemplate,
    required this.dimHeadersTitle,
    required this.dimHeadersSubtitle,
    required this.themePresetTitle,
    required this.themePresets,
    required this.previewThemeLabel,
    required this.accountTitle,
    required this.connectedEmailTitle,
    required this.connectedEmailValue,
    required this.changeLabel,
    required this.billingPlanTitle,
    required this.billingPlanValue,
    required this.manageLabel,
  });

  final String title;
  final String subtitle;
  final Color seedColor;
  final Color scaffoldBackgroundColor;

  final bool pushEnabled;
  final bool weeklyDigest;
  final bool darkHeaders;
  final double focusHours;
  final String selectedTheme;

  final String notificationsTitle;
  final String pushAlertsTitle;
  final String pushAlertsSubtitle;
  final String weeklyDigestTitle;
  final String weeklyDigestSubtitle;

  final String focusWindowsTitle;
  final String focusHoursTitle;
  final String focusHoursSubtitleTemplate;
  final String dimHeadersTitle;
  final String dimHeadersSubtitle;

  final String themePresetTitle;
  final List<ThemePreset> themePresets;
  final String previewThemeLabel;

  final String accountTitle;
  final String connectedEmailTitle;
  final String connectedEmailValue;
  final String changeLabel;
  final String billingPlanTitle;
  final String billingPlanValue;
  final String manageLabel;
}
