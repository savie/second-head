import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../journey/journey_runtime_service.dart';
import '../journey/journey_service.dart';
import 'lifecycle_models.dart';
import 'lifecycle_runtime_read_service.dart';
import 'lifecycle_runtime_request_service.dart';
import 'lifecycle_stage.dart';

class LifecycleAuthorityView extends StatefulWidget {
  const LifecycleAuthorityView({super.key, required this.stage, this.incomingItems = const []});
  final LifecycleStage stage;
  final List<JourneyLifecyclePayload> incomingItems;
  @override State<LifecycleAuthorityView> createState() => _LifecycleAuthorityViewState();
}

class _TargetDraft {
  _TargetDraft() : email = TextEditingController();
  final TextEditingController email;
  final Set<String> selected = <String>{};
  void dispose() => email.dispose();
}

class _LifecycleAuthorityViewState extends State<LifecycleAuthorityView> {
  final _read = const LifecycleRuntimeReadService();
  final _request = const LifecycleRuntimeRequestService();
  final _runtime = const JourneyRuntimeService();
  final _journey = const JourneyService();
  final _targets = <_TargetDraft>[_TargetDraft()];
  List<Map<String, dynamic>> _records = const [];
  List<JourneyLifecyclePayload> _journeyItems = const [];
  bool _busy = false;
  bool get _isClone => widget.stage.title == 'Clone';
  bool get _isTransfer => widget.stage.title == 'Inheritance' || widget.stage.title == 'Succession';
  bool get _hasJourneyChecklist => _isClone || _isTransfer;

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { for (final t in _targets) t.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final rows = await Future.wait([
        switch (widget.stage.title) {
          'Clone' => _read.listCloneAgreements(),
          'Inheritance' => _read.listInheritanceAuthorizations(),
          'Succession' => _read.listSuccessionRules(),
          _ => const <Map<String, dynamic>>[],
        },
        _journey.load(limit: 100),
      ]);
      final journeyRecords = rows[1] as List<JourneyBackendRecord>;
      final incoming = widget.incomingItems.isNotEmpty
          ? widget.incomingItems
          : [
              for (final record in journeyRecords)
                if (record.eventId.isNotEmpty && record.eventType.isNotEmpty)
                  JourneyLifecyclePayload(
                    title: record.payload['title']?.toString().trim().isNotEmpty == true
                        ? record.payload['title'].toString()
                        : record.eventType,
                    type: switch (record.eventType.toUpperCase()) {
                      'EXPERIENCE' => 'Experience',
                      'KNOWLEDGE' => 'Knowledge',
                      'MEMORY' => 'Memory',
                      _ => record.eventType,
                    },
                    content: record.payload['content']?.toString() ?? '',
                    isPrivate: record.payload['visibility']?.toString().toUpperCase() == 'PRIVATE',
                    date: record.occurredAt.toLocal().toString(),
                    semanticSourceId: record.payload['memory_id']?.toString()
                        ?? record.payload['knowledge_id']?.toString()
                        ?? record.payload['experience_id']?.toString()
                        ?? record.eventId,
                  ),
            ];
      if (mounted) setState(() { _records = rows[0] as List<Map<String, dynamic>>; _journeyItems = incoming; });
    } catch (error) { if (mounted) _show(error); }
  }

  void _show(Object value) => ScaffoldMessenger.of(context).showSnackBar(value is SnackBar ? value : SnackBar(content: Text(value.toString())));
  void _addTarget() => setState(() => _targets.add(_TargetDraft()));
  void _removeTarget(int i) { if (_targets.length == 1) return; final t = _targets.removeAt(i); t.dispose(); setState(() {}); }
  void _toggle(int i, JourneyLifecyclePayload item) {
    final key = item.semanticSourceId ?? '${item.type}|${item.title}';
    setState(() => _targets[i].selected.contains(key) ? _targets[i].selected.remove(key) : _targets[i].selected.add(key));
  }

  Map<String, dynamic> _scope(_TargetDraft target) {
    final out = <String, List<String>>{};
    for (final item in _journeyItems) {
      final key = item.semanticSourceId ?? '${item.type}|${item.title}';
      if (!target.selected.contains(key)) continue;
      final name = switch (item.type.toLowerCase()) {'memory' => 'memory_ids', 'knowledge' => 'knowledge_ids', 'experience' => 'experience_ids', _ => 'journey_event_ids'};
      (out[name] ??= <String>[]).add(key);
    }
    return out;
  }

  Future<void> _submit() async {
    if (_busy) return;
    for (final target in _targets) {
      final email = target.email.text.trim();
      if (email.isEmpty || !email.contains('@')) { _show(FormatException('Enter a valid target email.')); return; }
      if (_isTransfer && target.selected.isEmpty) { _show(StateError('Select at least one shared Journey item.')); return; }
    }
    setState(() => _busy = true);
    try {
      for (final target in _targets) {
        final email = target.email.text.trim();
        final scope = _scope(target);
        switch (widget.stage.title) {
          case 'Clone': await _request.createCloneAgreement(targetEmail: email); break;
          case 'Inheritance': await _request.createInheritanceAuthorization(targetEmail: email, scope: scope); break;
          case 'Succession': await _request.createSuccessionRule(targetEmail: email, scope: scope); break;
        }
      }
      for (final target in _targets) { target.email.clear(); target.selected.clear(); }
      await _load();
      if (mounted) _show(SnackBar(content: Text('${widget.stage.title} request created.')));
    } catch (error) { if (mounted) _show(error); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _execute(Map<String, dynamic> record) async {
    final status = record['status']?.toString().toUpperCase() ?? '';
    final id = (record['agreement_id'] ?? record['authorization_id'] ?? record['succession_id'])?.toString();
    final allowed = (_isClone || widget.stage.title == 'Inheritance') ? status == 'APPROVED' : status == 'ACTIVE';
    if (id == null || id.isEmpty || !allowed) return;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: Text('Execute ${widget.stage.title}?'), content: const Text('Execution is handled by the canonical runtime authority.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Execute'))]));
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      switch (widget.stage.title) {
        case 'Clone': await _runtime.createClone(agreementId: id, cloneName: 'Second Head Clone'); break;
        case 'Inheritance': await _runtime.recordInheritance(authorizationId: id); break;
        case 'Succession': await _runtime.executeSuccession(successionId: id); break;
      }
      await _load();
      if (mounted) _show(SnackBar(content: Text('${widget.stage.title} completed.')));
    } catch (error) { if (mounted) _show(error); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  int _count(String type) => _journeyItems.where((item) => item.type.toLowerCase() == type).length;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(leading: const BackButton(), title: Text(widget.stage.title)), body: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.fromLTRB(30, 16, 30, 28), children: [_card(_hero()), const SizedBox(height: 24), _card(_target()), const SizedBox(height: 24), _card(_history())])));

  Widget _card(Widget child) => Container(padding: const EdgeInsets.fromLTRB(32, 28, 32, 30), decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(30), border: Border.all(color: widget.stage.accent.withValues(alpha: .22), width: 1.2), boxShadow: [BoxShadow(color: widget.stage.accent.withValues(alpha: .07), blurRadius: 24)]), child: child);

  Widget _hero() => Row(children: [_StageIcon(stage: widget.stage), const SizedBox(width: 24), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.stage.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 16), Text(widget.stage.subtitle, style: const TextStyle(fontSize: 16, color: shMuted, height: 1.45))]))]);

  Widget _target() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(_isClone ? 'Target & Journey' : 'Target & Incoming from Journey', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 24),
    for (var i = 0; i < _targets.length; i++) ...[
      Text('Target ${i + 1}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)), const SizedBox(height: 12), const Text('Email', style: TextStyle(color: shMuted)), const SizedBox(height: 8),
      TextField(controller: _targets[i].email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline_rounded), hintText: 'Enter target email')),
      if (_hasJourneyChecklist) ...[
        const SizedBox(height: 18), Text(_isClone ? 'Shared Journey' : 'Incoming from Journey', style: const TextStyle(color: shMuted)), const SizedBox(height: 8),
        if (_journeyItems.isEmpty) const Text('No shared Journey data available.', style: TextStyle(color: shMuted))
        else for (final item in _journeyItems) CheckboxListTile(contentPadding: EdgeInsets.zero, value: _isClone ? true : _targets[i].selected.contains(item.semanticSourceId ?? '${item.type}|${item.title}'), onChanged: _busy || _isClone ? null : (_) => _toggle(i, item), title: Text(item.title), subtitle: Text('${item.type} · ${item.date}'), controlAffinity: ListTileControlAffinity.leading),
      ],
      if (!_isClone && _targets.length > 1) Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: _busy ? null : () => _removeTarget(i), icon: const Icon(Icons.remove_circle_outline), label: const Text('Remove target'))),
      if (i != _targets.length - 1) const SizedBox(height: 18),
    ],
    if (!_isClone) ...[const SizedBox(height: 12), OutlinedButton.icon(onPressed: _busy ? null : _addTarget, icon: const Icon(Icons.add_rounded), label: const Text('Add Target'))],
    const SizedBox(height: 20), Text(_isClone ? 'Target email is used for the clone authorization flow. Authorization is handled by Integrations.' : 'Request ${widget.stage.title.toLowerCase()} using selected shared Journey context.', style: const TextStyle(color: shMuted, height: 1.4)), const SizedBox(height: 18),
    SizedBox(width: double.infinity, height: 68, child: FilledButton.icon(onPressed: _busy ? null : _submit, icon: Icon(_isClone ? Icons.copy_all_outlined : Icons.send_rounded), label: Text(_busy ? 'Submitting…' : _isClone ? 'Create Clone' : 'Request ${widget.stage.title}'))), const SizedBox(height: 22),
    Container(padding: const EdgeInsets.fromLTRB(24, 20, 24, 18), decoration: BoxDecoration(color: shBackground.withValues(alpha: .48), borderRadius: BorderRadius.circular(22), border: Border.all(color: shBorder)), child: Row(children: [_summary('Memory', _count('memory')), _summary('Knowledge', _count('knowledge')), _summary('Experience', _count('experience'))])),
  ]);

  Widget _summary(String label, int value) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: shMuted))]));

  Widget _history() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_isClone ? 'Clone Result' : 'Decision History', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 22), if (_records.isEmpty) Text(_isClone ? 'No clone results yet.' : 'No decisions yet.', style: const TextStyle(color: shMuted, fontSize: 16)) else for (final r in _records) Card(child: ListTile(title: Text(r['status']?.toString() ?? 'UNKNOWN'), subtitle: Text(r['created_at']?.toString() ?? ''), trailing: ((_isClone || widget.stage.title == 'Inheritance') ? r['status']?.toString().toUpperCase() == 'APPROVED' : r['status']?.toString().toUpperCase() == 'ACTIVE') ? IconButton(icon: const Icon(Icons.play_arrow_rounded), onPressed: _busy ? null : () => _execute(r)) : null))]);
}

class _StageIcon extends StatelessWidget {
  const _StageIcon({required this.stage});
  final LifecycleStage stage;
  @override Widget build(BuildContext context) => Container(width: 88, height: 88, decoration: BoxDecoration(shape: BoxShape.circle, color: shBackground.withValues(alpha: .78), border: Border.all(color: stage.accent.withValues(alpha: .55), width: 1.6), boxShadow: [BoxShadow(color: stage.accent.withValues(alpha: .16), blurRadius: 22, spreadRadius: 2)]), alignment: Alignment.center, child: Icon(stage.icon, size: 42, color: stage.accent));
}
