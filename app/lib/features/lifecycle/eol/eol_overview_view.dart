import 'package:flutter/material.dart';

import 'eol_controller.dart';
import 'eol_impact_review_view.dart';
import 'eol_widgets.dart';

class EolOverviewView extends StatelessWidget {
  const EolOverviewView({super.key, required this.controller});

  final EolController controller;

  @override
  Widget build(BuildContext context) {
    return EolShell(
      title: 'End of Life',
      child: Column(
        children: [
          const EolHero(),
          const SizedBox(height: 24),
          const EolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What this means', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 9),
                Text(
                  'End of Life is a terminal lifecycle transition for this Second Head. It is not the same as immediately erasing identity or history.',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const EolCard(
            child: Column(
              children: [
                EolImpactRow(
                  icon: Icons.fingerprint_rounded,
                  title: 'Identity & history',
                  subtitle: 'Reviewed as part of the terminal lifecycle.',
                  trailing: 'Retained',
                ),
                Divider(height: 1),
                EolImpactRow(
                  icon: Icons.hub_outlined,
                  title: 'Relationships',
                  subtitle: 'Clone, succession, inheritance, and legacy may be affected.',
                ),
                Divider(height: 1),
                EolImpactRow(
                  icon: Icons.shield_moon_outlined,
                  title: 'Recovery',
                  subtitle: 'Existing recovery state is reviewed before closure.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          EolActionButton(
            label: 'Review impact',
            icon: Icons.arrow_forward_rounded,
            onPressed: () async {
              await controller.loadImpact();
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EolImpactReviewView(controller: controller),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
