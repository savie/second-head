import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/widgets/sh_brand_mark.dart';
import 'more_widgets.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShTopBar(title: 'About'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
            children: [
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [shPurple, shElectric],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: shPurple.withValues(alpha: .22),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                      child: const ShBrandMark(),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'SECOND HEAD',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Your second head, built for continuity.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: shMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: shSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: shBorder),
                ),
                child: const Column(
                  children: [
                    AboutRow('Version', '1.0.0'),
                    Divider(height: 1, color: shBorder),
                    AboutRow('Build', '#1'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Second Head',
                  style: TextStyle(fontSize: 9, color: shMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
