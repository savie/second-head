import 'package:flutter/material.dart';

import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/theme/sh_theme.dart';

class LifecycleView extends StatefulWidget {
  const LifecycleView({super.key});

  @override
  State<LifecycleView> createState() => LifecycleViewState();
}

class LifecycleViewState extends State<LifecycleView> {
  String query = '';

  Future<void> _search(BuildContext context) async {
    final controller = TextEditingController(text: query);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          8,
          18,
          MediaQuery.of(sheet).viewInsets.bottom + 18,
        ),
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
            Row(
              children: [
                _StageIcon(stage: stage, size: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stage.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              stage.subtitle,
              style: const TextStyle(
                color: shMuted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 88,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Menu',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu, size: 30),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Lifecycle',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Kelola siklus penuh Second Head',
                        style: TextStyle(
                          fontSize: 15,
                          color: shMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Search',
                  onPressed: () => _search(context),
                  icon: const Icon(Icons.search, size: 30),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 18),
            child: LifecycleMap(
              query: query,
              onStageTap: (stage) => _showDetail(context, stage),
            ),
          ),
        ),
      ],
    );
  }
}

class LifecycleMap extends StatelessWidget {
  const LifecycleMap({
    super.key,
    required this.query,
    required this.onStageTap,
  });

  final String query;
  final ValueChanged<LifecycleStage> onStageTap;

  @override
  Widget build(BuildContext context) {
    final stages = [
      const LifecycleStage(
        'Clone',
        'Buat salinan Second Head untuk tujuan tertentu atau skenario spesifik.',
        Icons.copy_all_rounded,
        Color(0xFF9A45FF),
      ),
      const LifecycleStage(
        'Recovery',
        'Pulihkan data, memori, atau keadaan Second Head dari cadangan.',
        Icons.shield_moon_outlined,
        Color(0xFF3B82F6),
      ),
      const LifecycleStage(
        'Inheritance',
        'Teruskan memori, pengetahuan, dan nilai kepada generasi berikutnya.',
        Icons.account_tree_rounded,
        Color(0xFF22D3EE),
      ),
      const LifecycleStage(
        'Succession',
        'Siapkan dan kelola transisi kepemilikan atau pengelolaan Second Head.',
        Icons.people_outline_rounded,
        Color(0xFF6366F1),
      ),
      const LifecycleStage(
        'Legacy',
        'Kelola warisan digital yang bermakna dan berdampak jangka panjang.',
        Icons.menu_book_rounded,
        Color(0xFFF59E0B),
      ),
      const LifecycleStage(
        'End of Life',
        'Atur penutupan, penghapusan, atau penyerahan Second Head secara aman dan terhormat.',
        Icons.favorite_border_rounded,
        Color(0xFFEC4899),
      ),
    ];

    final q = query.trim().toLowerCase();
    final visible = stages
        .where(
          (s) => q.isEmpty ||
              '\${s.title} \${s.subtitle}'.toLowerCase().contains(q),
        )
        .toList();

    if (visible.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: shSurface.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: shBorder),
        ),
        child: const Center(
          child: Text(
            'Tidak ada tahap lifecycle yang cocok.',
            style: TextStyle(fontSize: 15, color: shMuted),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 560;

        if (!wide) {
          return _MobileLifecycle(
            stages: visible,
            onStageTap: onStageTap,
          );
        }

        return _WideLifecycle(
          stages: visible,
          onStageTap: onStageTap,
        );
      },
    );
  }
}

class _WideLifecycle extends StatelessWidget {
  const _WideLifecycle({
    required this.stages,
    required this.onStageTap,
  });

  final List<LifecycleStage> stages;
  final ValueChanged<LifecycleStage> onStageTap;

  @override
  Widget build(BuildContext context) {
    final ordered = List<LifecycleStage>.generate(
      6,
      (index) => index < stages.length ? stages[index] : LifecycleStage.empty,
    );

    final width = MediaQuery.sizeOf(context).width - 20;

    return SizedBox(
      height: 790,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _LifecycleBackdropPainter(),
            ),
          ),
          for (var i = 0; i < 6; i++)
            if (ordered[i] != LifecycleStage.empty)
              Positioned(
                left: i.isEven ? 8 : null,
                right: i.isOdd ? 8 : null,
                top: switch (i) {
                  0 || 1 => 4,
                  2 || 3 => 220,
                  _ => 500,
                },
                width: width * .47,
                height: 250,
                child: LifecycleCard(
                  stage: ordered[i],
                  index: i,
                  onTap: () => onStageTap(ordered[i]),
                ),
              ),
          Positioned(
            left: (width - 150) / 2,
            top: 355,
            child: const _LifecycleHub(),
          ),
        ],
      ),
    );
  }
}

