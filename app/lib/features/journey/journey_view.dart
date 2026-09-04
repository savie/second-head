import 'package:flutter/material.dart';

import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/theme/sh_theme.dart';
import 'semantic_domain_view.dart';
import 'journey_widgets.dart';
import 'memory/memory_view.dart';
import 'knowledge/knowledge_view.dart';
import 'experience/experience_view.dart';
import 'semantic_hook.dart';
import 'journey_data.dart';
import '../profile/integrations/integration_authorization_store.dart';

class JourneyView extends StatefulWidget {
  const JourneyView({super.key});

  @override
  State<JourneyView> createState() => JourneyViewState();
}

class JourneyViewState extends State<JourneyView> {
  String filter = 'All';

  List<JourneyItem> get items => shJourneyItems;

  Future<void> _loadJourney() async {
    await JourneyStore.refreshFromDisk();
    if (mounted) setState(() {});
  }

  void _syncSemanticRecords() {
    final existingSources = items.map((item) => item.semanticSourceId).whereType<String>().toSet();
    final additions = <JourneyItem>[];
    for (final record in shSemanticRecords.value) {
      if (existingSources.contains(record.sourceId + '|' + record.content)) continue;
      additions.add(JourneyItem(
        record.content,
        'Created from explicit Conversation command',
        'Just now',
        record.domain.label,
        record.content,
        true,
        semanticSourceId: record.sourceId + '|' + record.content,
      ));
    }
    if (additions.isNotEmpty) {
      setState(() => items.insertAll(0, additions));
      JourneyStore.persist();
    }
  }

  @override
  void initState() {
    super.initState();
    shSemanticRecords.addListener(_syncSemanticRecords);
    _loadJourney();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSemanticRecords());
  }

  @override
  void dispose() {
    shSemanticRecords.removeListener(_syncSemanticRecords);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (var i = 0; i < items.length; i++)
        if (filter == 'All' || items[i].type == filter) i,
    ];

    return Stack(
      children: [
        Column(
          children: [
            ShTopBar(
              title: 'Journey',
              onSearch: () => _search(context),
              actions: [
                IconButton(
                  tooltip: 'Domains',
                  onPressed: () => _openDomain(context),
                  icon: const Icon(Icons.hub_outlined, size: 26),
                ),
              ],
            ),
            JourneyFilters(
              value: filter,
              onChanged: (value) => setState(() => filter = value),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                itemCount: visible.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 142,
                ),
                itemBuilder: (_, index) {
                  final itemIndex = visible[index];
                  return JourneyCard(
                    item: items[itemIndex],
                    onTap: () => _openDetail(context, itemIndex),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: FloatingActionButton(
            heroTag: 'journey-add',
            onPressed: () => _create(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _openDomain(BuildContext context) async {
    final domain = await showModalBottomSheet<ShSemanticDomain>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Explore domains', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              for (final domain in ShSemanticDomain.values)
                ListTile(
                  leading: Icon(domain.icon, color: shPurple),
                  title: Text(domain.label),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => Navigator.pop(sheet, domain),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || domain == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => switch (domain) {
          ShSemanticDomain.memory => const MemoryView(),
          ShSemanticDomain.knowledge => const KnowledgeView(),
          ShSemanticDomain.experience => const ExperienceView(),
        },
      ),
    );
  }

  Future<void> _search(BuildContext context) async {
    final result = await showShInternalSearch<int>(
      context: context,
      hintText: 'Search Journey',
      search: (query) {
        return [
          for (var i = 0; i < items.length; i++)
            if (query.isEmpty ||
                [
                  items[i].title,
                  items[i].subtitle,
                  items[i].content,
                  items[i].type,
                ].any((value) => value.toLowerCase().contains(query)))
              ShSearchResult<int>(
                value: i,
                title: items[i].title,
                subtitle: items[i].type,
              ),
        ];
      },
    );

    if (!mounted || result == null || result < 0 || result >= items.length) {
      return;
    }

    _openDetail(context, result);
  }

  void _openDetail(BuildContext context, int itemIndex) {
    if (itemIndex < 0 || itemIndex >= items.length) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JourneyDetail(
          item: items[itemIndex],
          onChanged: () => setState(() {}),
          onDelete: () {
            if (itemIndex < 0 || itemIndex >= items.length) return;
            setState(() => items.removeAt(itemIndex));
            JourneyStore.persist();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final type = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  JourneyCreateAction(
                    icon: Icons.psychology_outlined,
                    label: 'Memory',
                    onTap: () => Navigator.of(sheet).pop('Memory'),
                  ),
                  JourneyCreateAction(
                    icon: Icons.menu_book_outlined,
                    label: 'Knowledge',
                    onTap: () => Navigator.of(sheet).pop('Knowledge'),
                  ),
                  JourneyCreateAction(
                    icon: Icons.auto_awesome_outlined,
                    label: 'Experience',
                    onTap: () => Navigator.of(sheet).pop('Experience'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || type == null) return;

    final draft = await _showJourneyEditor(
      context,
      title: 'Create $type',
    );

    if (!mounted || draft == null) return;

    setState(
      () => items.insert(
        0,
        JourneyItem(
          draft.title,
          draft.content,
          'Just now',
          type,
          draft.content,
          draft.isPrivate,
        ),
      ),
    );
    await JourneyStore.persist();
  }
}
