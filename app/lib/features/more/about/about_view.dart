import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/navigation/sh_navigation_shell.dart';
import '../../../core/theme/sh_theme.dart';
import '../../../core/widgets/sh_brand_mark.dart';
import '../more_widgets.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _info = info);
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;

    return Column(
      children: [
        const ShTopBar(title: 'About'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            children: [
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Second Head',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Human - AI Unity',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: shMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: ShBrandMark(large: true),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  color: shSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: shBorder),
                ),
                child: Column(
                  children: [
                    AboutRow('Version', info?.version ?? 'Loading…'),
                    const Divider(height: 1, color: shBorder),
                    AboutRow(
                      'Build',
                      info == null ? 'Loading…' : '#${info.buildNumber}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Center(
                child: Text(
                  '© 2026 second head',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: shMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