class _MobileLifecycle extends StatelessWidget {
  const _MobileLifecycle({
    required this.stages,
    required this.onStageTap,
  });

  final List<LifecycleStage> stages;
  final ValueChanged<LifecycleStage> onStageTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          SizedBox(
            height: 220,
            child: LifecycleCard(
              stage: stages[i],
              index: i,
              onTap: () => onStageTap(stages[i]),
            ),
          ),
          if (i == 2)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: _LifecycleHub(compact: true),
            ),
        ],
      ],
    );
  }
}

class LifecycleStage {
  const LifecycleStage(this.title, this.subtitle, this.icon, this.accent);

  static const empty =
      LifecycleStage('', '', Icons.circle, Colors.transparent);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}

class LifecycleCard extends StatelessWidget {
  const LifecycleCard({
    super.key,
    required this.stage,
    required this.index,
    required this.onTap,
  });

  final LifecycleStage stage;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OrganicCardPainter(accent: stage.accent),
      child: ClipPath(
        clipper: _OrganicCardClipper(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 20, 20),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: shBackground.withValues(alpha: .92),
                        border: Border.all(
                          color: stage.accent.withValues(alpha: .7),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '\${index + 1}'.padLeft(2, '0'),
                        style: TextStyle(
                          color: stage.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StageIcon(stage: stage, size: 76),
                        const Spacer(),
                        Text(
                          stage.title,
                          style: const TextStyle(
                            fontSize: 22,
                            height: 1.1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stage.subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: shMuted,
                            height: 1.45,
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: stage.accent.withValues(alpha: .05),
                              border: Border.all(
                                color: stage.accent.withValues(alpha: .42),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 22,
                              color: stage.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StageIcon extends StatelessWidget {
  const _StageIcon({required this.stage, required this.size});

  final LifecycleStage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: shBackground.withValues(alpha: .78),
        border: Border.all(
          color: stage.accent.withValues(alpha: .42),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: stage.accent.withValues(alpha: .14),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(stage.icon, size: size * .46, color: stage.accent),
    );
  }
}

class _LifecycleHub extends StatelessWidget {
  const _LifecycleHub({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 96.0 : 150.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: shBackground.withValues(alpha: .96),
        border: Border.all(
          color: shPurple.withValues(alpha: .8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: shPurple.withValues(alpha: .18),
            blurRadius: 28,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.all(compact ? 17 : 24),
      child: Image.asset(
        'assets/brand/unity.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _OrganicCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(24, 0)
      ..lineTo(size.width - 64, 0)
      ..quadraticBezierTo(size.width - 12, 2, size.width - 4, 30)
      ..lineTo(size.width, size.height - 54)
      ..quadraticBezierTo(
        size.width - 2,
        size.height - 8,
        size.width - 48,
        size.height - 4,
      )
      ..lineTo(54, size.height)
      ..quadraticBezierTo(4, size.height - 3, 2, size.height - 48)
      ..lineTo(0, 46)
      ..quadraticBezierTo(2, 4, 24, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _OrganicCardClipper oldClipper) => false;
}

class _OrganicCardPainter extends CustomPainter {
  _OrganicCardPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _OrganicCardClipper().getClip(size);
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: .12),
          shSurface.withValues(alpha: .96),
          accent.withValues(alpha: .08),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, fill);

    final border = Paint()
      ..color = accent.withValues(alpha: .78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _OrganicCardPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class _LifecycleBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 430);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = shPurple.withValues(alpha: .14);

    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(center, 115.0 + (i * 20), paint);
    }

    final line = Paint()
      ..strokeWidth = 1
      ..shader = const LinearGradient(
        colors: [shPurple, shElectric, shCyan, shPurple],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawLine(
      Offset(size.width / 2, 50),
      Offset(size.width / 2, size.height - 40),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _LifecycleBackdropPainter oldDelegate) => false;
}
