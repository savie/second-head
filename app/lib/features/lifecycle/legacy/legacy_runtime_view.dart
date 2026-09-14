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

class _LegacyTarget { _LegacyTarget() : email = TextEditingController(); final TextEditingController email; void dispose() => email.dispose(); }

class _LegacyRuntimeViewState extends State<LegacyRuntimeView> {
  final _read = const LifecycleRuntimeReadService();
  final _runtime = const JourneyRuntimeService();
  final _journey = const JourneyService();
  final _targets = <_LegacyTarget>[_LegacyTarget()];
  List<Map<String, dynamic>> _records = const [];
  List<JourneyBackendRecord> _journeyRecords = const [];
  final _selected = <String>{};
  bool _loading = true, _busy = false;

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { for (final t in _targets) t.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final r = await Future.wait([_read.listLegacyRecords(), _journey.load(limit: 100)]);
      if (!mounted) return;
      setState(() { _records = r[0] as List<Map<String, dynamic>>; _journeyRecords = r[1] as List<JourneyBackendRecord>; _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); _show(e); }
  }

  void _addTarget() => setState(() => _targets.add(_LegacyTarget()));
  void _removeTarget(int i) { if (_targets.length == 1) return; final t = _targets.removeAt(i); t.dispose(); setState(() {}); }

  Future<void> _preserve() async {
    final emails = <String>[];
    for (final target in _targets) {
      final email = target.email.text.trim();
      if (email.isEmpty || !email.contains('@')) { _show('Enter a valid target email.'); return; }
      if (emails.contains(email.toLowerCase())) { _show('Each target email must be unique.'); return; }
      emails.add(email.toLowerCase());
    }
    if (_selected.isEmpty) { _show('Select at least one shared Journey item.'); return; }
    setState(() => _busy = true);
    try {
      for (final email in emails) {
        final scope = <String, dynamic>{'target_email': email, 'journey_event_ids': _selected.toList()};
        await _runtime.preserveSelectedTransferAsLegacy(sourceShId: profileShId.value.trim(), scope: scope);
      }
      for (final t in _targets) t.email.clear();
      _selected.clear(); await _load(); _show('Legacy request completed.');
    } catch (e) { _show('Legacy request failed: $e'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _show(Object m) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m.toString()))); }
  String _date(dynamic v) { final d = DateTime.tryParse(v?.toString() ?? ''); return d == null ? '—' : d.toLocal().toString(); }
  int _count(String type) => _journeyRecords.where((record) => record.eventType.toUpperCase() == type.toUpperCase()).length;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const BackButton(), title: const Text('Legacy')),
    body: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.fromLTRB(30, 16, 30, 28), children: [
      _card(Row(children: [_Icon(), const SizedBox(width: 24), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Legacy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 16), Text(LifecycleStage.legacy.subtitle, style: const TextStyle(fontSize: 16, color: shMuted, height: 1.45))]))])),
      const SizedBox(height: 24),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Target & Incoming from Journey', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 24),
        for (var i = 0; i < _targets.length; i++) ...[
          Text('Target ${i + 1}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)), const SizedBox(height: 12),
          const Text('Email', style: TextStyle(color: shMuted)), const SizedBox(height: 8),
          TextField(controller: _targets[i].email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline_rounded), hintText: 'Enter target email')),
          if (_targets.length > 1) Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: _busy ? null : () => _removeTarget(i), icon: const Icon(Icons.remove_circle_outline), label: const Text('Remove target'))),
          if (i != _targets.length - 1) const SizedBox(height: 16),
        ],
        const SizedBox(height: 10), const Text('Incoming from Journey', style: TextStyle(color: shMuted)), const SizedBox(height: 8),
        if (_loading || _journeyRecords.isEmpty) const Text('No shared Journey data available.', style: TextStyle(color: shMuted))
        else for (final r in _journeyRecords)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _selected.contains(r.eventId),
            onChanged: _busy
                ? null
                : (v) {
                    setState(() {
                      if (v == true) {
                        _selected.add(r.eventId);
                      } else {
                        _selected.remove(r.eventId);
                      }
                    });
                  },
            title: Text(r.eventType),
            subtitle: Text(_date(r.occurredAt)),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        const SizedBox(height: 12), OutlinedButton.icon(onPressed: _busy ? null : _addTarget, icon: const Icon(Icons.add_rounded), label: const Text('Add Target')),
        const SizedBox(height: 20), const Text('Request legacy handling for selected shared Journey context.', style: TextStyle(color: shMuted, height: 1.4)), const SizedBox(height: 18),
        SizedBox(width: double.infinity, height: 68, child: FilledButton.icon(onPressed: _busy ? null : _preserve, icon: const Icon(Icons.send_rounded), label: Text(_busy ? 'Submitting…' : 'Request Legacy')),
        const SizedBox(height: 22),
        Container(padding: const EdgeInsets.fromLTRB(24, 20, 24, 18), decoration: BoxDecoration(color: shBackground.withValues(alpha: .48), borderRadius: BorderRadius.circular(22), border: Border.all(color: shBorder)), child: Row(children: [_summary('Memory', _count('MEMORY')), _summary('Knowledge', _count('KNOWLEDGE')), _summary('Experience', _count('EXPERIENCE'))])),
        const SizedBox(height: 12), const Text('Authentication is handled by Integrations.', style: TextStyle(color: shMuted)),
      ])),
      const SizedBox(height: 24), _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Decision History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 22), if (_loading) const Center(child: CircularProgressIndicator()) else if (_records.isEmpty) const Text('No decisions yet.', style: TextStyle(color: shMuted, fontSize: 16)) else for (final r in _records) Card(child: ListTile(title: Text(r['legacy_type']?.toString() ?? 'LEGACY'), subtitle: Text('${r['status'] ?? 'ACTIVE'} · ${_date(r['created_at'])}')))])),
    ])),
  );

  Widget _summary(String label, int value) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: shMuted))]));

  Widget _card(Widget child) => Container(padding: const EdgeInsets.fromLTRB(32, 28, 32, 30), decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(30), border: Border.all(color: LifecycleStage.legacy.accent.withValues(alpha: .22), width: 1.2), boxShadow: [BoxShadow(color: LifecycleStage.legacy.accent.withValues(alpha: .07), blurRadius: 24)]), child: child);
}

class _Icon extends StatelessWidget {
  @override Widget build(BuildContext context) => Container(width: 88, height: 88, decoration: BoxDecoration(shape: BoxShape.circle, color: shBackground.withValues(alpha: .78), border: Border.all(color: LifecycleStage.legacy.accent.withValues(alpha: .55), width: 1.6), boxShadow: [BoxShadow(color: LifecycleStage.legacy.accent.withValues(alpha: .16), blurRadius: 22, spreadRadius: 2)]), alignment: Alignment.center, child: Icon(LifecycleStage.legacy.icon, size: 42, color: LifecycleStage.legacy.accent));
}
