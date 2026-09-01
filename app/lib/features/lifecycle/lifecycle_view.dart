import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';

class LifecycleView extends StatefulWidget {
  const LifecycleView({super.key});
  @override State<LifecycleView> createState()=>LifecycleViewState();
}

class LifecycleViewState extends State<LifecycleView> {
  Future<void> _search(BuildContext context) async {
    final controller = TextEditingController(text: query);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(18, 8, 18,
            MediaQuery.of(sheet).viewInsets.bottom + 18),
        child: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => Navigator.pop(sheet, controller.text),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search lifecycle',
          ),
        ),
      ),
    );
    controller.dispose();
    if (!mounted || result == null) return;
    setState(() => query = result.trim());
  }

  void _showDetail(BuildContext context, LifecycleStage stage) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(stage.icon, size: 24),
              const SizedBox(width: 10),
              Expanded(child: Text(stage.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 12),
            Text(stage.subtitle,
              style: const TextStyle(color: shMuted, height: 1.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShTopBar(
          title: 'Lifecycle',
          actions: [
            IconButton(onPressed: _search, icon: const Icon(Icons.search, size: 19)),
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
                    child: LifecycleMap(query: query, onStageTap: _showDetail),
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
  const LifecycleMap({super.key, required this.query, required this.onStageTap});
  final String query;
  final ValueChanged<LifecycleStage> onStageTap;

  @override
  Widget build(BuildContext context) {
    final stages = [
      const LifecycleStage('Clone','Duplicate your Second Head state',Icons.copy_all_rounded),
      const LifecycleStage('Recovery','Restore continuity when something changes',Icons.restore_rounded),
      const LifecycleStage(
        'Inheritance',
        'Pass knowledge and identity forward',
        Icons.account_tree_rounded,
        Alignment.centerLeft,
      ),
      const LifecycleStage('Succession','Continue the role beyond one instance',Icons.swap_horiz_rounded),
      const LifecycleStage(
        'Legacy',
        'Preserve what should remain meaningful',
        Icons.auto_awesome_rounded,
        Alignment.centerLeft,
      ),
      const LifecycleStage('End of Life','Close the lifecycle with dignity and control',Icons.trip_origin_rounded),
    ];
    final q=query.toLowerCase();
    final visible=stages.where((s)=>q.isEmpty||('${s.title} ${s.subtitle}').toLowerCase().contains(q)).toList();

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
                  for (var i = 0; i < visible.length; i++)
                    LifecycleCard(stage: visible[i], index: i, wide: wide, onTap: () => onStageTap(visible[i])),
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
  const LifecycleStage(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

class LifecycleCard extends StatelessWidget {
  const LifecycleCard({
    required this.stage,
    required this.index,
    required this.wide,
    required this.onTap,
  });

  final LifecycleStage stage;
  final int index;
  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
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

