import 'package:flutter/material.dart';

import '../../../core/theme/sh_theme.dart';
import 'eol_controller.dart';
import 'eol_confirmation_view.dart';
import 'eol_widgets.dart';

class EolImpactReviewView extends StatelessWidget {
  const EolImpactReviewView({super.key, required this.controller});

  final EolController controller;

  @override
  Widget build(BuildContext context) {
    final impact = controller.state.impact;

    return EolShell(
      title: 'EOL Review',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Before continuing', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500)),
          const SizedBox(height: 7),
          const Text(
            'Review the local lifecycle surfaces connected to this Second Head.',
            style: TextStyle(color: shMuted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 20),
          EolCard(
            child: Column(
              children: [
                EolImpactRow(
                  icon: Icons.timeline_rounded,
                  title: 'Journey / history',
                  subtitle: 'Existing Journey items remain outside generic delete-data behavior.',
                  trailing: '${impact.journeyItems}',
                ),
                const Divider(height: 1),
                EolImpactRow(
                  icon: Icons.hub_outlined,
                  title: 'Relationships',
                  subtitle: 'Existing local authorization records are reviewed, not bulk-deleted.',
                  trailing: '${impact.relationships}',
                ),
                const Divider(height: 1),
                EolImpactRow(
                  icon: Icons.shield_moon_outlined,
                  title: 'Recovery snapshots',
                  subtitle: 'Existing local recovery snapshots are retained for review.',
                  trailing: '${impact.recoverySnapshots}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const EolCard(
            accent: Color(0xFFF59E0B),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These counts describe the current frontend state only. They do not represent a completed Supabase lifecycle transition.',
                    style: TextStyle(fontSize: 12, color: shMuted, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          EolActionButton(
            label: 'Continue to confirmation',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              controller.openConfirmation();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EolConfirmationView(controller: controller),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
