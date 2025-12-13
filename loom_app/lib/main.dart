import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/app_values_controller.dart';
import 'package:loom_app/src/controllers/main_controller.dart';
import 'package:loom_app/src/pages/friends_page.dart';
import 'package:loom_app/src/pages/feed_page.dart';
import 'package:loom_app/src/pages/saved_page.dart';
import 'package:loom_app/src/pages/Settings/settings_page.dart';
import 'package:loom_app/src/pages/totems_page.dart';
import 'package:loom_app/src/bindings/app_bindings.dart';
import 'package:loom_app/src/rust/frb_generated.dart';
import 'package:flutter/services.dart';

// ------------------- MAIN -------------------
import 'package:loom_app/src/rust/api/simple.dart';

Future<void> main() async {
  // Stellen Sie sicher, dass Flutter gebunden ist, bevor RustLib initialisiert wird
  WidgetsFlutterBinding.ensureInitialized();
  //String result = await greet(name: "Test name");
  await RustLib.init();

  Get.put(AppValuesController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends GetView<AppValuesController> {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: controller.appTitle.value,
        debugShowCheckedModeBanner: false,
        initialBinding: AppBindings(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: controller.seedColor.value),
          scaffoldBackgroundColor: controller.appScaffoldBackground.value,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends GetView<MainController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _HomeScreenBody(controller: controller);
  }
}

// creates a window when Compose is clicked
class Compose extends StatelessWidget {
  const Compose({super.key});

  @override
  Widget build(BuildContext context) {
    // Holen Sie sich das aktuelle Theme für konsistentes Styling
    final theme = Theme.of(context);
    final values = Get.find<AppValuesController>();

    return Obx(() => Scaffold(
      // 1. Elegante App Bar: Kein Schatten und eine klare Schaltfläche zum Schließen
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, // Hintergrundfarbe des Scaffolds
        elevation: 0, // Entfernt den Schatten unter der AppBar
        title: Text(
          values.composeTitle.value,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Logik zum Veröffentlichen des Beitrags
              },
              // 2. Styled "Posten"-Button
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Obx(
                () => Text(
                  values.composePostLabel.value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 3. Titel-/Betreff-Eingabefeld
            Obx(
              () => TextField(
                decoration: InputDecoration(
                  hintText: values.composeTitleHint.value,
                  border: InputBorder.none, // Kein Rahmen
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(height: 30),

            // 4. Haupt-Textbereich
            Obx(
              () => TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null, // Ermöglicht beliebig viele Zeilen
                decoration: InputDecoration(
                  hintText: values.composeBodyHint.value,
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 30),

            // 5. Zusätzliche Aktionen (Bilder, Tags etc.)
            Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  tooltip: values.composeAddImageTooltip.value,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.tag),
                  tooltip: values.composeAddTagsTooltip.value,
                  onPressed: () {},
                ),
                const Spacer(), // Schiebt das folgende Element nach rechts
                // Optional: Zeichenzähler oder Statusanzeige
                Obx(() => Text(values.composeCharCounter.value, style: theme.textTheme.bodySmall)),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

// creates a window when new totem is clicked
class NewTotem extends StatelessWidget {
  const NewTotem({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = Get.find<AppValuesController>();

    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text(
          values.newTotemTitle.value,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // Logik zum Speichern/Erstellen des Totems
            },
            child: Obx(
              () => Text(
                values.newTotemSaveLabel.value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Visuelle Repräsentation / Bild-Upload
            Center(
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.add_a_photo_outlined, size: 40, color: theme.colorScheme.primary),
                  onPressed: () {
                    // Logik zum Hochladen eines Bildes
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 2. Name / Titel des Totems
            Obx(() => Text(values.newTotemNameLabel.value, style: theme.textTheme.titleMedium)),
            const SizedBox(height: 8),
            Obx(
              () => TextField(
                decoration: InputDecoration(
                  hintText: values.newTotemNameHint.value,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Beschreibung
            Obx(() => Text(values.newTotemDescriptionLabel.value, style: theme.textTheme.titleMedium)),
            const SizedBox(height: 8),
            Obx(
              () => TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: values.newTotemDescriptionHint.value,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Kategorie/Typ-Auswahl (Beispiel für ein Dropdown)
            Obx(() => Text(values.newTotemTypeLabel.value, style: theme.textTheme.titleMedium)),
            Obx(
              () => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                hint: Text(values.newTotemTypeHint.value),
                items: values.newTotemTypeOptions
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  // Wert speichern
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

// creates a window when invite friends is clicked
class InviteFriends extends StatelessWidget {
  const InviteFriends({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = Get.find<AppValuesController>();

    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text(values.inviteFriendsTitle.value),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Große Aufforderung
            Obx(
              () => Text(
                values.inviteFriendsHeroTitle.value,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => Text(values.inviteFriendsHeroSubtitle.value, style: theme.textTheme.bodyLarge)),
            const SizedBox(height: 30),

            // 2. Einladungslink-Bereich
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => Text(
                        values.inviteLink.value,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: values.inviteCopyTooltip.value,
                    child: IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () {
                        // Logik zum Kopieren
                        Clipboard.setData(ClipboardData(text: values.inviteLink.value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(values.inviteCopiedSnackbar.value)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 3. Schaltflächen für verschiedene Freigaben
            Obx(() => Text(values.inviteShareViaLabel.value, style: theme.textTheme.titleMedium)),
            const SizedBox(height: 15),

            // Beispiel: Zeile mit Teilen-Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareButton(context, Icons.email_outlined, values.inviteShareEmail.value, () {}),
                _buildShareButton(context, Icons.sms_outlined, values.inviteShareSms.value, () {}),
                _buildShareButton(context, Icons.share_outlined, values.inviteShareOther.value, () {
                  // Logik für systemeigenes Teilen (z.B. share_plus package)
                }),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  // Hilfs-Widget für die Share-Buttons
  Widget _buildShareButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody({required this.controller});

  final MainController controller;

  void _openComposeWindow() {
    Get.to(() => const Compose());
  }

  void _openNewTotemWindow() {
    Get.to(() => const NewTotem());
  }

  void _openInviteFriendsWindow() {
    Get.to(() => const InviteFriends());
  }

  @override
  Widget build(BuildContext context) {
    final values = Get.find<AppValuesController>();
    return Obx(() {
      final List<_NavigationItem> items = <_NavigationItem>[
        _NavigationItem(
          label: values.navHomeLabel.value,
          icon: Icons.home_rounded,
          page: const FeedPage(),
          fabLabel: values.fabComposeLabel.value,
          fabIcon: Icons.edit_rounded,
          onFabTap: _openComposeWindow,
        ),
        _NavigationItem(
          label: values.navTotemsLabel.value,
          icon: Icons.auto_awesome_rounded,
          page: const TotemsPage(),
          fabLabel: values.fabNewTotemLabel.value,
          fabIcon: Icons.auto_fix_high_rounded,
          onFabTap: _openNewTotemWindow,
        ),
        _NavigationItem(
          label: values.navFriendsLabel.value,
          icon: Icons.groups_2_rounded,
          page: const FriendsPage(),
          fabLabel: values.fabInviteLabel.value,
          fabIcon: Icons.person_add_alt_1_rounded,
          onFabTap: _openInviteFriendsWindow,
        ),
        _NavigationItem(
          label: values.navSavedLabel.value,
          icon: Icons.bookmark_added_rounded,
          page: const SavedPage(),
        ),
        _NavigationItem(
          label: values.navSettingsLabel.value,
          icon: Icons.settings_rounded,
          page: const SettingsPage(),
        ),
      ];

      final selectedIndex = controller.selectedIndex.value;
      final activeItem = items[selectedIndex];
      return Scaffold(
        floatingActionButton: activeItem.fabIcon != null
            ? FloatingActionButton.extended(
                onPressed: activeItem.onFabTap,
                icon: Icon(activeItem.fabIcon),
                label: Text(activeItem.fabLabel!),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: controller.selectTab,
          type: BottomNavigationBarType.fixed,
          items: items
              .map(
                (_NavigationItem item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: items.map((_NavigationItem item) => item.page).toList(),
        ),
      );
    });
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.page,
    this.fabLabel,
    this.fabIcon,
    this.onFabTap,
  });

  final String label;
  final IconData icon;
  final Widget page;
  final String? fabLabel;
  final IconData? fabIcon;
  final VoidCallback? onFabTap;
}




