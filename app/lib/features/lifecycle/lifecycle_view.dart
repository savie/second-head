import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../journey/journey_data.dart';
import '../../core/navigation/sh_navigation_shell.dart';
import '../integrations/integration_authorization_store.dart';
import '../integrations/integrations_view.dart';

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
      ),
      const LifecycleStage(
        'Recovery',
        'Restore Second Head data, memories, or state from a backup.',
        Icons.shield_moon_outlined,
        Color(0xFF3B82F6),
      ),
      const LifecycleStage(
        'Inheritance',
        'Pass memories, knowledge, and values to the next generation.',
        Icons.account_tree_outlined,
        Color(0xFF22D3EE),
      ),
      const LifecycleStage(
        'Succession',
        'Prepare and manage the transition of Second Head ownership or stewardship.',
        Icons.people_outline_rounded,
        Color(0xFF6366F1),
      ),
      const LifecycleStage(
        'Legacy',
        'Manage a meaningful digital legacy for the long term.',
        Icons.menu_book_rounded,
        Color(0xFFF59E0B),
      ),
      const LifecycleStage(
        'End of Life',
        'Handle the closure, deletion, or safe and respectful handover of Second Head.',
        Icons.favorite_border_rounded,
        Color(0xFFEC4899),
      ),
    ];

    final q = query.trim().toLowerCase();
    final visible = stages
        .where(
          (s) => q.isEmpty ||
              '${s.title} ${s.subtitle}'.toLowerCase().contains(q),
        )
        .toList();

    if (visible.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: shSurface.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: shBorder),
        ),
        child: const Center(
          child: Text(
            'Tidak ada tahap lifecycle yang cocok.',
            style: TextStyle(fontSize: 15, color: shMuted),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 330;

        if (!wide) {
          return _MobileLifecycle(
            stages: visible,
            onStageTap: onStageTap,
          );
        }

        return _WideLifecycle(
          stages: visible,
          onStageTap: onStageTap,
        );
      },
    );
  }
}

class _WideLifecycle extends StatelessWidget {
  const _WideLifecycle({
    required this.stages,
    required this.onStageTap,
  });

  final List<LifecycleStage> stages;
  final ValueChanged<LifecycleStage> onStageTap;

  @override
  Widget build(BuildContext context) {
    final ordered = List<LifecycleStage>.generate(
      6,
      (index) => index < stages.length ? stages[index] : LifecycleStage.empty,
    );

    final width = MediaQuery.sizeOf(context).width - 20;
    final cardWidth = width * .47;
    final cardHeight = 204.0;

    return SizedBox(
      height: 650,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < 6; i++)
            if (ordered[i] != LifecycleStage.empty)
              Positioned(
                left: i.isEven ? 8 : null,
                right: i.isOdd ? 8 : null,
                top: switch (i) {
                  0 || 1 => 8,
                  2 || 3 => 220,
                  _ => 432,
                },
                width: cardWidth,
                height: cardHeight,
                child: LifecycleCard(
                  stage: ordered[i],
                  onTap: () => onStageTap(ordered[i]),
                ),
              ),
        ],
      ),
    );
  }
}

class _MobileLifecycle extends StatelessWidget {
  const _MobileLifecycle({
    required this.stages,
    required this.onStageTap,
  });

  final List<LifecycleStage> stages;
  final ValueChanged<LifecycleStage> onStageTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          SizedBox(
            height: 220,
            child: LifecycleCard(
              stage: stages[i],
              onTap: () => onStageTap(stages[i]),
            ),
          ),
        ],
      ],
    );
  }
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

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}

class LifecycleCard extends StatelessWidget {
  const LifecycleCard({
    super.key,
    required this.stage,
    required this.onTap,
  });

