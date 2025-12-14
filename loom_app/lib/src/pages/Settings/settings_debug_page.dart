import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DebugSettingsPage extends StatelessWidget {
  const DebugSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            color: Colors.orange,
          ),
          _buildDebugTile(
            theme,
            title: 'Network Inspector',
            subtitle: 'Monitor API requests and responses',
            icon: Icons.data_usage_rounded,
            color: Colors.blue,
          ),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Experimental Features'),
          _buildDebugTile(
            theme,
            title: 'Strict Mode',
            subtitle: 'Flash screen on main thread disk IO',
            icon: Icons.flash_on_rounded,
            color: Colors.redAccent,
          ),
          _buildDebugTile(
            theme,
            title: 'UI Inspector',
            subtitle: 'Show widget bounding boxes',
            icon: Icons.layers_outlined,
            color: Colors.teal,
          ),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Maintenance'),
          _buildDebugTile(
            theme,
            title: 'Reset Database',
            subtitle: 'Wipe all local SQL storage',
            icon: Icons.delete_forever_rounded,
            color: Colors.grey,
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

  Widget _buildDebugTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.code_rounded, size: 18),
        onTap: () {
          // Action for the specific debug tool
        },
      ),
    );
  }
}
