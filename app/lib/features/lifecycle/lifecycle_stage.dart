import 'package:flutter/material.dart';

class JourneyLifecyclePayload {
  const JourneyLifecyclePayload({
    required this.title,
    required this.type,
    required this.content,
    required this.isPrivate,
    required this.date,
    this.semanticSourceId,
  });

  final String title;
  final String type;
  final String content;
  final bool isPrivate;
  final String date;
  final String? semanticSourceId;
}

class LifecycleStage {
  const LifecycleStage(this.title, this.subtitle, this.icon, this.accent);

  static const clone = LifecycleStage(
    'Clone',
    'Private Journey data enters the Clone / Recovery path.',
    Icons.copy_all_outlined,
    Color(0xFF9A45FF),
  );

  static const isl = LifecycleStage(
    'I / S / L',
    'Shared Journey data enters the I / S / L path.',
    Icons.account_tree_outlined,
    Color(0xFF22D3EE),
  );

  static const empty =
      LifecycleStage('', '', Icons.circle, Colors.transparent);

  static const all = <LifecycleStage>[
    LifecycleStage(
      'Clone',
      'Create a Second Head copy for a specific purpose or scenario.',
      Icons.copy_all_outlined,
      Color(0xFF9A45FF),
    ),
    LifecycleStage(
      'Recovery',
      'Restore Second Head data, memories, or state from a backup.',
      Icons.shield_moon_outlined,
      Color(0xFF3B82F6),
    ),
    LifecycleStage(
      'Inheritance',
      'Pass memories, knowledge, and values to the next generation.',
      Icons.account_tree_outlined,
      Color(0xFF22D3EE),
    ),
    LifecycleStage(
      'Succession',
      'Prepare and manage the transition of Second Head ownership or stewardship.',
      Icons.people_outline_rounded,
      Color(0xFF6366F1),
    ),
    LifecycleStage(
      'Legacy',
      'Manage a meaningful digital legacy for the long term.',
      Icons.menu_book_rounded,
      Color(0xFFF59E0B),
    ),
    LifecycleStage(
      'End of Life',
      'Handle the closure, deletion, or safe and respectful handover of Second Head.',
      Icons.favorite_border_rounded,
      Color(0xFFEC4899),
    ),
  ];

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}