  final LifecycleStage stage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OrganicCardPainter(accent: stage.accent),
      child: ClipPath(
        clipper: _OrganicCardClipper(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StageIcon(stage: stage, size: 50),
                  const SizedBox(height: 8),
                  Text(
                    stage.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      height: 1.1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stage.subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: shMuted,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 21,
                    color: stage.accent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StageIcon extends StatelessWidget {
  const _StageIcon({required this.stage, required this.size});

  final LifecycleStage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: shBackground.withValues(alpha: .78),
        border: Border.all(
          color: stage.accent.withValues(alpha: .42),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: stage.accent.withValues(alpha: .14),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(stage.icon, size: size * .46, color: stage.accent),
    );
  }
}

class _OrganicCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(24, 0)
      ..lineTo(size.width - 64, 0)
      ..quadraticBezierTo(size.width - 12, 2, size.width - 4, 30)
      ..lineTo(size.width, size.height - 54)
      ..quadraticBezierTo(
        size.width - 2,
        size.height - 8,
        size.width - 48,
        size.height - 4,
      )
      ..lineTo(54, size.height)
      ..quadraticBezierTo(4, size.height - 3, 2, size.height - 48)
      ..lineTo(0, 46)
      ..quadraticBezierTo(2, 4, 24, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _OrganicCardClipper oldClipper) => false;
}

class _OrganicCardPainter extends CustomPainter {
  _OrganicCardPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _OrganicCardClipper().getClip(size);
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: .12),
          shSurface.withValues(alpha: .96),
          accent.withValues(alpha: .08),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, fill);

