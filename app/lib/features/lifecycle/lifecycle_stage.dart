import 'package:flutter/material.dart';

class LifecycleStage {
  const LifecycleStage(this.title, this.subtitle, this.icon, this.accent);

  static const clone = LifecycleStage(
    'Clone',
    'Create a Second Head copy for a specific purpose or scenario.',
    Icons.copy_all_outlined,
    Color(0xFF9A45FF),
  );

  static const recovery = LifecycleStage(
    'Recovery',
    'Restore Second Head data, memories, or state from a backup.',
    Icons.shield_moon_outlined,
    Color(0xFF3B82F6),
  );

  static const inheritance = LifecycleStage(
    'Inheritance',
    'Pass memories, knowledge, and values to the next generation.',
    Icons.account_tree_outlined,
    Color(0xFF22D3EE),
  );

  static const succession = LifecycleStage(
    'Succession',
    'Prepare and manage the transition of Second Head ownership or stewardship.',
    Icons.people_outline,
    Color(0xFF6366F1),
  );

  static const legacy = LifecycleStage(
    'Legacy',
    'Manage a meaningful digital legacy for the long term.',
    Icons.menu_book_outlined,
    Color(0xFFF59E0B),
  );

  static const eol = LifecycleStage(
    'End of Life',
    'Handle the closure, deletion, or safe and respectful handover of Second Head.',
    Icons.favorite_border_outlined,
    Color(0xFFEC4899),
  );

  static const isl = LifecycleStage(
    'I / S / L',
    'Shared Journey data enters the I / S / L path.',
    Icons.account_tree_outlined,
    Color(0xFF22D3EE),
  );

  static const empty =
      LifecycleStage('', '', Icons.circle, Colors.transparent);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}
