import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushEnabled = true;
  bool _weeklyDigest = true;
  bool _darkHeaders = false;
  double _focusHours = 2;
  String _selectedTheme = 'Aurora';

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    final ThemeData sectionTheme = base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1F2D3D),
        brightness: base.brightness,
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F6FB),
    );

    return Theme(
      data: sectionTheme,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
        children: <Widget>[
          Text(
            'Settings',
            style: sectionTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Tune your notifications, focus windows, and vibe presets.',
            style: sectionTheme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _SettingsCard(
            title: 'Notifications',
            children: <Widget>[
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _pushEnabled,
                title: const Text('Push alerts'),
                subtitle: const Text('Trending totems, mentions, invites'),
                onChanged: (bool value) => setState(() => _pushEnabled = value),
              ),
              const Divider(),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _weeklyDigest,
                title: const Text('Weekly digest'),
                subtitle: const Text('Sent Mondays 9am local time'),
                onChanged: (bool value) => setState(() => _weeklyDigest = value),
              ),
            ],
          ),
          _SettingsCard(
            title: 'Focus windows',
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Focus hours'),
                subtitle: Text('${_focusHours.toStringAsFixed(1)} hrs protected each day'),
              ),
              Slider(
                min: 1,
                max: 4,
                divisions: 6,
                value: _focusHours,
                label: '${_focusHours.toStringAsFixed(1)} hrs',
                onChanged: (double value) => setState(() => _focusHours = value),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _darkHeaders,
                title: const Text('Dim noisy headers'),
                subtitle: const Text('Mute banner colors during focus spans'),
                onChanged: (bool value) => setState(() => _darkHeaders = value),
              ),
            ],
          ),
          _SettingsCard(
            title: 'Theme preset',
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedTheme,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'Aurora', child: Text('Aurora (teal + mint)')),
                  DropdownMenuItem(value: 'Sunset', child: Text('Sunset (peach + coral)')),
                  DropdownMenuItem(value: 'Noir', child: Text('Noir (charcoal + lilac)')),
                ],
                onChanged: (String? value) => setState(() => _selectedTheme = value ?? _selectedTheme),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.palette_rounded),
                label: const Text('Preview theme'),
              ),
            ],
          ),
          _SettingsCard(
            title: 'Account',
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Connected email'),
                subtitle: const Text('you@loom.space'),
                trailing: TextButton(onPressed: () {}, child: const Text('Change')),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Billing plan'),
                subtitle: const Text('Creator Crew — annual'),
                trailing: OutlinedButton(onPressed: () {}, child: const Text('Manage')), 
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
