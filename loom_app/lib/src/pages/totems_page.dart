import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loom_app/src/controllers/totems_controller.dart';

IconData _signalIconFor(int strength) {
  final int s = strength.clamp(0, 4);
  switch (s) {
    case 0:
      return Icons.wifi_off;
    case 1:
      return Icons.network_wifi_1_bar_rounded;
    case 2:
      return Icons.network_wifi_2_bar_rounded;
    case 3:
      return Icons.network_wifi_3_bar_rounded;
    default:
      return Icons.network_wifi_rounded;
  }
}

class TotemsPage extends GetView<TotemsController> {
  const TotemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totems = controller.totems;
      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _TotemHeader(
              greeting: controller.greeting.value,
              nofTotems: totems.length,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index == totems.length - 1 ? 80 : 16),
                  child: _TotemCard(totem: totems[index]),
                );
              }, childCount: totems.length),
            ),
          ),
        ],
      );
    });
  }
}

class _TotemHeader extends StatelessWidget {
  const _TotemHeader({required this.greeting, required this.nofTotems});
  final String greeting;
  final int nofTotems;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
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
              child: Icon(
                Icons.signal_wifi_statusbar_4_bar,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$greeting\n(There are $nofTotems Totems available)',
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotemCard extends StatelessWidget {
  const _TotemCard({required this.totem});
  final TotemCard totem;

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
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isNarrow = constraints.maxWidth < 420;
            final Widget details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${Get.find<TotemsController>().nameLabel.value}: ${totem.name}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${Get.find<TotemsController>().descriptionLabel.value}: ${totem.description}',
                  style: theme.textTheme.bodyMedium,
                  softWrap: true,
                ),
              ],
            );

            final Widget connect = ElevatedButton.icon(
              onPressed: () {
                // TODO implement connection
              },
              icon: Icon(
                _signalIconFor(totem.signalStrength),
                size: 18,
                color: theme.colorScheme.primary,
              ),
              label: Text(Get.find<TotemsController>().connectLabel.value),
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  details,
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: connect),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: details),
                const SizedBox(width: 16),
                connect,
              ],
            );
          },
        ),
      ),
    );
  }
}
