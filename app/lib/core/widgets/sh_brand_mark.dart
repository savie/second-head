import 'package:flutter/material.dart';

import '../theme/sh_theme.dart';

class ShBrandMark extends StatelessWidget {
  const ShBrandMark({
    super.key,
    this.large = false,
    this.showWordmark = false,
  });

  final bool large;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    // Keep the compact mark safe inside constrained auth/header containers.
    // Large remains intentionally unchanged for dedicated brand surfaces.
    final size = large ? 180.0 : 64.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/brand/unity.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 18),
          const Text(
            'SECOND HEAD',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dual Mind. Infinite Potential.',
            style: TextStyle(fontSize: 14, color: shMuted),
          ),
          const Text(
            'Human – AI Unity.',
            style: TextStyle(fontSize: 14, color: shMuted),
          ),
        ],
      ],
    );
  }
}
