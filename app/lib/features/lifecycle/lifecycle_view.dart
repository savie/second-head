import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/navigation/sh_navigation_shell.dart';

class LifecycleView extends StatelessWidget {
  const LifecycleView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShTopBar(
          title: 'Lifecycle',
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search, size: 19)),
            IconButton(onPressed: () {}, icon: Icon(Icons.fullscreen, size: 18)),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 26,
                      maxWidth: 520,
                    ),
                    child: const LifecycleMap(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LifecycleMap extends StatelessWidget {
  const LifecycleMap();

  @override
  Widget build(BuildContext context) {
    final stages = const [
      LifecycleStage(
        'Clone',
        'Duplicate your Second Head state',
        Icons.copy_all_rounded,
        Alignment.centerLeft,
      ),
      LifecycleStage(
        'Recovery',
        'Restore continuity when something changes',
        Icons.restore_rounded,
        Alignment.centerRight,
      ),
      LifecycleStage(
        'Inheritance',
        'Pass knowledge and identity forward',
        Icons.account_tree_rounded,
        Alignment.centerLeft,
      ),
      LifecycleStage(
        'Succession',
        'Continue the role beyond one instance',
        Icons.swap_horiz_rounded,
        Alignment.centerRight,
      ),
      LifecycleStage(
        'Legacy',
        'Preserve what should remain meaningful',
        Icons.auto_awesome_rounded,
        Alignment.centerLeft,
      ),
      LifecycleStage(
        'End of Life',
        'Close the lifecycle with dignity and control',
        Icons.trip_origin_rounded,
        Alignment.centerRight,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: shSurface.withOpacity(.62),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: shBorder),
        boxShadow: [
          BoxShadow(
            color: shPurple.withOpacity(.08),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 400;
          return Stack(
            children: [
              Positioned(
                top: 22,
                bottom: 22,
                left: wide ? constraints.maxWidth / 2 - 1 : 22,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [shPurple, shElectric, shCyan, shPurple],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Column(
                children: [
                  for (var i = 0; i < stages.length; i++)
                    LifecycleCard(
                      stage: stages[i],
                      index: i,
                      wide: wide,
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class LifecycleStage {
  const LifecycleStage(this.title, this.subtitle, this.icon, this.alignment);
  final String title;
  final String subtitle;
  final IconData icon;
  final Alignment alignment;
}

class LifecycleCard extends StatelessWidget {
  const LifecycleCard({
    required this.stage,
    required this.index,
    required this.wide,
  });

  final LifecycleStage stage;
  final int index;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Container(
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: shSurface2.withOpacity(.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: shBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [shPurple, shElectric],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shPurple.withOpacity(.22),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Icon(stage.icon, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stage.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stage.subtitle,
                      style: const TextStyle(
                        fontSize: 9,
                        color: shMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: shMuted,
              ),
            ],
          ),
        ),
      ),
    );

    if (!wide) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: card,
      );
    }

    final left = index.isEven;
    return SizedBox(
      height: 96,
      child: Align(
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: .84,
          child: card,
        ),
      ),
    );
  }
}

