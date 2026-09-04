import 'package:flutter/material.dart';

import '../../../core/theme/sh_theme.dart';
import 'eol_controller.dart';
import 'eol_widgets.dart';

class EolTerminalView extends StatelessWidget {
  const EolTerminalView({super.key, required this.controller});

  final EolController controller;

  @override
  Widget build(BuildContext context) {
    final impact = controller.state.impact;
    return EolShell(
      title: 'Second Head',
      child: Column(
        children: [
          const SizedBox(height: 16),
          const EolHero(),
          const SizedBox(height: 24),
          const EolCard(
            child: Column(
              children: [
                Text('End of Life', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Text(
                  'The frontend EOL flow has reached its terminal UI state. Backend lifecycle execution remains behind the service boundary.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: shMuted, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          EolCard(
            child: Column(
              children: [
                const EolImpactRow(
                  icon: Icons.fingerprint_rounded,
                  title: 'Identity & history',
                  subtitle: 'Not erased by the frontend EOL flow.',
                  trailing: 'Retained',
                ),
                const Divider(height: 1),
                EolImpactRow(
                  icon: Icons.hub_outlined,
                  title: 'Relationships reviewed',
                  subtitle: 'Local relationship state remains available for later backend orchestration.',
                  trailing: '${impact.relationships}',
                ),
                const Divider(height: 1),
                EolImpactRow(
                  icon: Icons.shield_moon_outlined,
                  title: 'Recovery snapshots',
                  subtitle: 'No snapshot is physically deleted by this frontend flow.',
                  trailing: '${impact.recoverySnapshots}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          EolActionButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }
}
