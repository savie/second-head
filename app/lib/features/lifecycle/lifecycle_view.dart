import 'package:flutter/material.dart';

import '../journey/journey_data.dart';
import 'eol/eol_entry_view.dart';
import 'clone/clone_view.dart';
import 'recovery/recovery_view.dart';
import 'inheritance/inheritance_view.dart';
import 'succession/succession_view.dart';
import 'legacy/legacy_view.dart';
import 'lifecycle_widgets.dart';

class LifecycleView extends StatefulWidget {
  const LifecycleView({super.key});

  @override
  State<LifecycleView> createState() => LifecycleViewState();
}

class LifecycleViewState extends State<LifecycleView> {
  String query = '';

  Future<void> _search(BuildContext context) async {
    const stages = [
      LifecycleStage.clone,
      LifecycleStage.recovery,
      LifecycleStage.inheritance,
      LifecycleStage.succession,
      LifecycleStage.legacy,
      LifecycleStage.eol,
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

  List<JourneyLifecyclePayload> get _sharedJourneyPayloads => [
        for (final item in shJourneyItems)
          if (!item.isPrivate)
            JourneyLifecyclePayload(
              title: item.title,
              type: item.type,
              content: item.content,
              isPrivate: item.isPrivate,
              date: item.date,
              semanticSourceId: item.semanticSourceId,
            ),
      ];

  void _showDetail(BuildContext context, LifecycleStage stage) {
    if (stage.title == 'End of Life') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const EolEntryView(),
        ),
      );
      return;
    }

    final destination = switch (stage.title) {
      'Clone' => CloneView(incomingItems: _sharedJourneyPayloads),
      'Recovery' => RecoveryView(incomingItems: _sharedJourneyPayloads),
      'Inheritance' => InheritanceView(incomingItems: _sharedJourneyPayloads),
      'Succession' => SuccessionView(incomingItems: _sharedJourneyPayloads),
      'Legacy' => LegacyView(incomingItems: _sharedJourneyPayloads),
      _ => LifecycleDetailView(
          stage: stage,
          incomingItems: _sharedJourneyPayloads,
        ),
    };

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => destination),
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
