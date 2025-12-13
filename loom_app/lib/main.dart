import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/pages/friends_page.dart';
import 'package:loom_app/src/pages/feed_page.dart';
import 'package:loom_app/src/pages/saved_page.dart';
import 'package:loom_app/src/pages/Settings/settings_page.dart';
import 'package:loom_app/src/pages/totems_page.dart';
import 'package:loom_app/src/rust/frb_generated.dart';

Future<void> main() async {
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

class _HomeScreenState extends State<HomeScreen> {
  late final List<_NavigationItem> _items;
  int _selectedIndex = 0;

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
        onFabTap: () => _showAction('Start a new post'),
      ),
      _NavigationItem(
        label: 'Totems',
        icon: Icons.auto_awesome_rounded,
        page: const TotemsPage(),
        fabLabel: 'New totem',
        fabIcon: Icons.auto_fix_high_rounded,
        onFabTap: () => _showAction('Crafting a new totem'),
      ),
      _NavigationItem(
        label: 'Friends',
        icon: Icons.groups_2_rounded,
        page: const FriendsPage(),
        fabLabel: 'Invite',
        fabIcon: Icons.person_add_alt_1_rounded,
        onFabTap: () => _showAction('Sending invites to friends'),
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
