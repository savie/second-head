import 'package:flutter/material.dart';

import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/storage/recovery_snapshot_store.dart';
import '../../core/theme/sh_theme.dart';
import '../integrations/integration_authorization_store.dart';
import '../journey/journey_data.dart';
import 'lifecycle_presentation.dart';
import 'lifecycle_stage.dart';

class LifecycleView extends StatefulWidget {
  const LifecycleView({super.key});

  @override
  State<LifecycleView> createState() => LifecycleViewState();
}

class LifecycleViewState extends State<LifecycleView> {
  String query = '';

  Future<void> _search(BuildContext context) async {
    final result = await showShInternalSearch<LifecycleStage>(
      context: context,
      hintText: 'Search Lifecycle',
      search: (query) => [
        for (final stage in LifecycleStage.all)
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LifecycleDetailView(
          stage: stage,
          incomingItems: _sharedJourneyPayloads,
        ),
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

class LifecycleDetailView extends StatefulWidget {
  const LifecycleDetailView({
    super.key,
    required this.stage,
    this.incoming,
    this.incomingItems = const [],
  });

  final LifecycleStage stage;
  final JourneyLifecyclePayload? incoming;
  final List<JourneyLifecyclePayload> incomingItems;

  @override
  State<LifecycleDetailView> createState() => _LifecycleDetailViewState();
}

class _LifecycleDetailViewState extends State<LifecycleDetailView> {
  final List<_LifecycleRequestGroup> _groups = [
    const _LifecycleRequestGroup(),
  ];
  final TextEditingController _cloneEmailController = TextEditingController();
  final _snapshots = RecoverySnapshotStore.instance;
  final _integrations = IntegrationAuthorizationStore.instance;
  bool _storesReady = false;

  bool get _isRecovery => widget.stage.title == 'Recovery';

  @override
  void initState() {
    super.initState();
    _snapshots.addListener(_storesChanged);
    _integrations.addListener(_storesChanged);
    _loadStores();
  }

  @override
  void dispose() {
    _snapshots.removeListener(_storesChanged);
    _integrations.removeListener(_storesChanged);
    _cloneEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    await Future.wait([
      JourneyStore.refreshFromDisk(),
      _snapshots.refreshFromDisk(),
      _integrations.refreshFromDisk(),
    ]);
    if (mounted) setState(() => _storesReady = true);
  }

  void _storesChanged() {
    if (mounted) setState(() {});
  }

  List<RecoverySnapshot> get _recoveryHistory => _snapshots.items;

  List<IntegrationAuthorization> get _cloneResults =>
      _integrations.items
          .where((item) => item.type == 'Clone')
          .toList(growable: false);

  List<IntegrationAuthorization> get _islResults =>
      _integrations.items
          .where((item) => item.type == widget.stage.title)
          .toList(growable: false);

  String _recoveryDate(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return value.year.toString() + '-' +
        two(value.month) + '-' +
        two(value.day) + ' ' +
        two(value.hour) + ':' +
        two(value.minute);
  }

  Future<void> _createRecoverySnapshot() async {
    await JourneyStore.refreshFromDisk();
    await _snapshots.createSnapshot();
  }

  Future<void> _restoreRecovery(RecoverySnapshot snapshot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Snapshot?'),
        content: Text(
          'This will restore the selected FULL snapshot to your current SH.\n\n'
          'Created: ' +
              _recoveryDate(snapshot.createdAt),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _snapshots.restoreSnapshot(snapshot);
      await JourneyStore.refreshFromDisk();
      await _integrations.refreshFromDisk();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Snapshot restored successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $error')),
      );
    }
  }

  Future<void> _deleteRecoverySnapshot(RecoverySnapshot snapshot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Snapshot?'),
        content: Text(
          'This permanently removes snapshot ${snapshot.id} from local Recovery history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _snapshots.deleteSnapshot(snapshot.id);
  }

  void _openRecoveryDetail(RecoverySnapshot snapshot, int index) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recovery Detail #' + index.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _LifecycleDataRow(label: 'ID', value: snapshot.id),
                _LifecycleDataRow(label: 'Type', value: snapshot.type),
                _LifecycleDataRow(
                  label: 'Created',
                  value: _recoveryDate(snapshot.createdAt),
                ),
                _LifecycleDataRow(
                  label: 'Memory',
                  value: snapshot.memoryCount.toString(),
                ),
                _LifecycleDataRow(
                  label: 'Knowledge',
                  value: snapshot.knowledgeCount.toString(),
                ),
                _LifecycleDataRow(
                  label: 'Experience',
                  value: snapshot.experienceCount.toString(),
                ),
                _LifecycleDataRow(
                  label: 'Files',
                  value: snapshot.fileCount.toString(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _deleteRecoverySnapshot(snapshot);
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _restoreRecovery(snapshot);
                        },
                        icon: const Icon(Icons.restore_rounded),
                        label: const Text('Restore'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _isIsl =>
      widget.stage.title == 'Inheritance' ||
      widget.stage.title == 'Succession' ||
      widget.stage.title == 'Legacy';

  bool get _isClone => widget.stage.title == 'Clone';

  List<JourneyLifecyclePayload> get _availableItems {
    final source = widget.incomingItems.isNotEmpty
        ? widget.incomingItems
        : (widget.incoming == null ? const [] : [widget.incoming!]);
    final seen = <String>{};
    return [
      for (final item in source)
        if (!item.isPrivate &&
            seen.add(item.semanticSourceId ?? '${item.type}|${item.title}'))
          item,
    ];
  }

  String _itemKey(JourneyLifecyclePayload item) =>
      item.semanticSourceId ?? '${item.type}|${item.title}';

  Set<String> _requestedKeysForTarget(String target, {String? type}) {
    final normalizedTarget = target.trim().toLowerCase();
    final keys = <String>{};
    for (final item in _integrations.items) {
      if (type != null && item.type != type) continue;
      if (item.targetAccountId.trim().toLowerCase() != normalizedTarget) {
        continue;
      }
      for (final values in item.scope.values) {
        keys.addAll(values);
      }
    }
    return keys;
  }

  bool _wasAlreadyRequested(
    JourneyLifecyclePayload item,
    String target,
  ) =>
      _requestedKeysForTarget(
        target,
        type: widget.stage.title,
      ).contains(_itemKey(item));

  void _setTarget(int index, String value) {
    final group = _groups[index];
    setState(() {
      _groups[index] = group.copyWith(targetAccountId: value);
    });
  }

  void _toggleItem(int groupIndex, JourneyLifecyclePayload item) {
    setState(() {
      final group = _groups[groupIndex];
      final key = _itemKey(item);
      final selected = Set<String>.from(group.selectedKeys);
      if (!selected.add(key)) selected.remove(key);
      _groups[groupIndex] = group.copyWith(selectedKeys: selected);
    });
  }

  void _addGroup() {
    setState(() => _groups.add(const _LifecycleRequestGroup()));
  }

  Map<String, List<String>> _scopeForItems(
    Iterable<JourneyLifecyclePayload> items,
  ) {
    final scope = <String, List<String>>{};
    for (final item in items) {
      final key = _itemKey(item);
      final scopeKey = switch (item.type.toLowerCase()) {
        'memory' => 'memory_ids',
        'knowledge' => 'knowledge_ids',
        'experience' => 'experience_ids',
        _ => 'journey_event_ids',
      };
      (scope[scopeKey] ??= <String>[]).add(key);
    }
    return scope;
  }

  Future<void> _request() async {
    final groups = <_LifecycleRequestGroup>[];
    for (final group in _groups) {
      final target = group.targetAccountId.trim();
      if (target.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Masukkan Target Account ID untuk setiap target.'),
          ),
        );
        return;
      }
      if (group.selectedKeys.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih minimal satu data Journey untuk setiap target.'),
          ),
        );
        return;
      }
      final selected = _availableItems
          .where((item) => group.selectedKeys.contains(_itemKey(item)))
          .toList();
      final scope = _scopeForItems(selected);
      if (_integrations.findRequest(
            type: widget.stage.title,
            targetAccountId: target,
            scope: scope,
          ) !=
          null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Request dengan target dan data yang sama sudah pernah dibuat.',
            ),
          ),
        );
        return;
      }
      groups.add(group);
    }
    for (final group in groups) {
      final selected = _availableItems
          .where((item) => group.selectedKeys.contains(_itemKey(item)))
          .toList();
      await _integrations.addRequest(
        type: widget.stage.title,
        targetAccountId: group.targetAccountId.trim(),
        scope: _scopeForItems(selected),
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request sent to Integrations.')),
    );
  }

