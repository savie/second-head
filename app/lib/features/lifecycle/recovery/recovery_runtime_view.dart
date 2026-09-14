import 'package:flutter/material.dart';

import '../../../core/state/sh_profile_state.dart';
import '../../../core/theme/sh_theme.dart';
import '../../journey/journey_runtime_service.dart';
import '../lifecycle_stage.dart';
import '../lifecycle_runtime_read_service.dart';

class RecoveryRuntimeView extends StatefulWidget {
  const RecoveryRuntimeView({super.key});
  @override State<RecoveryRuntimeView> createState() => _RecoveryRuntimeViewState();
}

class _RecoveryRuntimeViewState extends State<RecoveryRuntimeView> {
  final _read = const LifecycleRuntimeReadService();
  final _runtime = const JourneyRuntimeService();
  List<Map<String, dynamic>> _snapshots = const [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final rows = await _read.listRecoverySnapshots();
      if (mounted) setState(() { _snapshots = rows; _loading = false; });
    } catch (error) {
      if (mounted) setState(() => _loading = false);
      _show(error);
    }
  }

  Future<void> _createSnapshot() async {
    final shId = profileShId.value.trim();
    if (shId.isEmpty) { _show('Recovery blocked: active SH identity is unavailable.'); return; }
    try {
      await _runtime.createRecoverySnapshot(shId: shId);
      await _load();
      _show('Snapshot created.');
    } catch (error) { _show('Snapshot creation failed: $error'); }
  }

  Future<void> _restore(Map<String, dynamic> row) async {
    final id = row['snapshot_id']?.toString().trim() ?? '';
    if (id.isEmpty) { _show('Restore blocked: snapshot identity is missing.'); return; }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Snapshot?'),
        content: const Text('This will restore the selected FULL snapshot to your current SH.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _runtime.restoreRecoverySnapshot(snapshotId: id);
      await _load();
      _show('Snapshot restored successfully.');
    } catch (error) { _show('Restore failed: $error'); }
  }

  void _show(Object message) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.toString()))); }
  String _date(dynamic value) { final parsed = DateTime.tryParse(value?.toString() ?? ''); return parsed == null ? '—' : parsed.toLocal().toString(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const BackButton(), title: const Text('Recovery')),
    body: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 28), children: [
      _card(Row(children: [_Icon(), const SizedBox(width: 18), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Recovery', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, height: 1.1)), const SizedBox(height: 9), Text(LifecycleStage.recovery.subtitle, style: const TextStyle(fontSize: 13, color: shMuted, height: 1.45))]))])),
      const SizedBox(height: 18),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Full SH Snapshot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)), const SizedBox(height: 15),
        const Text('Recovery uses a FULL snapshot of the current SH. No target or per-item selection is required.', style: TextStyle(fontSize: 13, color: shMuted, height: 1.45)), const SizedBox(height: 18),
        SizedBox(width: double.infinity, height: 48, child: FilledButton.icon(onPressed: _loading ? null : _createSnapshot, icon: const Icon(Icons.camera_alt_outlined, size: 18), label: const Text('Create Snapshot', style: TextStyle(fontSize: 14)))),
      ])),
      const SizedBox(height: 18),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Recovery History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)), const SizedBox(height: 18),
        if (_loading) const Center(child: Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator()))
        else if (_snapshots.isEmpty) const Text('No recovery history yet.', style: TextStyle(color: shMuted, fontSize: 13))
        else for (final row in _snapshots) Card(child: ListTile(title: Text(row['snapshot_kind']?.toString() ?? 'FULL', style: const TextStyle(fontSize: 14)), subtitle: Text(_date(row['created_at']), style: const TextStyle(fontSize: 11, color: shMuted)), trailing: IconButton(icon: const Icon(Icons.restore_rounded, size: 20), onPressed: () => _restore(row)))),
      ])),
    ])),
  );

  Widget _card(Widget child) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: shSurface.withValues(alpha: .72), borderRadius: BorderRadius.circular(24), border: Border.all(color: LifecycleStage.recovery.accent.withValues(alpha: .24))), child: child);
}

class _Icon extends StatelessWidget {
  @override Widget build(BuildContext context) => Container(width: 76, height: 76, decoration: BoxDecoration(shape: BoxShape.circle, color: shBackground, border: Border.all(color: LifecycleStage.recovery.accent.withValues(alpha: .42), width: 1.5), boxShadow: [BoxShadow(color: LifecycleStage.recovery.accent.withValues(alpha: .13), blurRadius: 28, spreadRadius: 4)]), alignment: Alignment.center, child: Icon(LifecycleStage.recovery.icon, size: 34, color: LifecycleStage.recovery.accent));
}
