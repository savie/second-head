import 'package:flutter/material.dart';

import '../../core/state/sh_profile_state.dart';
import '../../core/theme/sh_theme.dart';
import 'journey_runtime_service.dart';
import 'journey_service.dart';
import 'semantic_domain_view.dart';

class SemanticRuntimeDomainView extends StatefulWidget {
  const SemanticRuntimeDomainView({super.key, required this.domain});
  final ShSemanticDomain domain;
  @override
  State<SemanticRuntimeDomainView> createState() => _SemanticRuntimeDomainViewState();
}

class _SemanticRuntimeDomainViewState extends State<SemanticRuntimeDomainView> {
  static const _runtime = JourneyRuntimeService();
  bool _loading = true;
  String? _error;
  List<JourneyBackendRecord> _records = const [];

  String get _eventType => switch (widget.domain) {
        ShSemanticDomain.memory => 'MEMORY',
        ShSemanticDomain.knowledge => 'LEARNING',
        ShSemanticDomain.experience => 'EXPERIENCE',
      };

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final records = await const JourneyService().load(limit: 100);
      if (!mounted) return;
      setState(() {
        _records = records.where((r) {
          if (r.eventType.toUpperCase() != _eventType) return false;
          if (widget.domain == ShSemanticDomain.knowledge) {
            return r.payload['knowledge_id']?.toString().trim().isNotEmpty == true;
          }
          return true;
        }).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  String? _recordId(JourneyBackendRecord record) {
    final key = switch (widget.domain) {
      ShSemanticDomain.memory => 'memory_id',
      ShSemanticDomain.knowledge => 'knowledge_id',
      ShSemanticDomain.experience => 'experience_id',
    };
    final value = record.payload[key]?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  String _content(JourneyBackendRecord record) => record.payload['content']?.toString().trim() ?? '';

  Future<void> _create() async {
    final draft = await _editor('Create ${widget.domain.label}');
    if (!mounted || draft == null) return;
    final shId = profileShId.value.trim();
    if (shId.isEmpty) { _showError('Active SH identity is unavailable.'); return; }
    try {
      switch (widget.domain) {
        case ShSemanticDomain.memory:
          await _runtime.createMemory(shId: shId, content: draft.content, scope: draft.scope, visibility: draft.visibility);
        case ShSemanticDomain.knowledge:
          await _runtime.createKnowledgeCandidate(shId: shId, content: draft.content, scope: draft.scope, visibility: draft.visibility);
        case ShSemanticDomain.experience:
          await _runtime.createExperience(shId: shId, content: draft.content, scope: draft.scope, visibility: draft.visibility);
      }
      await _load();
    } catch (e) { _showError(e.toString()); }
  }

  Future<void> _edit(JourneyBackendRecord record) async {
    final id = _recordId(record);
    final content = _content(record);
    if (id == null || content.isEmpty) { _showError('This Journey record has no editable canonical record identity.'); return; }
    if (widget.domain == ShSemanticDomain.knowledge) {
      final lifecycle = record.payload['lifecycle']?.toString().trim();
      if (lifecycle == null || lifecycle.isEmpty) {
        _showError('Knowledge edit is blocked because canonical lifecycle evidence is unavailable.');
        return;
      }
    }
    final draft = await _editor('Edit ${widget.domain.label}', initialContent: content);
    if (!mounted || draft == null) return;
    try {
      switch (widget.domain) {
        case ShSemanticDomain.memory:
          await _runtime.replaceMemory(shId: profileShId.value, newContent: draft.content, oldPattern: content, scope: draft.scope, visibility: draft.visibility);
        case ShSemanticDomain.knowledge:
          final lifecycle = record.payload['lifecycle']!.toString();
          await _runtime.updateKnowledge(knowledgeId: id, expectedLifecycle: lifecycle, operationKey: 'journey-ui-update-$id-${DateTime.now().microsecondsSinceEpoch}', updateRef: 'journey-ui-edit', successorContent: draft.content);
        case ShSemanticDomain.experience:
          _showError('Experience update runtime authority is not available yet; no local mutation was performed.');
          return;
      }
      await _load();
    } catch (e) { _showError(e.toString()); }
  }

  Future<void> _delete(JourneyBackendRecord record) async {
    final id = _recordId(record);
    if (id == null) { _showError('This Journey record has no canonical record identity.'); return; }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text('Delete ${widget.domain.label}?'),
        content: const Text('This deletes the canonical record through the runtime authority and its linked Journey projection.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _runtime.deleteRecordWithJourney(domain: widget.domain.name.toUpperCase(), recordId: id);
      await _load();
    } catch (e) { _showError(e.toString()); }
  }

  Future<_RuntimeDraft?> _editor(String title, {String initialContent = ''}) async {
    final controller = TextEditingController(text: initialContent);
    var privateOnly = true;
    final result = await showModalBottomSheet<_RuntimeDraft>(
      context: context, isScrollControlled: true, backgroundColor: shSurface, showDragHandle: true,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(18, 8, 18, MediaQuery.viewInsetsOf(sheet).bottom + 18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(controller: controller, minLines: 4, maxLines: 8, autofocus: true, decoration: const InputDecoration(hintText: 'Content')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ChoiceChip(label: const Text('Owner Only'), selected: privateOnly, onSelected: (_) => setSheetState(() => privateOnly = true))),
              const SizedBox(width: 10),
              Expanded(child: ChoiceChip(label: const Text('Shared'), selected: !privateOnly, onSelected: (_) => setSheetState(() => privateOnly = false))),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheet), child: const Text('Cancel'))),
              const SizedBox(width: 10),
              Expanded(child: FilledButton(onPressed: () { final content = controller.text.trim(); if (content.isEmpty) return; Navigator.pop(sheet, _RuntimeDraft(content: content, scope: privateOnly ? 'PRIVATE' : 'GENERAL', visibility: privateOnly ? 'OWNER_ONLY' : 'SHARED')); }, child: const Text('Save'))),
            ]),
          ]),
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  void _showError(String message) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
      appBar: AppBar(title: Text(widget.domain.label)),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: const TextStyle(color: shMuted)))) : _records.isEmpty ? const Center(child: Text('No canonical records yet.', style: TextStyle(color: shMuted))) : RefreshIndicator(onRefresh: _load, child: ListView.separated(padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), itemCount: _records.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, index) { final record = _records[index]; final content = _content(record); return Card(color: shSurface, child: ListTile(leading: Icon(widget.domain.icon, color: shPurple), title: Text(content.isEmpty ? 'Untitled record' : content, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text('${record.continuityStatus} · ${record.occurredAt.toLocal()}'), onTap: () => _edit(record), trailing: PopupMenuButton<String>(onSelected: (value) { if (value == 'edit') _edit(record); if (value == 'delete') _delete(record); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))]))); })),
      floatingActionButton: FloatingActionButton(onPressed: _create, child: const Icon(Icons.add)),
    );
  }
}

class _RuntimeDraft {
  const _RuntimeDraft({required this.content, required this.scope, required this.visibility});
  final String content;
  final String scope;
  final String visibility;
}