    final border = Paint()
      ..color = accent.withValues(alpha: .78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _OrganicCardPainter oldDelegate) =>
      oldDelegate.accent != accent;
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
  final List<_LifecycleDecision> _history = [];
  final TextEditingController _cloneEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    IntegrationAuthorizationStore.instance.addListener(_onAuthorizationChanged);
  }

  void _onAuthorizationChanged() {
    if (mounted) setState(() {});
  }

  bool get _isRecovery => widget.stage.title == 'Recovery';

  String _recoveryDate(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return value.year.toString() + '-' + two(value.month) + '-' +
        two(value.day) + ' ' + two(value.hour) + ':' + two(value.minute);
  }

  void _createRecoverySnapshot() {
    setState(() {
      _history.insert(0, _LifecycleDecision(
        status: 'Snapshot Created',
        createdAt: DateTime.now(),
        groups: const [],
        detail: 'FULL SH snapshot prepared. Restore is available from snapshot detail.',
      ));
    });
  }

  void _restoreRecovery(_LifecycleDecision decision) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Snapshot?'),
        content: Text(
          'This will restore the selected FULL snapshot to your current SH.\n\n' +
          'Created: ' + _recoveryDate(decision.createdAt),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _history.insert(0, _LifecycleDecision(
                  status: 'Restored',
                  createdAt: DateTime.now(),
                  groups: const [],
                  detail: 'Outcome: RESTORED · Continuity: RECOVERED.',
                ));
              });
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _openRecoveryDetail(_LifecycleDecision decision, int index) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recovery Detail #' + index.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                _LifecycleDataRow(label: 'Type', value: 'FULL'),
                _LifecycleDataRow(label: 'Status', value: decision.status),
                _LifecycleDataRow(label: 'Created', value: _recoveryDate(decision.createdAt)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _restoreRecovery(decision);
                    },
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Restore Snapshot'),
                  ),
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

  Map<String, List<String>> _scopeForGroup(_LifecycleRequestGroup group) {
    final scope = <String, List<String>>{
      'memory_ids': <String>[],
      'knowledge_ids': <String>[],
      'experience_ids': <String>[],
      'journey_event_ids': <String>[],
    };

    for (final item in _availableItems) {
      if (!group.selectedKeys.contains(_itemKey(item))) continue;
      final id = item.semanticSourceId ?? _itemKey(item);
      final key = switch (item.type.toLowerCase()) {
        'memory' => 'memory_ids',
        'knowledge' => 'knowledge_ids',
        'experience' => 'experience_ids',
        _ => 'journey_event_ids',
      };
      scope[key]!.add(id);
    }

    return scope;
  }

  List<IntegrationAuthorization> get _islAuthorizations =>
      IntegrationAuthorizationStore.instance.items.where(
        (item) =>
            item.type == widget.stage.title &&
            (item.type == 'Inheritance' ||
                item.type == 'Succession' ||
                item.type == 'Legacy'),
      ).toList();

  String _authorizationStatus(IntegrationAuthorization item) {
    switch (item.status) {
      case IntegrationAuthorizationStatus.pending:
        return 'Waiting for Approval';
      case IntegrationAuthorizationStatus.approved:
        return 'Approved';
      case IntegrationAuthorizationStatus.rejected:
        return 'Rejected';
      case IntegrationAuthorizationStatus.revoked:
        return 'Revoked';
    }
  }

  Set<String> _requestedKeysForTarget(String target) {
    final normalizedTarget = target.trim();
    if (normalizedTarget.isEmpty) return <String>{};
    final keys = <String>{};
    for (final decision in _history) {
      for (final group in decision.groups) {
        if (group.targetAccountId.trim() == normalizedTarget) {
          keys.addAll(group.selectedKeys);
        }
      }
    }
    return keys;
  }

  bool _wasAlreadyRequested(JourneyLifecyclePayload item, String target) =>
      _requestedKeysForTarget(target).contains(_itemKey(item));

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

  void _request() {
    final groups = <_LifecycleRequestGroup>[];
    for (final group in _groups) {
      final target = group.targetAccountId.trim();
      if (target.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan Target Account ID untuk setiap target.')),
        );
        return;
      }
      if (group.selectedKeys.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih minimal satu data Journey untuk setiap target.')),
        );
        return;
      }
      final previous = _requestedKeysForTarget(target);
      if (group.selectedKeys.any(previous.contains)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sebagian data sudah pernah diminta untuk target ini.')),
        );
        return;
      }
      groups.add(group);
    }

    final immutableGroups = List<_LifecycleRequestGroup>.unmodifiable(groups);
    final integrations = IntegrationAuthorizationStore.instance;
    for (final group in immutableGroups) {
      integrations.addRequest(
        type: widget.stage.title,
        targetAccountId: group.targetAccountId.trim(),
        scope: _scopeForGroup(group),
      );
    }

    setState(() {});
  }

  @override
  void dispose() {
    IntegrationAuthorizationStore.instance.removeListener(_onAuthorizationChanged);
    _cloneEmailController.dispose();
    super.dispose();
  }

  void _createClone() {
    final email = _cloneEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan target email yang valid.')),
      );
      return;
    }

    setState(() {
      _history.insert(
        0,
        _LifecycleDecision(
          status: 'Clone Created',
          createdAt: DateTime.now(),
          groups: [
            _LifecycleRequestGroup(targetAccountId: email),
          ],
          detail:
              'Clone target dikunci berdasarkan email. Authorization ditangani oleh Integrations.',
        ),
      );
      _cloneEmailController.clear();
    });
  }

  void _openAuthorizationDetail(
    IntegrationAuthorization item,
    int index,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.type + ' #' + index.toString(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _LifecycleDataRow(
                  label: 'Status',
                  value: _authorizationStatus(item),
                ),
                _LifecycleDataRow(label: 'Target', value: item.targetAccountId),
                _LifecycleDataRow(label: 'Source', value: item.sourceShId),
                _LifecycleDataRow(
                  label: 'Created',
                  value: _formatDate(item.createdAt),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Selected Journey Data',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 7),
                for (final entry in item.scope.entries)
                  if (entry.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: _LifecycleDataRow(
                        label: entry.key.replaceAll('_ids', ''),
                        value: entry.value.join(', '),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDecision(_LifecycleDecision decision, int index) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Result #$index',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _LifecycleDataRow(label: 'Status', value: decision.status),
                _LifecycleDataRow(
                  label: 'Target',
                  value: decision.groups.first.targetAccountId,
                ),
                _LifecycleDataRow(
                  label: 'Created',
                  value: _formatDate(decision.createdAt),
                ),
                const SizedBox(height: 12),
                const Text('Result', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  decision.detail,
                  style: const TextStyle(fontSize: 13, color: shMuted, height: 1.5),
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
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.stage;
    final availableItems = _availableItems;

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
            actions: [
              IconButton(
                tooltip: 'Integrations',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const IntegrationsView(),
                    ),
                  );
                },
                icon: const Icon(Icons.hub_outlined, size: 24),
              ),
            ],
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
                      _StageIcon(stage: stage, size: 54),
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
                  _LifecycleSectionCard(
                    accent: stage.accent,
                    title: 'Full SH Snapshot',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recovery uses a FULL snapshot of the current SH. No target or per-item selection is required.',
                          style: TextStyle(fontSize: 12, color: shMuted, height: 1.5),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _createRecoverySnapshot,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Create Snapshot'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LifecycleSectionCard(
                    accent: stage.accent,
                    title: 'Recovery History',
                    child: _history.isEmpty
                        ? const Text('No recovery history yet.', style: TextStyle(fontSize: 12, color: shMuted))
                        : Column(
                            children: [
                              for (var i = 0; i < _history.length; i++)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    radius: 15,
                                    child: Text((i + 1).toString(), style: const TextStyle(fontSize: 11)),
                                  ),
                                  title: Text(_history[i].status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                    'Type: FULL · ' + _recoveryDate(_history[i].createdAt),
                                    style: const TextStyle(fontSize: 10, color: shMuted),
                                  ),
                                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                                  onTap: () => _openRecoveryDetail(_history[i], i + 1),
                                ),
                            ],
                          ),
                  ),
                ] else if (_isClone) ...[
                  const SizedBox(height: 14),
                  _LifecycleSectionCard(
                    accent: stage.accent,
                    title: 'Target',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email', style: TextStyle(fontSize: 11, color: shMuted)),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _cloneEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter target email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: shBackground.withValues(alpha: .55),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _createClone,
                            icon: const Icon(Icons.copy_all_outlined),
                            label: const Text('Create Clone'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Target email is used for the clone authorization flow. Authorization is handled by Integrations.',
                          style: TextStyle(fontSize: 10, color: shMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LifecycleSectionCard(
                    accent: stage.accent,
                    title: 'Clone Result',
                    child: _history.isEmpty
                        ? const Text('No clone results yet.', style: TextStyle(fontSize: 12, color: shMuted))
                        : Column(
                            children: [
                              for (var i = 0; i < _history.length; i++)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    radius: 15,
                                    child: Text((i + 1).toString(), style: const TextStyle(fontSize: 11)),
                                  ),
                                  title: Text(
                                    _history[i].status,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'Target: ${_history[i].groups.first.targetAccountId}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10, color: shMuted),
                                  ),
                                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                                  onTap: () => _openDecision(_history[i], i + 1),
                                ),
                            ],
                          ),
                  ),
                ] else if (_isIsl) ...[
                  const SizedBox(height: 14),
                  _LifecycleSectionCard(
                    accent: stage.accent,
                    title: 'Target & Incoming from Journey',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < _groups.length; i++) ...[
                          _RequestGroupEditor(
                            group: _groups[i],
                            groupIndex: i,
                            availableItems: availableItems,
                            onTargetChanged: (value) => _setTarget(i, value),
                            onItemToggle: (item) => _toggleItem(i, item),
                            isItemAlreadyRequested: (item) =>
                                _wasAlreadyRequested(item, _groups[i].targetAccountId),
                            showRemove: _groups.length > 1,
                            onRemove: () => setState(() => _groups.removeAt(i)),
                          ),
                          if (i != _groups.length - 1)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(color: shBorder),
                            ),
                        ],
                        const SizedBox(height: 4),
                        OutlinedButton.icon(
                          onPressed: _addGroup,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Target'),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          switch (stage.title) {
                            'Inheritance' => 'Request transfer of selected shared Journey context.',
                            'Succession' => 'Request succession using selected shared Journey context.',
                            'Legacy' => 'Request legacy handling for selected shared Journey context.',
                            _ => '',
                          },
                          style: const TextStyle(fontSize: 12, color: shMuted, height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _request,
                            icon: const Icon(Icons.send_rounded),
                            label: Text(switch (stage.title) {
                              'Inheritance' => 'Request Inheritance',
                              'Succession' => 'Request Succession',
                              'Legacy' => 'Request Legacy',
                              _ => 'Request',
                            }),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Authentication is handled by Integrations.',
                          style: TextStyle(fontSize: 10, color: shMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LifecycleSectionCard(
                    accent: stage.accent,
                    title: 'Decision History',
                    child: _islAuthorizations.isEmpty
                        ? const Text(
                            'No decisions yet.',
                            style: TextStyle(fontSize: 12, color: shMuted),
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < _islAuthorizations.length; i++)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    radius: 15,
                                    child: Text((i + 1).toString()),
                                  ),
                                  title: Text(
                                    _authorizationStatus(_islAuthorizations[i]),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _islAuthorizations[i].targetAccountId +
                                        ' · ' +
                                        _islAuthorizations[i].scope.values
                                            .fold<int>(
                                              0,
                                              (sum, values) => sum + values.length,
                                            )
                                            .toString() +
                                        ' data',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10, color: shMuted),
                                  ),
                                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                                  onTap: () => _openAuthorizationDetail(
                                    _islAuthorizations[i],
                                    i + 1,
                                  ),
                                ),
                            ],
                          ),
                  ),
                ] else ...[
                  const SizedBox(height: 14),
                  _LifecycleSectionCard(
                    accent: stage.accent,
                    title: 'Lifecycle detail',
                    child: const Text(
                      'This lifecycle detail is intentionally not implemented in this pass.',
                      style: TextStyle(fontSize: 12, color: shMuted, height: 1.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestGroupEditor extends StatelessWidget {
  const _RequestGroupEditor({
    required this.group,
    required this.groupIndex,
    required this.availableItems,
    required this.onTargetChanged,
    required this.onItemToggle,
    required this.isItemAlreadyRequested,
    required this.showRemove,
    required this.onRemove,
  });

  final _LifecycleRequestGroup group;
  final int groupIndex;
  final List<JourneyLifecyclePayload> availableItems;
  final ValueChanged<String> onTargetChanged;
  final ValueChanged<JourneyLifecyclePayload> onItemToggle;
  final bool Function(JourneyLifecyclePayload item) isItemAlreadyRequested;
  final bool showRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Target ${groupIndex + 1}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            if (showRemove)
              IconButton(
                tooltip: 'Remove target',
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 7),
        const Text('Account ID', style: TextStyle(fontSize: 11, color: shMuted)),
        const SizedBox(height: 7),
        TextFormField(
          initialValue: group.targetAccountId,
          onChanged: onTargetChanged,
          decoration: InputDecoration(
            hintText: 'Enter target Account ID',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            filled: true,
            fillColor: shBackground.withValues(alpha: .55),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Incoming from Journey', style: TextStyle(fontSize: 11, color: shMuted)),
        const SizedBox(height: 7),
        if (availableItems.isEmpty)
          const Text('No shared Journey data available.', style: TextStyle(fontSize: 12, color: shMuted))
        else
          for (final item in availableItems)
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: group.selectedKeys.contains(
                item.semanticSourceId ?? '${item.type}|${item.title}',
              ),
              onChanged: isItemAlreadyRequested(item) ? null : (_) => onItemToggle(item),
              title: Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              subtitle: Text(
                isItemAlreadyRequested(item)
                    ? '${item.type} · Already requested for this target'
                    : '${item.type} · Shared',
                style: const TextStyle(fontSize: 10, color: shMuted),
              ),
              controlAffinity: ListTileControlAffinity.leading,
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
  }) =>
      _LifecycleRequestGroup(
        targetAccountId: targetAccountId ?? this.targetAccountId,
        selectedKeys: selectedKeys ?? this.selectedKeys,
      );
}

class _LifecycleDecision {
  const _LifecycleDecision({
    required this.status,
    required this.createdAt,
    required this.groups,
    required this.detail,
  });

  final String status;
  final DateTime createdAt;
  final List<_LifecycleRequestGroup> groups;
  final String detail;

  int get totalDataCount =>
      groups.fold(0, (sum, group) => sum + group.selectedKeys.length);
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: shBorder),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .06),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: shMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
