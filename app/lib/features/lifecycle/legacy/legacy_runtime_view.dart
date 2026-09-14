import 'package:flutter/material.dart';
import '../../../core/state/sh_profile_state.dart';
import '../../../core/theme/sh_theme.dart';
import '../../journey/journey_runtime_service.dart';
import '../../journey/journey_service.dart';
import '../lifecycle_models.dart';
import '../lifecycle_stage.dart';
import '../lifecycle_runtime_read_service.dart';

class LegacyRuntimeView extends StatefulWidget {
  const LegacyRuntimeView({super.key, this.incomingItems = const []});
  final List<JourneyLifecyclePayload> incomingItems;
  @override State<LegacyRuntimeView> createState() => _LegacyRuntimeViewState();
}

class LegacyRuntimeViewState extends State<LegacyRuntimeView> {
  final _read = const LifecycleRuntimeReadService();
  final _runtime = const JourneyRuntimeService();
  final _journey = const JourneyService();
  List<Map<String, dynamic>> _records = const [];
  List<JourneyBackendRecord> _journeyRecords = const [];
  final _selected = <String>{};
  bool _loading = true, _busy = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final r = await Future.wait([_read.listLegacyRecords(), _journey.load(limit: 100)]);
      if (!mounted) return;
      setState(() {
        _records = r[0] as List<Map<String, dynamic>>;
        _journeyRecords = r[1] as List<JourneyBackendRecord>;
        _loading = false;
      });
    } catch (e) { if (mounted) setState(() => _loading = false); _show(e); }
  }

  Future<void> _preserve() async {
    if (_selected.isEmpty) { _show('Select at least one shared Journey item.'); return; }
    final shId = profileShId.value.trim();
    if (shId.isEmpty) { _show('Legacy blocked: active SH identity is unavailable.'); return; }
    setState(() => _busy = true);
    try {
      await _runtime.preserveSelectedTransferAsLegacy(
        sourceShId: shId,
        scope: <String, dynamic>{'journey_event_ids': _selected.toList()},
      );
      _selected.clear();
      await _load();
      _show('Legacy preserved for all SH.');
    } catch (e) { _show('Legacy preservation failed: $e'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _show(Object m) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m.toString()))); }
  String _date(dynamic v) { final d = DateTime.tryParse(v?.toString() ?? ''); return d == null ? '—' : d.toLocal().toString(); }
  List<JourneyBackendRecord> get _sharedRecords => [
    for (final record in _journeyRecords)
      if (record.visibility == 'SHARED' || record.visibility == 'PUBLIC') record,
  ];
  int _count(String type) => _sharedRecords.where((record) => record.eventType.toUpperCase() == type.toUpperCase()).length;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const BackButton(), title: const Text('Legacy')),
    body: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 28), children: [
      _card(Row(children: [_Icon(), const SizedBox(width: 18), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Legacy', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, height: 1.1)), const SizedBox(height: 9), Text(LifecycleStage.legacy.subtitle, style: const TextStyle(fontSize: 13, color: shMuted, height: 1.45))]))])),
      const SizedBox(height: 18),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Journey Heritage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)), const SizedBox(height: 18),
        const Text('Select shared Journey context to preserve as Legacy. Legacy has no target actor and is distributed across all SH.', style: TextStyle(fontSize: 13, color: shMuted, height: 1.45)), const SizedBox(height: 15),
        if (_loading || _sharedRecords.isEmpty) const Text('No shared Journey data available.', style: TextStyle(fontSize: 13, color: shMuted))
        else for (final r in _sharedRecords)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _selected.contains(r.eventId),
            onChanged: _busy ? null : (v) => setState(() => v == true ? _selected.add(r.eventId) : _selected.remove(r.eventId)),
            title: Text(r.eventType, style: const TextStyle(fontSize: 14)),
            subtitle: Text(_date(r.occurredAt), style: const TextStyle(fontSize: 11, color: shMuted)),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        const SizedBox(height: 15),
        _summaryRow(),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, height: 48, child: FilledButton.icon(onPressed: _busy ? null : _preserve, icon: const Icon(Icons.auto_awesome_outlined, size: 18), label: Text(_busy ? 'Preserving…' : 'Preserve Legacy', style: const TextStyle(fontSize: 14)))),
        const SizedBox(height: 12), const Text('Legacy is a shared heritage state, not a target-specific transfer request.', style: TextStyle(fontSize: 12, color: shMuted, height: 1.4)),
      ])),
      const SizedBox(height: 18),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Legacy History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)), const SizedBox(height: 18), if (_loading) const Center(child: CircularProgressIndicator()) else if (_records.isEmpty) const Text('No legacy history yet.', style: TextStyle(color: shMuted, fontSize: 13)) else for (final r in _records) Card(child: ListTile(title: Text(r['legacy_type']?.toString() ?? 'LEGACY', style: const TextStyle(fontSize: 14)), subtitle: Text('${r['status'] ?? 'ACTIVE'} · ${_date(r['created_at'])}', style: const TextStyle(fontSize: 11, color: shMuted))))])),
    ])),
  );

  Widget _summaryRow() => Container(padding: const EdgeInsets.fromLTRB(18, 16, 18, 14), decoration: BoxDecoration(color: shBackground.withValues(alpha: .48), borderRadius: BorderRadius.circular(18), border: Border.all(color: shBorder)), child: Row(children: [_summary('Memory', _count('MEMORY')), _summary('Knowledge', _count('KNOWLEDGE')), _summary('Experience', _count('EXPERIENCE'))]));
  Widget _summary(String label, int value) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)), const SizedBox(height: 3), Text(label, style: const TextStyle(fontSize: 12, color: shMuted))]));
  Widget _card(Widget child) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: shSurface.withValues(alpha: .72), borderRadius: BorderRadius.circular(24), border: Border.all(color: LifecycleStage.legacy.accent.withValues(alpha: .24))), child: child);
}

class _Icon extends StatelessWidget {
  @override Widget build(BuildContext context) => Container(width: 76, height: 76, decoration: BoxDecoration(shape: BoxShape.circle, color: shBackground, border: Border.all(color: LifecycleStage.legacy.accent.withValues(alpha: .42), width: 1.5), boxShadow: [BoxShadow(color: LifecycleStage.legacy.accent.withValues(alpha: .13), blurRadius: 28, spreadRadius: 4)]), alignment: Alignment.center, child: Icon(LifecycleStage.legacy.icon, size: 34, color: LifecycleStage.legacy.accent));
}
