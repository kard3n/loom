import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- Main Settings Entry (Subprogram Definition) ---
// This is the item you would use in your Navigation Rail or Bottom Nav
final settingsNavigationItem = _NavigationItem(
  label: 'Settings',
  icon: Icons.settings_rounded,
  page: const SettingsPage(),
  fabLabel: 'Search',
  fabIcon: Icons.search_rounded,
  onFabTap: () {}, // Trigger search focus
);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
          child: TextField(
            onChanged: (String value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search settings...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),

        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            children: [
              _buildCategoryHeader(theme, 'General'),
              SettingsCategoryTile(
                title: 'General Settings',
                subtitle: 'App preferences and notifications',
                icon: Icons.tune_rounded,
                accentColor: Colors.blue,
                destination: GeneralSettingsPage(),
              ),
              _buildCategoryHeader(theme, 'Privacy'),
              SettingsCategoryTile(
                title: 'Privacy & Security',
                subtitle: 'Account protection and data',
                icon: Icons.shield_outlined,
                accentColor: Colors.green,
                destination: PrivacySettingsPage(),
              ),
              _buildCategoryHeader(theme, 'Debug'),
              SettingsCategoryTile(
                title: 'Developer Options',
                subtitle: 'Technical logs and debug tools',
                icon: Icons.bug_report_outlined,
                accentColor: Colors.orange,
                destination: DebugSettingsPage(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// --- Sub-Pages (The Subprograms) ---

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General Settings')),
      body: const Center(child: Text('General Settings Content Placeholder')),
    );
  }
}

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: const Center(child: Text('Privacy Settings Content Placeholder')),
    );
  }
}

class DebugSettingsPage extends StatelessWidget {
  const DebugSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer Options')),
      body: const Center(child: Text('Debug Tools Content Placeholder')),
    );
  }
}

// --- Updated Reusable Category Widget ---

class SettingsCategoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget destination; // Added destination

  const SettingsCategoryTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Theme.of(context).dividerColor.withAlpha(25)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          leading: CircleAvatar(
            backgroundColor: accentColor.withAlpha(30),
            child: Icon(icon, color: accentColor),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
        ),
      ),
    );
  }
}

// Helper Class Definition
class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.page,
    required this.fabLabel,
    required this.fabIcon,
    required this.onFabTap,
  });

  final String label;
  final IconData icon;
  final Widget page;
  final String fabLabel;
  final IconData fabIcon;
  final VoidCallback onFabTap;
}
