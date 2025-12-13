import 'package:flutter/material.dart';

class TotemsPage extends StatefulWidget {
  const TotemsPage({super.key});

  @override
  State<TotemsPage> createState() => _TotemsPageState();
}

class _TotemsPageState extends State<TotemsPage> {
  List<_Totem> _totems = <_Totem>[
    const _Totem(name: "xy", description: "desc"),
    const _Totem(name: "ab", description: "hello"),
  ];
  final String _totemGreeting = "These are the available Totems:";
  
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: _TotemHeader(greeting: _totemGreeting, nof_totems: _totems.length),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index == _totems.length - 1 ? 80 : 16),
                  child: _TotemCard(totem: _totems[index]),
                );
              },
              childCount: _totems.length,
            ),
          )
        ),
      ]
    );
  }
}

// TODO expand Totem class
class _Totem {
  const _Totem({ required this.name, required this.description});

  final String name;
  final String description;
}
class _TotemHeader extends StatelessWidget{
  const _TotemHeader({required this.greeting, required this.nof_totems});
  final String greeting;
  final int nof_totems;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height:48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                ],
              ),
            ),
            child: const Center(
              child: Icon(Icons.signal_wifi_statusbar_4_bar, color: Colors.white),
            )
          ),
          const SizedBox(width: 12),
          Text("$greeting \n    (There are $nof_totems Totems available)"),
        ]
      ),
    );
  }
}
class _TotemCard extends StatelessWidget{
  const _TotemCard({required this.totem});
  final _Totem totem;


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget> [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Name: " + totem.name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  "Description: " + totem.name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Text(
              "Display Signal strength here",
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            ElevatedButton(
              onPressed: (){
                // TODO implement connection
              },
              child: Text("Connect"),
            ),
          ],
        ),
      )
    );
  }
}
