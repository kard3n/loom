import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          onPressed: () => Get.back(), // GetX Navigation
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
          ),
          _buildPrivacyTile(
            theme,
            title: 'App Lock',
            subtitle: 'Secure app with Biometrics/PIN',
            icon: Icons.fingerprint_rounded,
            color: cs.primary,
          ),
          const Divider(height: 32),
          _buildSectionHeader(theme, 'Data & Visibility'),
          _buildPrivacyTile(
            theme,
            title: 'Profile Visibility',
            subtitle: 'Choose who can see your profile',
            icon: Icons.visibility_off_outlined,
            color: cs.tertiary,
          ),
          _buildPrivacyTile(
            theme,
            title: 'Blocked Contacts',
            subtitle: 'Manage 12 restricted users',
            icon: Icons.person_off_outlined,
            color: cs.error,
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
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          // Action for the specific privacy setting
        },
      ),
    );
  }
}
