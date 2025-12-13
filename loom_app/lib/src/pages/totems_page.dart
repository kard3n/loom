import 'package:flutter/material.dart';

class TotemsPage extends StatelessWidget {
  const TotemsPage({super.key});

  static const List<_Totem> _totems = <_Totem>[
    _Totem(
      name: 'Aurora Grove',
      mantra: 'Slow craft over noise.',
      keepers: <String>['Ava Chen', 'Miles Carter'],
      rituals: <String>['Sunrise sketching', 'Asynchronous critiques'],
      membersOnline: 18,
      membersTotal: 42,
      accent: Color(0xFF0FBF9F),
    ),
    _Totem(
      name: 'Signal Bloom',
      mantra: 'Ship generous ideas.',
      keepers: <String>['Sasha Park'],
      rituals: <String>['Weekly zine', 'Rapid-fire AMA'],
      membersOnline: 52,
      membersTotal: 108,
      accent: Color(0xFF65D6CE),
    ),
    _Totem(
      name: 'North Node',
      mantra: 'Measure what matters.',
      keepers: <String>['Diego Luna', 'Lina Patel'],
      rituals: <String>['Pulse review', 'Retro mural'],
      membersOnline: 9,
      membersTotal: 27,
      accent: Color(0xFF2E9684),
    ),
    _Totem(
      name: 'Founders Fire',
      mantra: 'Set intent, then leap.',
      keepers: <String>['Kai Root'],
      rituals: <String>['Capital circle', 'Hiring huddles'],
      membersOnline: 6,
      membersTotal: 15,
      accent: Color(0xFF46C6A8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    final ThemeData sectionTheme = base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0FBF9F),
        brightness: base.brightness,
      ),
      scaffoldBackgroundColor: const Color(0xFFF1FBF7),
      cardTheme: base.cardTheme.copyWith(color: Colors.white),
    );

    return Theme(
      data: sectionTheme,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFE6FFF5), Color(0xFFF9FFFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
          itemCount: _totems.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Totems',
                      style: sectionTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Anchor your crews around living rituals and signals.',
                      style: sectionTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            final _Totem totem = _totems[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: <Color>[totem.accent, totem.accent.withOpacity(0.6)],
                              ),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  totem.name,
                                  style: sectionTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(totem.mantra, style: sectionTheme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('Enter space'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: totem.rituals
                            .map((String ritual) => Chip(
                                  label: Text(ritual),
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _TotemMeta(
                            label: 'Keepers',
                            value: totem.keepers.join(', '),
                          ),
                          _TotemMeta(
                            label: 'Pulse',
                            value: '${totem.membersOnline} online / ${totem.membersTotal}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TotemMeta extends StatelessWidget {
  const _TotemMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Totem {
  const _Totem({
    required this.name,
    required this.mantra,
    required this.keepers,
    required this.rituals,
    required this.membersOnline,
    required this.membersTotal,
    required this.accent,
  });

  final String name;
  final String mantra;
  final List<String> keepers;
  final List<String> rituals;
  final int membersOnline;
  final int membersTotal;
  final Color accent;
}
