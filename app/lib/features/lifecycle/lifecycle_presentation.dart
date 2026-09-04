import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import 'lifecycle_stage.dart';

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
    final q = query.trim().toLowerCase();
    final visible = LifecycleStage.all
        .where(
          (s) => q.isEmpty ||
              '${s.title} ${s.subtitle}'.toLowerCase().contains(q),
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
        final wide = constraints.maxWidth >= 330;
        if (!wide) {
          return _MobileLifecycle(stages: visible, onStageTap: onStageTap);
        }
        return _WideLifecycle(stages: visible, onStageTap: onStageTap);
      },
    );
  }
}

class _WideLifecycle extends StatelessWidget {
  const _WideLifecycle({required this.stages, required this.onStageTap});

  final List<LifecycleStage> stages;
  final ValueChanged<LifecycleStage> onStageTap;

  @override
  Widget build(BuildContext context) {
    final ordered = List<LifecycleStage>.generate(
      6,
      (index) => index < stages.length ? stages[index] : LifecycleStage.empty,
    );
    final width = MediaQuery.sizeOf(context).width - 20;
    final cardWidth = width * .47;

    return SizedBox(
      height: 650,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < 6; i++)
            if (ordered[i] != LifecycleStage.empty)
              Positioned(
                left: i.isEven ? 8 : null,
                right: i.isOdd ? 8 : null,
                top: switch (i) {
                  0 || 1 => 8,
                  2 || 3 => 220,
                  _ => 432,
                },
                width: cardWidth,
                height: 204,
                child: LifecycleCard(
                  stage: ordered[i],
                  onTap: () => onStageTap(ordered[i]),
                ),
              ),
        ],
      ),
    );
  }
}

class _MobileLifecycle extends StatelessWidget {
  const _MobileLifecycle({required this.stages, required this.onStageTap});

  final List<LifecycleStage> stages;
  final ValueChanged<LifecycleStage> onStageTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final stage in stages)
          SizedBox(
            height: 220,
            child: LifecycleCard(
              stage: stage,
              onTap: () => onStageTap(stage),
            ),
          ),
      ],
    );
  }
}

class LifecycleCard extends StatelessWidget {
  const LifecycleCard({
    super.key,
    required this.stage,
    required this.onTap,
  });

  final LifecycleStage stage;
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
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StageIcon(stage: stage, size: 50),
                  const SizedBox(height: 8),
                  Text(
                    stage.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      height: 1.1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stage.subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: shMuted,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 21,
                    color: stage.accent,
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
