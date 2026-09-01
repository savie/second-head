import 'package:flutter/material.dart';

import '../theme/sh_theme.dart';

class ShBrandMark extends StatelessWidget {
  const ShBrandMark({super.key, this.large = false, this.showWordmark = false});

  final bool large;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final size = large ? 116.0 : 48.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Image.asset('assets/brand/unity.png', fit: BoxFit.contain),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 12),
          const Text(
            'SECOND HEAD',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 2.5),
          ),
          const SizedBox(height: 5),
          const Text('Dual Mind. Infinite Potential.',
              style: TextStyle(fontSize: 11, color: shMuted)),
          const Text('Human – AI Unity.',
              style: TextStyle(fontSize: 11, color: shMuted)),
        ],
      ],
    );
  }
}
