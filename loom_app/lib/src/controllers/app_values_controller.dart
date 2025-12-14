import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppValuesController extends GetxController {
  final RxString appTitle = ''.obs;

  // Home navigation
  final RxString navHomeLabel = ''.obs;
  final RxString navTotemsLabel = ''.obs;
  final RxString navFriendsLabel = ''.obs;
  final RxString navSavedLabel = ''.obs;
  final RxString navSettingsLabel = ''.obs;

  final RxString fabComposeLabel = ''.obs;
  final RxString fabNewTotemLabel = ''.obs;
  final RxString fabInviteLabel = ''.obs;

  // Compose
  final RxString composeTitle = ''.obs;
  final RxString composePostLabel = ''.obs;
  final RxString composeTitleHint = ''.obs;
  final RxString composeBodyHint = ''.obs;
  final RxString composeCharCounter = ''.obs;
  final RxString composeAddImageTooltip = ''.obs;
  final RxString composeAddTagsTooltip = ''.obs;

  // New Totem
  final RxString newTotemTitle = ''.obs;
  final RxString newTotemSaveLabel = ''.obs;
  final RxString newTotemNameLabel = ''.obs;
  final RxString newTotemNameHint = ''.obs;
  final RxString newTotemDescriptionLabel = ''.obs;
  final RxString newTotemDescriptionHint = ''.obs;
  final RxString newTotemTypeLabel = ''.obs;
  final RxString newTotemTypeHint = ''.obs;
  final RxList<String> newTotemTypeOptions = <String>[].obs;

  // Invite friends
  final RxString inviteFriendsTitle = ''.obs;
  final RxString inviteFriendsHeroTitle = ''.obs;
  final RxString inviteFriendsHeroSubtitle = ''.obs;
  final RxString inviteLink = ''.obs;
  final RxString inviteCopyTooltip = ''.obs;
  final RxString inviteCopiedSnackbar = ''.obs;
  final RxString inviteShareViaLabel = ''.obs;
  final RxString inviteShareEmail = ''.obs;
  final RxString inviteShareSms = ''.obs;
  final RxString inviteShareOther = ''.obs;

  // App theme
  final Rx<Color> seedColor = const Color(0xFF3F51B5).obs; // indigo
  final Rx<Color> appScaffoldBackground = const Color(0xFFF5F7FB).obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final values = await fetchAppValues();

    appTitle.value = values.appTitle;

    navHomeLabel.value = values.navHomeLabel;
    navTotemsLabel.value = values.navTotemsLabel;
    navFriendsLabel.value = values.navFriendsLabel;
    navSavedLabel.value = values.navSavedLabel;
    navSettingsLabel.value = values.navSettingsLabel;

    fabComposeLabel.value = values.fabComposeLabel;
    fabNewTotemLabel.value = values.fabNewTotemLabel;
    fabInviteLabel.value = values.fabInviteLabel;

    composeTitle.value = values.composeTitle;
    composePostLabel.value = values.composePostLabel;
    composeTitleHint.value = values.composeTitleHint;
    composeBodyHint.value = values.composeBodyHint;
    composeCharCounter.value = values.composeCharCounter;
    composeAddImageTooltip.value = values.composeAddImageTooltip;
    composeAddTagsTooltip.value = values.composeAddTagsTooltip;

    newTotemTitle.value = values.newTotemTitle;
    newTotemSaveLabel.value = values.newTotemSaveLabel;
    newTotemNameLabel.value = values.newTotemNameLabel;
    newTotemNameHint.value = values.newTotemNameHint;
    newTotemDescriptionLabel.value = values.newTotemDescriptionLabel;
    newTotemDescriptionHint.value = values.newTotemDescriptionHint;
    newTotemTypeLabel.value = values.newTotemTypeLabel;
    newTotemTypeHint.value = values.newTotemTypeHint;
    newTotemTypeOptions.assignAll(values.newTotemTypeOptions);

    inviteFriendsTitle.value = values.inviteFriendsTitle;
    inviteFriendsHeroTitle.value = values.inviteFriendsHeroTitle;
    inviteFriendsHeroSubtitle.value = values.inviteFriendsHeroSubtitle;
    inviteLink.value = values.inviteLink;
    inviteCopyTooltip.value = values.inviteCopyTooltip;
    inviteCopiedSnackbar.value = values.inviteCopiedSnackbar;
    inviteShareViaLabel.value = values.inviteShareViaLabel;
    inviteShareEmail.value = values.inviteShareEmail;
    inviteShareSms.value = values.inviteShareSms;
    inviteShareOther.value = values.inviteShareOther;

    seedColor.value = values.seedColor;
    appScaffoldBackground.value = values.appScaffoldBackground;
  }

  Future<AppValuesData> fetchAppValues() async {
    return const AppValuesData(
      appTitle: 'Loom Social',
      navHomeLabel: 'Home',
      navTotemsLabel: 'Totems',
      navFriendsLabel: 'Friends',
      navSavedLabel: 'Saved',
      navSettingsLabel: 'Settings',
      fabComposeLabel: 'Compose',
      fabNewTotemLabel: 'New totem',
      fabInviteLabel: 'Invite',
      composeTitle: 'Neuen Beitrag verfassen',
      composePostLabel: 'Posten',
      composeTitleHint: 'Titel (optional)',
      composeBodyHint: 'Was möchten Sie posten?',
      composeCharCounter: '0/280',
      composeAddImageTooltip: 'Bild hinzufügen',
      composeAddTagsTooltip: 'Tags hinzufügen',
      newTotemTitle: 'Neues Totem erstellen',
      newTotemSaveLabel: 'Speichern',
      newTotemNameLabel: 'Name',
      newTotemNameHint: 'Gib deinem Totem einen Namen...',
      newTotemDescriptionLabel: 'Beschreibung',
      newTotemDescriptionHint: 'Beschreibe die Bedeutung deines Totems...',
      newTotemTypeLabel: 'Totem-Typ',
      newTotemTypeHint: 'Wähle einen Typ',
      newTotemTypeOptions: <String>['Erfolg', 'Erinnerung', 'Ziel'],
      inviteFriendsTitle: 'Freunde einladen',
      inviteFriendsHeroTitle: 'Teile den Spaß!',
      inviteFriendsHeroSubtitle: 'Lade deine Freunde ein, um Belohnungen freizuschalten oder gemeinsam Inhalte zu erstellen.',
      inviteLink: 'https://ihre-app.com/invite/XYZ123',
      inviteCopyTooltip: 'Link kopieren',
      inviteCopiedSnackbar: 'Link kopiert!',
      inviteShareViaLabel: 'Oder teile über:',
      inviteShareEmail: 'E-Mail',
      inviteShareSms: 'SMS',
      inviteShareOther: 'Andere',
      seedColor: Color(0xFF3F51B5),
      appScaffoldBackground: Color(0xFFF5F7FB),
    );
  }
}

