import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/navigation/sh_navigation_shell.dart';

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

class LifecycleView extends StatefulWidget {
  const LifecycleView({super.key});

  @override
  State<LifecycleView> createState() => LifecycleViewState();
}

class LifecycleViewState extends State<LifecycleView> {
  String query = '';

  Future<void> _search(BuildContext context) async {
    const stages = [
      LifecycleStage('Clone', 'Create a Second Head copy for a specific purpose or scenario.', Icons.copy_all_outlined, Color(0xFF9A45FF)),
      LifecycleStage('Recovery', 'Restore Second Head data, memories, or state from a backup.', Icons.shield_moon_outlined, Color(0xFF3B82F6)),
      LifecycleStage('Inheritance', 'Pass memories, knowledge, and values to the next generation.', Icons.account_tree_outlined, Color(0xFF22D3EE)),
      LifecycleStage('Succession', 'Prepare and manage the transition of Second Head ownership or stewardship.', Icons.people_outline, Color(0xFF6366F1)),
      LifecycleStage('Legacy', 'Manage a meaningful digital legacy for the long term.', Icons.menu_book_outlined, Color(0xFFF59E0B)),
      LifecycleStage('End of Life', 'Handle the closure, deletion, or safe and respectful handover of Second Head.', Icons.favorite_border_outlined, Color(0xFFEC4899)),
    ];
    final result = await showShInternalSearch<LifecycleStage>(
      context: context,
      hintText: 'Search Lifecycle',
      search: (query) => [
        for (final stage in stages)
          if (query.isEmpty ||
              '${stage.title} ${stage.subtitle}'.toLowerCase().contains(query))
            ShSearchResult<LifecycleStage>(
              value: stage,
              title: stage.title,
              subtitle: stage.subtitle,
            ),
      ],
    );
    if (!mounted || result == null) return;
    _showDetail(context, result);
  }

  void _showDetail(BuildContext context, LifecycleStage stage) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LifecycleDetailView(stage: stage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShTopBar(
          title: 'Lifecycle',
          onSearch: () => _search(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 18),
            child: LifecycleMap(
              query: query,
              onStageTap: (stage) => _showDetail(context, stage),
            ),
          ),
        ),
      ],
    );
  }
}

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
    final stages = [
      const LifecycleStage(
        'Clone',
        'Create a Second Head copy for a specific purpose or scenario.',
        Icons.copy_all_outlined,
        Color(0xFF9A45FF),