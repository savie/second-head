import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../journey/journey_runtime_service.dart';
import 'lifecycle_models.dart';
import 'lifecycle_runtime_read_service.dart';
import 'lifecycle_runtime_request_service.dart';
import 'lifecycle_stage.dart';

class LifecycleAuthorityView extends StatefulWidget {
  const LifecycleAuthorityView({super.key, required this.stage, this.incomingItems = const []});

  final LifecycleStage stage;
  final List<JourneyLifecyclePayload> incomingItems;

  @override
  State<LifecycleAuthorityView> createState() => _LifecycleAuthorityViewState();
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
  final _targets = <_TargetDraft>[_TargetDraft()];
  List<Map<String, dynamic>> _records = const [];
  bool _busy = false;

  bool get _isClone => widget.stage.title == 'Clone';
  bool get _isTransfer => widget.stage.title == 'Inheritance' || widget.stage.title == 'Succession';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final target in _targets) target.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final rows = switch (widget.stage.title) {
        'Clone' => await _read.listCloneAgreements(),
        'Inheritance' => await _read.listInheritanceAuthorizations(),
        'Succession' => await _read.listSuccessionRules(),
        _ => const <Map<String, dynamic>>[],
      };
      if (mounted) setState(() => _records = rows);
    } catch (error) {
      if (mounted) _show(error);
    }
  }

  void _addTarget() => setState(() => _targets.add(_TargetDraft()));

  void _removeTarget(int index) {
    if (_targets.length == 1) return;
    final target = _targets.removeAt(index);
    target.dispose();
    setState(() {});
  }

  void _toggle(int index, JourneyLifecyclePayload item) {
    final key = item.semanticSourceId ?? '${item.type}|${item.title}';
    final selected = _targets[index].selected;
    setState(() => selected.contains(key) ? selected.remove(key) : selected.add(key));
  }

  Map<String, dynamic> _scope(_TargetDraft target) {
    final result = <String, List<String>>{};
    for (final item in widget.incomingItems) {
      final key = item.semanticSourceId ?? '${item.type}|${item.title}';
      if (!target.selected.contains(key)) continue;
      final name = switch (item.type.toLowerCase()) {
        'memory' => 'memory_ids',
        'knowledge' => 'knowledge_ids',
        'experience' => 'experience_ids',
        _ => 'journey_event_ids',
      };
      (result[name] ??= <String>[]).add(key);
    }
    return result;
  }

  Future<void> _submit() async {
    if (_busy) return;
    for (final target in _targets) {
      final email = target.email.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        _show(const FormatException('Enter a valid target email.'));
        return;
      }
      if (_isTransfer && target.selected.isEmpty) {
        _show(const StateError('Select at least one shared Journey item.'));
        return;
      }
    }

    setState(() => _busy = true);
    try {
      for (final target in _targets) {
        final email = target.email.text.trim();
        final scope = _scope(target);
        switch (widget.stage.title) {
          case 'Clone':
            await _request.createCloneAgreement(targetEmail: email);
            break;
          case 'Inheritance':
            await _request.createInheritanceAuthorization(targetEmail: email, scope: scope);
            break;
          case 'Succession':
            await _request.createSuccessionRule(targetEmail: email, scope: scope);
            break;
        }
      }
      for (final target in _targets) {
        target.email.clear();
        target.selected.clear();
      }
      await _load();
      if (mounted) _show(SnackBar(content: Text('${widget.stage.title} request created.')));
    } catch (error) {
      if (mounted) _show(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _execute(Map<String, dynamic> record) async {
    final status = record['status']?.toString().toUpperCase() ?? '';
    final id = (record['agreement_id'] ?? record['authorization_id'] ?? record['succession_id'])?.toString();
    final allowed = (_isClone || widget.stage.title == 'Inheritance') ? status == 'APPROVED' : status == 'ACTIVE';
    if (id == null || id.isEmpty || !allowed) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Execute ${widget.stage.title}?'),
        content: const Text('Execution is handled by the canonical runtime authority.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Execute')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      switch (widget.stage.title) {
        case 'Clone':
          await _runtime.createClone(agreementId: id, cloneName: 'Second Head Clone');
          break;
        case 'Inheritance':
          await _runtime.recordInheritance(authorizationId: id);
          break;
        case 'Succession':
          await _runtime.executeSuccession(successionId: id);
          break;
      }
      await _load();
      if (mounted) _show(SnackBar(content: Text('${widget.stage.title} completed.')));
    } catch (error) {
      if (mounted) _show(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _show(Object value) {
    ScaffoldMessenger.of(context).showSnackBar(
      value is SnackBar ? value : SnackBar(content: Text(value.toString())),
    );
  }

  int _count(String type) => widget.incomingItems.where((item) => item.type.toLowerCase() == type).length;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(leading: const BackButton(), title: Text(widget.stage.title)),
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(30, 16, 30, 28),
            children: [
              _card(_hero()),
              const SizedBox(height: 24),
              _card(_target()),
              const SizedBox(height: 24),
              _card(_history()),
            ],
          ),
        ),
      );

  Widget _card(Widget child) => Container(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 30),
        decoration: BoxDecoration(
          color: shSurface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: widget.stage.accent.withValues(alpha: .22), width: 1.2),
          boxShadow: [BoxShadow(color: widget.stage.accent.withValues(alpha: .07), blurRadius: 24)],
        ),
        child: child,
      );

  Widget _hero() => Row(
        children: [
          _StageIcon(stage: widget.stage),
          const SizedBox(width: 24),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.stage.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Text(widget.stage.subtitle, style: const TextStyle(fontSize: 16, color: shMuted, height: 1.45)),
            ]),
          ),
        ],
      );

  Widget _target() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isClone ? 'Target' : 'Target & Incoming from Journey', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          for (var i = 0; i < _targets.length; i++) ...[
            Text('Target ${i + 1}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Text('Email', style: TextStyle(color: shMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: _targets[i].email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline_rounded), hintText: 'Enter target email'),
            ),
            if (_isTransfer) ...[
              const SizedBox(height: 18),
              const Text('Incoming from Journey', style: TextStyle(color: shMuted)),
              const SizedBox(height: 8),
              if (widget.incomingItems.isEmpty)
                const Text('No shared Journey data available.', style: TextStyle(color: shMuted))
              else
                for (final item in widget.incomingItems)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _targets[i].selected.contains(item.semanticSourceId ?? '${item.type}|${item.title}'),
                    onChanged: _busy ? null : (_) => _toggle(i, item),
                    title: Text(item.title),
                    subtitle: Text('${item.type} · ${item.date}'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
            ],
            if (!_isClone && _targets.length > 1)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(onPressed: _busy ? null : () => _removeTarget(i), icon: const Icon(Icons.remove_circle_outline), label: const Text('Remove target')),
              ),
            if (i != _targets.length - 1) const SizedBox(height: 18),
          ],
          if (!_isClone) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: _busy ? null : _addTarget, icon: const Icon(Icons.add_rounded), label: const Text('Add Target')),
          ],
          const SizedBox(height: 20),
          Text(
            _isClone
                ? 'Target email is used for the clone authorization flow. Authorization is handled by Integrations.'
                : 'Request ${widget.stage.title.toLowerCase()} using selected shared Journey context.',
            style: const TextStyle(color: shMuted, height: 1.4),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 68,
            child: FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: Icon(_isClone ? Icons.copy_all_outlined : Icons.send_rounded),
              label: Text(_busy ? 'Submitting…' : _isClone ? 'Create Clone' : 'Request ${widget.stage.title}'),
            ),
          ),
          const SizedBox(height: 22),
          _summary(),
        ],
      );

  Widget _summary() => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
        decoration: BoxDecoration(color: shBackground.withValues(alpha: .48), borderRadius: BorderRadius.circular(22), border: Border.all(color: shBorder)),
        child: Row(children: [
          _summaryValue('Memory', _count('memory')),
          _summaryValue('Knowledge', _count('knowledge')),
          _summaryValue('Experience', _count('experience')),
        ]),
      );

  Widget _summaryValue(String label, int value) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: shMuted)),
        ]),
      );

  Widget _history() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_isClone ? 'Clone Result' : 'Decision History', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 22),
        if (_records.isEmpty)
          Text(_isClone ? 'No clone results yet.' : 'No decisions yet.', style: const TextStyle(color: shMuted, fontSize: 16))
        else
          for (final record in _records) _record(record),
      ]);

  Widget _record(Map<String, dynamic> record) {
    final status = record['status']?.toString() ?? 'UNKNOWN';
    final canExecute = (_isClone || widget.stage.title == 'Inheritance')
        ? status.toUpperCase() == 'APPROVED'
        : status.toUpperCase() == 'ACTIVE';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(status),
        subtitle: Text(record['created_at']?.toString() ?? ''),
        trailing: canExecute ? IconButton(onPressed: _busy ? null : () => _execute(record), icon: const Icon(Icons.play_arrow_rounded)) : null,
      ),
    );
  }
}

class _StageIcon extends StatelessWidget {
  const _StageIcon({required this.stage});
  final LifecycleStage stage;

  @override
  Widget build(BuildContext context) => Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: shBackground.withValues(alpha: .78),
          border: Border.all(color: stage.accent.withValues(alpha: .55), width: 1.6),
          boxShadow: [BoxShadow(color: stage.accent.withValues(alpha: .16), blurRadius: 22, spreadRadius: 2)],
        ),
        alignment: Alignment.center,
        child: Icon(stage.icon, size: 42, color: stage.accent),
      );
}
