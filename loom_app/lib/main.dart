import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/pages/friends_page.dart';
import 'package:loom_app/src/pages/feed_page.dart';
import 'package:loom_app/src/pages/saved_page.dart';
import 'package:loom_app/src/pages/Settings/settings_page.dart';
import 'package:loom_app/src/pages/totems_page.dart';
import 'package:loom_app/src/rust/frb_generated.dart';
import 'package:flutter/services.dart';

// ------------------- MAIN -------------------
import 'package:loom_app/src/rust/api/simple.dart';

Future<void> main() async {
  // Stellen Sie sicher, dass Flutter gebunden ist, bevor RustLib initialisiert wird
  WidgetsFlutterBinding.ensureInitialized();
  //String result = await greet(name: "Test name");
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loom Social',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// creates a window when Compose is clicked
class Compose extends StatelessWidget {
  const Compose({super.key});

  @override
  Widget build(BuildContext context) {
    // Holen Sie sich das aktuelle Theme für konsistentes Styling
    final theme = Theme.of(context);

    return Scaffold(
      // 1. Elegante App Bar: Kein Schatten und eine klare Schaltfläche zum Schließen
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, // Hintergrundfarbe des Scaffolds
        elevation: 0, // Entfernt den Schatten unter der AppBar
        title: Text(
          'Neuen Beitrag verfassen',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Logik zum Schließen des Bildschirms, z.B. Navigator.pop(context);
            // In diesem Beispiel tun wir nichts, da es nur ein Template ist.
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
              child: const Text(
                'Posten',
                style: TextStyle(fontWeight: FontWeight.bold),
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
            const TextField(
              decoration: InputDecoration(
                hintText: 'Titel (optional)',
                border: InputBorder.none, // Kein Rahmen
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 30),

            // 4. Haupt-Textbereich
            const TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null, // Ermöglicht beliebig viele Zeilen
              decoration: InputDecoration(
                hintText: 'Was möchten Sie posten?',
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            // 5. Zusätzliche Aktionen (Bilder, Tags etc.)
            Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  tooltip: 'Bild hinzufügen',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.tag),
                  tooltip: 'Tags hinzufügen',
                  onPressed: () {},
                ),
                const Spacer(), // Schiebt das folgende Element nach rechts
                // Optional: Zeichenzähler oder Statusanzeige
                Text(
                  '0/280',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// creates a window when new totem is clicked

class NewTotem extends StatelessWidget {
  const NewTotem({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Neues Totem erstellen',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // Logik zum Speichern/Erstellen des Totems
            },
            child: const Text(
              'Speichern',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
            Text(
              'Name',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Gib deinem Totem einen Namen...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Beschreibung
            Text(
              'Beschreibung',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Beschreibe die Bedeutung deines Totems...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // 4. Kategorie/Typ-Auswahl (Beispiel für ein Dropdown)
            Text(
              'Totem-Typ',
              style: theme.textTheme.titleMedium,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              hint: const Text('Wähle einen Typ'),
              items: <String>['Erfolg', 'Erinnerung', 'Ziel']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Wert speichern
              },
            ),
          ],
        ),
      ),
    );
  }
}

// creates a window when invite friends is clicked

class InviteFriends extends StatelessWidget {
  const InviteFriends({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const inviteLink = "https://ihre-app.com/invite/XYZ123";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Freunde einladen'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Große Aufforderung
            Text(
              'Teile den Spaß!',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Lade deine Freunde ein, um Belohnungen freizuschalten oder gemeinsam Inhalte zu erstellen.',
              style: theme.textTheme.bodyLarge,
            ),
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
                    child: Text(
                      inviteLink,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: 'Link kopieren',
                    child: IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () {
                        // Logik zum Kopieren
                        Clipboard.setData(const ClipboardData(text: inviteLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link kopiert!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 3. Schaltflächen für verschiedene Freigaben
            Text(
              'Oder teile über:',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 15),

            // Beispiel: Zeile mit Teilen-Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareButton(context, Icons.email_outlined, 'E-Mail', () {}),
                _buildShareButton(context, Icons.sms_outlined, 'SMS', () {}),
                _buildShareButton(context, Icons.share_outlined, 'Andere', () {
                  // Logik für systemeigenes Teilen (z.B. share_plus package)
                }),
              ],
            ),
          ],
        ),
      ),
    );
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

class _HomeScreenState extends State<HomeScreen> {
  late final List<_NavigationItem> _items;
  int _selectedIndex = 0;

  void _openComposeWindow() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Compose()),
    );
  }

  void _openNewTotemWindow() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewTotem()),
    );
  }

  void _openInviteFriendsWindow() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InviteFriends()),
    );
  }

  @override
  void initState() {
    super.initState();
    _items = <_NavigationItem>[
      _NavigationItem(
        label: 'Home',
        icon: Icons.home_rounded,
        page: const FeedPage(),
        fabLabel: 'Compose',
        fabIcon: Icons.edit_rounded,
        onFabTap: () => _openComposeWindow(),
      ),
      _NavigationItem(
        label: 'Totems',
        icon: Icons.auto_awesome_rounded,
        page: const TotemsPage(),
        fabLabel: 'New totem',
        fabIcon: Icons.auto_fix_high_rounded,
        onFabTap: () => _openNewTotemWindow(),
      ),
      _NavigationItem(
        label: 'Friends',
        icon: Icons.groups_2_rounded,
        page: const FriendsPage(),
        fabLabel: 'Invite',
        fabIcon: Icons.person_add_alt_1_rounded,
        onFabTap: () => _openInviteFriendsWindow(),
      ),
      _NavigationItem(
        label: 'Saved',
        icon: Icons.bookmark_added_rounded,
        page: const SavedPage(),
      ),
      _NavigationItem(
        label: 'Settings',
        icon: Icons.settings_rounded,
        page: const SettingsPage(),
      ),
    ];
  }

  void _showAction(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final _NavigationItem activeItem = _items[_selectedIndex];
    return Scaffold(
      floatingActionButton: activeItem.fabIcon != null
          ? FloatingActionButton.extended(
              onPressed: activeItem.onFabTap,
              icon: Icon(activeItem.fabIcon),
              label: Text(activeItem.fabLabel!),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: _items
            .map(
              (_NavigationItem item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _items.map((_NavigationItem item) => item.page).toList(),
      ),
    );
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


