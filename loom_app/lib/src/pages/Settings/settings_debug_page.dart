import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/pages/Settings/P2P/nearby_service';

// Assuming nearby_service is a class/widget.
// If it's a function that returns a widget, keep it as nearby_service()
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
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          NearbyAndroidScreen(),
          // --- P2P Section ---
          _buildSectionHeader(theme, 'P2P'),
          _buildDebugTile(
            theme,
            title: 'Connect',
            subtitle: 'Connect with Others',
            icon: Icons.tune_rounded,
            color: cs.primary,
            onTap: () => Get.to(() => const GetMaterialApp()),
          ),

          const Divider(height: 32),

          // --- Diagnostics Section ---
          _buildSectionHeader(theme, 'Diagnostics'),
          _buildDebugTile(
            theme,
            title: 'View System Logs',
            subtitle: 'Real-time application runtime data',
            icon: Icons.terminal_rounded,
            color: cs.tertiary,
          ),
          _buildDebugTile(
            theme,
            title: 'Network Inspector',
            subtitle: 'Monitor API requests and responses',
            icon: Icons.data_usage_rounded,
            color: cs.secondary,
          ),

          const Divider(height: 32),

          // --- Maintenance Section ---
          _buildSectionHeader(theme, 'Maintenance'),
          _buildDebugTile(
            theme,
            title: 'Reset Database',
            subtitle: 'Wipe all local SQL storage',
            icon: Icons.delete_forever_rounded,
            color: cs.error,
          ),
        ],
      ),
    );
  }

  // Helper for Section Headers
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

  // Refactored Helper for Debug Tiles
  Widget _buildDebugTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded, size: 18),
        onTap: onTap ?? () {},
      ),
    );
  }
}
