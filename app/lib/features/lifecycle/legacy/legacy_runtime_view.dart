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

class _LegacyRuntimeViewState extends State<LegacyRuntimeView> {
  final _read = const LifecycleRuntimeReadService();
  final _runtime = const JourneyRuntimeService();
  final _journey = const JourneyService();
  final _targetEmail = TextEditingController();
  List<Map<String, dynamic>> _records = const [];
  List<JourneyBackendRecord> _journeyRecords = const [];
  final _selected = <String>{};
  bool _loading = true;
  bool _busy = false;

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _targetEmail.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final result = await Future.wait([_read.listLegacyRecords(), _journey.load(limit: 100)]);
      if (!mounted) return;
      setState(() { _records = result[0] as List<Map<String, dynamic>>; _journeyRecords = result[1] as List<JourneyBackendRecord>; _loading = false; });
    } catch (error) { if (mounted) setState(() => _loading = false); _show(error); }
  }

  Future<void> _preserve() async {
    final email = _targetEmail.text.trim();
    if (email.isEmpty || !email.contains('@')) { _show('Enter a valid target email.'); return; }
    if (_selected.isEmpty) { _show('Select at least one shared Journey item.'); return; }
    final scope = <String, dynamic>{'target_email': email, 'journey_event_ids': _selected.toList()};
    for (final record in _journeyRecords) {
      if (!_selected.contains(record.eventId)) continue;
      final p = record.payload;
      final memoryId = p['memory_id']?.toString().trim() ?? '';
      final knowledgeId = p['knowledge_id']?.toString().trim() ?? '';
      final experienceId = p['experience_id']?.toString().trim() ?? '';
      if (memoryId.isNotEmpty) (scope['memory_ids'] ??= <String>[]).add(memoryId);
      if (knowledgeId.isNotEmpty) (scope['knowledge_ids'] ??= <String>[]).add(knowledgeId);
      if (experienceId.isNotEmpty) (scope['experience_ids'] ??= <String>[]).add(experienceId);
    }
    setState(() => _busy = true);
    try {
      await _runtime.preserveSelectedTransferAsLegacy(sourceShId: profileShId.value.trim(), scope: scope);
      _targetEmail.clear(); _selected.clear(); await _load(); _show('Legacy request completed.');
    } catch (error) { _show('Legacy request failed: $error'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _show(Object message) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.toString()))); }
  String _date(dynamic value) { final parsed = DateTime.tryParse(value?.toString() ?? ''); return parsed == null ? '—' : parsed.toLocal().toString(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const BackButton(), title: const Text('Legacy')),
    body: RefreshIndicator(
      onRefresh: _load,
      child: ListView(padding: const EdgeInsets.fromLTRB(30, 16, 30, 28), children: [
        _card(Row(children: [_Icon(), const SizedBox(width: 24), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Legacy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 16),
          Text(LifecycleStage.legacy.subtitle, style: const TextStyle(fontSize: 16, color: shMuted, height: 1.45)),
        ]))])),
        const SizedBox(height: 24),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Target & Incoming from Journey', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 24),
          const Text('Target 1', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)), const SizedBox(height: 12),
          const Text('Email', style: TextStyle(color: shMuted)), const SizedBox(height: 8),
          TextField(controller: _targetEmail, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline_rounded), hintText: 'Enter target email')),
          const SizedBox(height: 18), const Text('Incoming from Journey', style: TextStyle(color: shMuted)), const SizedBox(height: 8),
          if (_loading || _journeyRecords.isEmpty) const Text('No shared Journey data available.', style: TextStyle(color: shMuted))
          else for (final record in _journeyRecords) CheckboxListTile(contentPadding: EdgeInsets.zero, value: _selected.contains(record.eventId), onChanged: _busy ? null : (v) => setState(() => v == true ? _selected.add(record.eventId) : _selected.remove(record.eventId)), title: Text(record.eventType), subtitle: Text(_date(record.occurredAt)), controlAffinity: ListTileControlAffinity.leading),
          const SizedBox(height: 12), OutlinedButton.icon(onPressed: _busy ? null : () => _show('Target uses email as the recipient identifier.'), icon: const Icon(Icons.add_rounded), label: const Text('Add Target')),
          const SizedBox(height: 20), const Text('Request legacy handling for selected shared Journey context.', style: TextStyle(color: shMuted, height: 1.4)), const SizedBox(height: 18),
          SizedBox(width: double.infinity, height: 68, child: FilledButton.icon(onPressed: _busy ? null : _preserve, icon: const Icon(Icons.send_rounded), label: Text(_busy ? 'Submitting…' : 'Request Legacy'))),
          const SizedBox(height: 12), const Text('Authentication is handled by Integrations.', style: TextStyle(color: shMuted)),
        ])),
        const SizedBox(height: 24),
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Decision History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 22),
          if (_loading) const Center(child: CircularProgressIndicator())
          else if (_records.isEmpty) const Text('No decisions yet.', style: TextStyle(color: shMuted, fontSize: 16))
          else for (final row in _records) Card(child: ListTile(title: Text(row['legacy_type']?.toString() ?? 'LEGACY'), subtitle: Text('${row['status'] ?? 'ACTIVE'} · ${_date(row['created_at'])}'))),
        ])),
      ]),
    ),
  );

  Widget _card(Widget child) => Container(padding: const EdgeInsets.fromLTRB(32, 28, 32, 30), decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(30), border: Border.all(color: LifecycleStage.legacy.accent.withValues(alpha: .22), width: 1.2), boxShadow: [BoxShadow(color: LifecycleStage.legacy.accent.withValues(alpha: .07), blurRadius: 24)]), child: child);
}

class _Icon extends StatelessWidget {
  @override Widget build(BuildContext context) => Container(width: 88, height: 88, decoration: BoxDecoration(shape: BoxShape.circle, color: shBackground.withValues(alpha: .78), border: Border.all(color: LifecycleStage.legacy.accent.withValues(alpha: .55), width: 1.6), boxShadow: [BoxShadow(color: LifecycleStage.legacy.accent.withValues(alpha: .16), blurRadius: 22, spreadRadius: 2)]), alignment: Alignment.center, child: Icon(LifecycleStage.legacy.icon, size: 42, color: LifecycleStage.legacy.accent));
}
