import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import 'lifecycle_models.dart';
import 'lifecycle_runtime_read_service.dart';
import 'lifecycle_runtime_request_service.dart';

class LifecycleAuthorityView extends StatefulWidget {
  const LifecycleAuthorityView({super.key, required this.stage});
  final LifecycleStage stage;

  @override
  State<LifecycleAuthorityView> createState() => _LifecycleAuthorityViewState();
}

class _LifecycleAuthorityViewState extends State<LifecycleAuthorityView> {
  final _read = const LifecycleRuntimeReadService();
  final _request = const LifecycleRuntimeRequestService();
  final _targetEmail = TextEditingController();
  final _targetAccountId = TextEditingController();
  final _targetShId = TextEditingController();
  final _scope = TextEditingController();
  bool _busy = false;
  List<Map<String, dynamic>> _records = const [];

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() {
    _targetEmail.dispose(); _targetAccountId.dispose(); _targetShId.dispose(); _scope.dispose(); super.dispose();
  }

  Future<void> _load() async {
    try {
      final records = switch (widget.stage.title) {
        'Clone' => await _read.listCloneAgreements(),
        'Inheritance' => await _read.listInheritanceAuthorizations(),
        'Succession' => await _read.listSuccessionRules(),
        _ => const <Map<String, dynamic>>[],
      };
      if (mounted) setState(() => _records = records);
    } catch (error) { if (mounted) _showError(error); }
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final scope = _parseScope();
      switch (widget.stage.title) {
        case 'Clone':
          await _request.createCloneAgreement(targetEmail: _targetEmail.text, scope: scope);
          break;
        case 'Inheritance':
          await _request.createInheritanceAuthorization(targetAccountId: _targetAccountId.text, targetShId: _targetShId.text, scope: scope);
          break;
        case 'Succession':
          await _request.createSuccessionRule(successorAccountId: _targetAccountId.text, scope: scope);
          break;
      }
      _targetEmail.clear(); _targetAccountId.clear(); _targetShId.clear(); _scope.clear();
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Canonical lifecycle request created.')));
    } catch (error) { if (mounted) _showError(error); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Map<String, dynamic> _parseScope() {
    final raw = _scope.text.trim();
    if (raw.isEmpty) return const <String, dynamic>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) throw const FormatException('Scope must be a JSON object.');
    return Map<String, dynamic>.from(decoded);
  }

  void _showError(Object error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));

  @override
  Widget build(BuildContext context) {
    final isClone = widget.stage.title == 'Clone';
    final isInheritance = widget.stage.title == 'Inheritance';
    return Scaffold(
      appBar: AppBar(title: Text(widget.stage.title)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(widget.stage.subtitle, style: const TextStyle(color: shMuted)),
            const SizedBox(height: 20),
            if (isClone) TextField(controller: _targetEmail, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Target email')),
            if (!isClone) TextField(controller: _targetAccountId, decoration: const InputDecoration(labelText: 'Target account UUID')),
            if (isInheritance) ...[
              const SizedBox(height: 12),
              TextField(controller: _targetShId, decoration: const InputDecoration(labelText: 'Target SH UUID')),
            ],
            const SizedBox(height: 12),
            TextField(controller: _scope, maxLines: 3, decoration: const InputDecoration(labelText: 'Scope JSON (optional)', hintText: '{}')),
            const SizedBox(height: 16),
            FilledButton(onPressed: _busy ? null : _submit, child: Text(_busy ? 'Submitting…' : 'Create canonical request')),
            const SizedBox(height: 28),
            const Text('Canonical records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            if (_records.isEmpty) const Text('No records visible for the current identity.'),
            for (final record in _records) Card(child: ListTile(title: Text(_recordTitle(record)), subtitle: Text(_recordSubtitle(record)))),
          ],
        ),
      ),
    );
  }

  String _recordTitle(Map<String, dynamic> record) => '${record['status'] ?? 'UNKNOWN'} • ${record['agreement_id'] ?? record['authorization_id'] ?? record['succession_id'] ?? ''}';

  String _recordSubtitle(Map<String, dynamic> record) {
    if (widget.stage.title == 'Clone') return 'Target: ${record['target_email'] ?? record['target_account_id'] ?? 'unresolved'}';
    if (widget.stage.title == 'Inheritance') return 'Target account: ${record['target_account_id'] ?? ''} • Target SH: ${record['target_sh_id'] ?? ''}';
    return 'Successor account: ${record['successor_account_id'] ?? ''}';
  }
}