class AppValuesData {
  const AppValuesData({
    required this.appTitle,
    required this.navHomeLabel,
    required this.navTotemsLabel,
    required this.navFriendsLabel,
    required this.navSavedLabel,
    required this.navSettingsLabel,
    required this.fabComposeLabel,
    required this.fabNewTotemLabel,
    required this.fabInviteLabel,
    required this.composeTitle,
    required this.composePostLabel,
    required this.composeTitleHint,
    required this.composeBodyHint,
    required this.composeCharCounter,
    required this.composeAddImageTooltip,
    required this.composeAddTagsTooltip,
    required this.newTotemTitle,
    required this.newTotemSaveLabel,
    required this.newTotemNameLabel,
    required this.newTotemNameHint,
    required this.newTotemDescriptionLabel,
    required this.newTotemDescriptionHint,
    required this.newTotemTypeLabel,
    required this.newTotemTypeHint,
    required this.newTotemTypeOptions,
    required this.inviteFriendsTitle,
    required this.inviteFriendsHeroTitle,
    required this.inviteFriendsHeroSubtitle,
    required this.inviteLink,
    required this.inviteCopyTooltip,
    required this.inviteCopiedSnackbar,
    required this.inviteShareViaLabel,
    required this.inviteShareEmail,
    required this.inviteShareSms,
    required this.inviteShareOther,
    required this.seedColor,
    required this.appScaffoldBackground,
  });

  final String appTitle;
  final String navHomeLabel;
  final String navTotemsLabel;
  final String navFriendsLabel;
  final String navSavedLabel;
  final String navSettingsLabel;

  final String fabComposeLabel;
  final String fabNewTotemLabel;
  final String fabInviteLabel;

  final String composeTitle;
  final String composePostLabel;
  final String composeTitleHint;
  final String composeBodyHint;
  final String composeCharCounter;
  final String composeAddImageTooltip;
  final String composeAddTagsTooltip;

  final String newTotemTitle;
  final String newTotemSaveLabel;
  final String newTotemNameLabel;
  final String newTotemNameHint;
  final String newTotemDescriptionLabel;
  final String newTotemDescriptionHint;
  final String newTotemTypeLabel;
  final String newTotemTypeHint;
  final List<String> newTotemTypeOptions;

  final String inviteFriendsTitle;
  final String inviteFriendsHeroTitle;
  final String inviteFriendsHeroSubtitle;
  final String inviteLink;
  final String inviteCopyTooltip;
  final String inviteCopiedSnackbar;
  final String inviteShareViaLabel;
  final String inviteShareEmail;
  final String inviteShareSms;
  final String inviteShareOther;

  final Color seedColor;
  final Color appScaffoldBackground;
}
