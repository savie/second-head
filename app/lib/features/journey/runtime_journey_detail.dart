import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import 'journey_runtime_service.dart';

class RuntimeJourneyDetail extends StatefulWidget {
  const RuntimeJourneyDetail({super.key, required this.domain, required this.recordId, required this.title, required this.content, required this.isPrivate, required this.onChanged});

  final String domain;
  final String recordId;
  final String title;
  final String content;
  final bool isPrivate;
  final VoidCallback onChanged;

  @override
  State<RuntimeJourneyDetail> createState() => _RuntimeJourneyDetailState();
}

class _RuntimeJourneyDetailState extends State<RuntimeJourneyDetail> {
  final _runtime = const JourneyRuntimeService();
  late bool _isPrivate;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _isPrivate = widget.isPrivate;
  }

  Future<void> _setPolicy(bool privateOnly) async {
    if (_busy || _isPrivate == privateOnly) return;
    setState(() => _busy = true);
    try {
      final scope = privateOnly ? 'PRIVATE' : 'GENERAL';
      final visibility = privateOnly ? 'OWNER_ONLY' : 'SHARED';
      switch (widget.domain) {
        case 'MEMORY':
          await _runtime.classifyMemory(memoryId: widget.recordId, scope: scope, visibility: visibility);
        case 'KNOWLEDGE':
          await _runtime.classifyKnowledge(knowledgeId: widget.recordId, scope: scope, visibility: visibility);
        case 'EXPERIENCE':
          await _runtime.classifyExperience(experienceId: widget.recordId, scope: scope, visibility: visibility);
        default:
          throw StateError('Unsupported canonical Journey domain: ${widget.domain}');
      }
      if (!mounted) return;
      setState(() => _isPrivate = privateOnly);
      widget.onChanged();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(privateOnly ? 'Policy changed to Owner Only.' : 'Policy changed to Shared.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Policy update failed: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(children: [
      AppBar(leading: const BackButton(), title: Text(widget.domain == 'LEARNING' ? 'Knowledge' : widget.domain.substring(0, 1) + widget.domain.substring(1).toLowerCase())),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: shBorder)), child: Text(widget.content, style: const TextStyle(fontSize: 12, height: 1.5))),
        const SizedBox(height: 20),
        const Text('Policy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _PolicyOption(label: 'Owner Only', icon: Icons.lock_outline, selected: _isPrivate, enabled: !_busy, onTap: () => _setPolicy(true))),
          const SizedBox(width: 10),
          Expanded(child: _PolicyOption(label: 'Shared', icon: Icons.public, selected: !_isPrivate, enabled: !_busy, onTap: () => _setPolicy(false))),
        ]),
      ]))),
    ]),
  );
}

class _PolicyOption extends StatelessWidget {
  const _PolicyOption({required this.label, required this.icon, required this.selected, required this.enabled, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
      decoration: BoxDecoration(color: selected ? shPurple.withValues(alpha: .13) : shSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? shPurple : shBorder)),
      child: Row(children: [Icon(icon, size: 19), const SizedBox(width: 8), Expanded(child: Text(label, style: const TextStyle(fontSize: 12))), if (selected) const Icon(Icons.check_rounded, size: 17)]),
    ),
  );
}
