// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import the PostsController to call its new method
import 'package:loom_app/src/controllers/posts_controller.dart';
import 'package:loom_app/src/pages/ble_provisioning_page.dart';

// --- 1. Helper Class Definitions ---

/// Helper class to define Navigation Rail/Bottom Nav items
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

/// The Navigation item used in the main application structure
final settingsNavigationItem = _NavigationItem(
  label: 'Settings',
  icon: Icons.settings_rounded,
  page: const SettingsPage(),
  fabLabel: 'Search',
  fabIcon: Icons.search_rounded,
  onFabTap: () {}, // Trigger search focus
);

/// Reusable tile for main settings categories
class SettingsCategoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget destination;

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
          // Use a subtle border for better definition
          side: BorderSide(color: Theme.of(context).dividerColor.withAlpha((0.25 * 255).round())), 
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          leading: CircleAvatar(
            backgroundColor: accentColor.withAlpha((0.1 * 255).round()),
            child: Icon(icon, color: accentColor),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            // Using GetX for navigation
            Get.to(() => destination);
          },
        ),
      ),
    );
  }
}

// --- 2. Main Settings Screen ---

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Column(
      children: <Widget>[
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search settings...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        
        // Settings List
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
                accentColor: cs.primary,
                // Using the detailed GeneralSettingsPage
                destination: const GeneralSettingsPage(), 
              ),
              _buildCategoryHeader(theme, 'Privacy'),
              SettingsCategoryTile(
                title: 'Privacy & Security',
                subtitle: 'Account protection and data',
                icon: Icons.shield_outlined,
                accentColor: cs.secondary,
                // Using the detailed PrivacySettingsPage
                destination: const PrivacySettingsPage(),
              ),
              _buildCategoryHeader(theme, 'Debug'),
              SettingsCategoryTile(
                title: 'Developer Options',
                subtitle: 'Technical logs and debug tools',
                icon: Icons.bug_report_outlined,
                accentColor: cs.tertiary,
                // Using the detailed DebugSettingsPage
                destination: const DebugSettingsPage(), 
              ),
              SettingsCategoryTile(
                title: 'BLE Wi‑Fi Provisioning',
                subtitle: 'Prototype: send SSID/PSK over BLE',
                icon: Icons.bluetooth_rounded,
                accentColor: cs.tertiary,
                destination: const BleProvisioningPage(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Common Section Header Builder for the main list
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

// --- 3. Detailed Sub-Pages ---

// 3.1. General Settings Page
class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text('General Settings'),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSectionHeader(theme, 'Preferences'),
          _buildStaticTile(
            context,
            title: 'Language',
            subtitle: 'English (US)',
            icon: Icons.language_rounded,
            onTap: () => Get.snackbar('Action', 'Language Selector Opened', snackPosition: SnackPosition.BOTTOM),
          ),
          _buildStaticTile(
            context,
            title: 'Notifications',
            subtitle: 'Sounds and Haptics',
            icon: Icons.notifications_active_outlined,
            onTap: () => Get.snackbar('Action', 'Notifications Page Opened', snackPosition: SnackPosition.BOTTOM),
          ),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Storage'),
          _buildStaticTile(
            context,
            title: 'Clear Cache',
            subtitle: 'Used: 124 MB',
            icon: Icons.delete_sweep_outlined,
            onTap: () => Get.snackbar('Action', 'Cache Cleared!', snackPosition: SnackPosition.BOTTOM),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 12),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildStaticTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap, // Added onTap
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // FIX: Replaced withValues() with withOpacity()
        side: BorderSide(color: theme.dividerColor.withAlpha((0.1 * 255).round())), 
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

// 3.2. Privacy Settings Page
class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(), 
        ),
        title: const Text('Privacy & Security'),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSectionHeader(theme, 'Account Security'),
          _buildPrivacyTile(
            theme,
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security',
            icon: Icons.enhanced_encryption_rounded,
            color: cs.secondary,
            onTap: () => Get.snackbar('Action', '2FA Setup Page Opened', snackPosition: SnackPosition.BOTTOM),
          ),
          _buildPrivacyTile(
            theme,
            title: 'App Lock',
            subtitle: 'Secure app with Biometrics/PIN',
            icon: Icons.fingerprint_rounded,
            color: cs.primary,
            onTap: () => Get.snackbar('Action', 'App Lock Settings Opened', snackPosition: SnackPosition.BOTTOM),
          ),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Data & Visibility'),
          _buildPrivacyTile(
            theme,
            title: 'Profile Visibility',
            subtitle: 'Choose who can see your profile',
            icon: Icons.visibility_off_outlined,
            color: cs.tertiary,
            onTap: () => Get.snackbar('Action', 'Profile Visibility Options Opened', snackPosition: SnackPosition.BOTTOM),
          ),
          _buildPrivacyTile(
            theme,
            title: 'Blocked Contacts',
            subtitle: 'Manage 12 restricted users',
            icon: Icons.person_off_outlined,
            color: cs.error,
            onTap: () => Get.snackbar('Action', 'Blocked Contacts List Opened', snackPosition: SnackPosition.BOTTOM),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 12),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildPrivacyTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap, // Added onTap
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // FIX: Replaced withValues() with withOpacity()
        side: BorderSide(color: theme.dividerColor.withAlpha((0.1 * 255).round())),
      ),
      child: ListTile(
        leading: CircleAvatar(
          // FIX: Replaced withValues() with withOpacity()
          backgroundColor: color.withAlpha((0.1 * 255).round()),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}


// 3.3. Detailed Debug Settings Page (Including functionality stubs)
class DebugSettingsPage extends StatelessWidget {
  const DebugSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text('Developer Options'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSectionHeader(theme, 'Diagnostics'),
          _buildDebugTile(
            theme,
            title: 'View System Logs',
            subtitle: 'Real-time application runtime data',
            icon: Icons.terminal_rounded,
            color: cs.tertiary,
            onTap: () => Get.snackbar('Log Viewer', 'Opening log viewer page...', snackPosition: SnackPosition.BOTTOM),
          ),
          _buildDebugTile(
            theme,
            title: 'Network Inspector',
            subtitle: 'Monitor API requests and responses',
            icon: Icons.data_usage_rounded,
            color: cs.secondary,
            onTap: () => Get.snackbar('Network Inspector', 'Launching network monitor...', snackPosition: SnackPosition.BOTTOM),
          ),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Experimental Features'),
          _buildDebugTile(
            theme,
            title: 'Strict Mode',
            subtitle: 'Flash screen on main thread disk IO',
            icon: Icons.flash_on_rounded,
            color: cs.error,
            onTap: () => Get.snackbar('Strict Mode', 'Strict Mode Toggled!', snackPosition: SnackPosition.BOTTOM),
          ),
          _buildDebugTile(
            theme,
            title: 'UI Inspector',
            subtitle: 'Show widget bounding boxes',
            icon: Icons.layers_outlined,
            color: cs.primary,
            onTap: () => Get.snackbar('UI Inspector', 'Showing bounds overlays.', snackPosition: SnackPosition.BOTTOM),
          ),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Maintenance'),
          _buildDebugTile(
            theme,
            title: 'Reset Database',
            subtitle: 'Wipe all local SQL storage',
            icon: Icons.delete_forever_rounded,
            color: cs.error,
            onTap: () {
              // Confirmation Dialog for destructive action
              Get.dialog(
                AlertDialog(
                  title: const Text('Confirm Reset'),
                  content: const Text('Are you sure you want to permanently delete all local data? This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
                    TextButton(
                      onPressed: () {
                        // DB Reset Logic would go here
                        Get.back(); // Close dialog
                        Get.snackbar('Database Reset', 'Local database has been wiped.', snackPosition: SnackPosition.BOTTOM);
                      },
                      child: Text('RESET', style: TextStyle(color: cs.error)),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildDebugTile(
            theme,
            title: 'Add Fake Friend',
            subtitle: 'Insert a mock contact for testing',
            icon: Icons.person_add_rounded,
            color: cs.primary,
            onTap: () async {
               // FIX: Implement logic to add a fake friend
              try {
                final postsController = Get.find<PostsController>();
                await postsController.addFakeFriend();
              } catch (e) {
                // Inform user if the PostsController isn't initialized
                Get.snackbar(
                  "Error", 
                  "PostsController not found or initialized. Ensure it's active.",
                  snackPosition: SnackPosition.BOTTOM,
                );
                debugPrint('Error finding PostsController: $e');
            }
            }, ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 12),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildDebugTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap, // Added onTap for interactivity
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // FIX: Replaced withValues() with withOpacity()
        side: BorderSide(color: theme.dividerColor.withAlpha((0.1 * 255).round())), 
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // FIX: Replaced withValues() with withOpacity()
            color: color.withAlpha((0.1 * 255).round()), 
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.code_rounded, size: 18),
        onTap: onTap,
      ),
    );
  }
}