  Future<void> _createClone() async {
    final email = _cloneEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan target email yang valid.')),
      );
      return;
    }
    if (_integrations.findRequest(
          type: 'Clone',
          targetAccountId: email,
          scope: const <String, List<String>>{},
        ) !=
        null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clone untuk target ini sudah pernah dibuat.')),
      );
      return;
    }
    await _integrations.addRequest(
      type: 'Clone',
      targetAccountId: email,
      scope: const <String, List<String>>{},
    );
    _cloneEmailController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clone request sent to Integrations.')),
    );
  }

  void _openAuthorizationDetail(
    IntegrationAuthorization item,
    int index,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Detail #' + index.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _LifecycleDataRow(
                  label: 'Status',
                  value: item.status.name,
                ),
                _LifecycleDataRow(
                  label: 'Created',
                  value: _formatDate(item.createdAt),
                ),
                _LifecycleDataRow(label: 'Type', value: item.type),
                _LifecycleDataRow(
                  label: 'Target',
                  value: item.targetAccountId,
                ),
                _LifecycleDataRow(
                  label: 'Data',
                  value: item.scope.values
                      .fold<int>(0, (n, v) => n + v.length)
                      .toString(),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Authorization is managed through Integrations.',
                  style: TextStyle(color: shMuted, height: 1.45),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return value.year.toString() + '-' +
        two(value.month) + '-' +
        two(value.day) + ' ' +
        two(value.hour) + ':' +
        two(value.minute);
  }

  Widget _buildRecovery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LifecycleSectionCard(
          accent: widget.stage.accent,
          title: 'Full SH Snapshot',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recovery stores a FULL snapshot of the current SH.',
                style: TextStyle(color: shMuted, height: 1.5),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _createRecoverySnapshot,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Create Snapshot'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_recoveryHistory.isEmpty)
          _LifecycleSectionCard(
            accent: widget.stage.accent,
            title: 'Recovery History',
            child: const Text(
              'No snapshots yet.',
              style: TextStyle(color: shMuted),
            ),
          )
        else
          ...[
            for (var i = 0; i < _recoveryHistory.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LifecycleSectionCard(
                  accent: widget.stage.accent,
                  title: 'Snapshot #${i + 1}',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_recoveryDate(_recoveryHistory[i].createdAt)),
                    subtitle: Text(
                      '${_recoveryHistory[i].memoryCount} Memory · '
                      '${_recoveryHistory[i].knowledgeCount} Knowledge · '
                      '${_recoveryHistory[i].experienceCount} Experience · '
                      '${_recoveryHistory[i].fileCount} Files',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openRecoveryDetail(
                      _recoveryHistory[i],
                      i + 1,
                    ),
                  ),
                ),
              ),
          ],
      ],
    );
  }

  Widget _buildClone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LifecycleSectionCard(
          accent: widget.stage.accent,
          title: 'Clone Request',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create a copy of the current Shared Journey for a specific target.',
                style: TextStyle(color: shMuted, height: 1.5),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _cloneEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Target email',
                  hintText: 'name@example.com',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _createClone,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Create Clone Request'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _LifecycleSectionCard(
          accent: widget.stage.accent,
          title: 'Clone Requests',
          child: _cloneResults.isEmpty
              ? const Text(
                  'No clone requests yet.',
                  style: TextStyle(color: shMuted),
                )
              : Column(
                  children: [
                    for (var i = 0; i < _cloneResults.length; i++)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_cloneResults[i].targetAccountId),
                        subtitle: Text(_cloneResults[i].status.name),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _openAuthorizationDetail(
                          _cloneResults[i],
                          i + 1,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildIsl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LifecycleSectionCard(
          accent: widget.stage.accent,
          title: 'Shared Journey Selection',
          child: _availableItems.isEmpty
              ? const Text(
                  'No Shared Journey data available.',
                  style: TextStyle(color: shMuted),
                )
              : Column(
                  children: [
                    for (var groupIndex = 0;
                        groupIndex < _groups.length;
                        groupIndex++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: groupIndex == _groups.length - 1 ? 0 : 18,
                        ),
                        child: _RequestGroupEditor(
                          group: _groups[groupIndex],
                          items: _availableItems,
                          onTargetChanged: (value) =>
                              _setTarget(groupIndex, value),
                          onItemToggle: (item) =>
                              _toggleItem(groupIndex, item),
                          wasAlreadyRequested: (item) => _wasAlreadyRequested(
                            item,
                            _groups[groupIndex].targetAccountId,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _addGroup,
              icon: const Icon(Icons.add),
              label: const Text('Add Target'),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: _request,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Send Request'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _LifecycleSectionCard(
          accent: widget.stage.accent,
          title: '${widget.stage.title} Requests',
          child: _islResults.isEmpty
              ? const Text(
                  'No requests yet.',
                  style: TextStyle(color: shMuted),
                )
              : Column(
                  children: [
                    for (var i = 0; i < _islResults.length; i++)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_islResults[i].targetAccountId),
                        subtitle: Text(_islResults[i].status.name),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _openAuthorizationDetail(
                          _islResults[i],
                          i + 1,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyStage() {
    return _LifecycleSectionCard(
      accent: widget.stage.accent,
      title: widget.stage.title,
      child: const Text(
        'This lifecycle stage is defined in the SH lifecycle model. Operational controls are not yet available here.',
        style: TextStyle(color: shMuted, height: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_storesReady) {
      return const Scaffold(
        backgroundColor: shBackground,
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final stage = widget.stage;
    return Scaffold(
      backgroundColor: shBackground,
      body: Column(
        children: [
          ShTopBar(
            title: stage.title,
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              children: [
                _LifecycleSectionCard(
                  accent: stage.accent,
                  title: stage.title,
                  child: Row(
                    children: [
                      StageIcon(stage: stage, size: 54),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          stage.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: shMuted,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isRecovery) ...[
                  const SizedBox(height: 14),
                  _buildRecovery(),
                ] else if (_isClone) ...[
                  const SizedBox(height: 14),
                  _buildClone(),
                ] else if (_isIsl) ...[
                  const SizedBox(height: 14),
                  _buildIsl(),
                ] else ...[
                  const SizedBox(height: 14),
                  _buildEmptyStage(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyCloneSummary extends StatelessWidget {
  const _JourneyCloneSummary({required this.items});

  final List<JourneyLifecyclePayload> items;

  @override
  Widget build(BuildContext context) {
    final memory = items.where((item) => item.type == 'Memory').length;
    final knowledge = items.where((item) => item.type == 'Knowledge').length;
    final experience = items.where((item) => item.type == 'Experience').length;
    return Row(
      children: [
        _CloneSummaryValue(label: 'Memory', value: memory),
        _CloneSummaryValue(label: 'Knowledge', value: knowledge),
        _CloneSummaryValue(label: 'Experience', value: experience),
      ],
    );
  }
}

class _CloneSummaryValue extends StatelessWidget {
  const _CloneSummaryValue({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: shMuted)),
        ],
      ),
    );
  }
}

class _RequestGroupEditor extends StatelessWidget {
  const _RequestGroupEditor({
    required this.group,
    required this.items,
    required this.onTargetChanged,
    required this.onItemToggle,
    required this.wasAlreadyRequested,
  });

  final _LifecycleRequestGroup group;
  final List<JourneyLifecyclePayload> items;
  final ValueChanged<String> onTargetChanged;
  final ValueChanged<JourneyLifecyclePayload> onItemToggle;
  final bool Function(JourneyLifecyclePayload item) wasAlreadyRequested;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: TextEditingController(text: group.targetAccountId),
          onChanged: onTargetChanged,
          decoration: const InputDecoration(
            labelText: 'Target Account ID',
          ),
        ),
        const SizedBox(height: 10),
        for (final item in items)
          CheckboxListTile(
            value: group.selectedKeys.contains(
              item.semanticSourceId ?? '${item.type}|${item.title}',
            ),
            onChanged: wasAlreadyRequested(item)
                ? null
                : (_) => onItemToggle(item),
            title: Text(item.title),
            subtitle: Text(item.type),
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }
}

class _LifecycleRequestGroup {
  const _LifecycleRequestGroup({
    this.targetAccountId = '',
    this.selectedKeys = const <String>{},
  });

  final String targetAccountId;
  final Set<String> selectedKeys;

  _LifecycleRequestGroup copyWith({
    String? targetAccountId,
    Set<String>? selectedKeys,
  }) {
    return _LifecycleRequestGroup(
      targetAccountId: targetAccountId ?? this.targetAccountId,
      selectedKeys: selectedKeys ?? this.selectedKeys,
    );
  }
}

class _LifecycleSectionCard extends StatelessWidget {
  const _LifecycleSectionCard({
    required this.accent,
    required this.title,
    required this.child,
  });

  final Color accent;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: .32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LifecycleDataRow extends StatelessWidget {
  const _LifecycleDataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: shMuted),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
