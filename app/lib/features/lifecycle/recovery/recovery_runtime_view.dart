import 'package:flutter/material.dart';

import '../../../core/state/sh_profile_state.dart';
import '../../../core/theme/sh_theme.dart';
import '../../journey/journey_runtime_service.dart';
import '../lifecycle_runtime_read_service.dart';

class RecoveryRuntimeView extends StatefulWidget {
  const RecoveryRuntimeView({super.key});

  @override
  State<RecoveryRuntimeView> createState() => _RecoveryRuntimeViewState();
}

class _RecoveryRuntimeViewState extends State<RecoveryRuntimeView> {
  final _read = const LifecycleRuntimeReadService();
  final _runtime = const JourneyRuntimeService();
  List<Map<String, dynamic>> _snapshots = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final rows = await _read.listRecoverySnapshots();
      if (!mounted) return;
      setState(() {
        _snapshots = rows;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createSnapshot() async {
    final shId = profileShId.value.trim();
    if (shId.isEmpty) {
      _show('Recovery blocked: active SH identity is unavailable.');
      return;
    }
    try {
      await _runtime.createRecoverySnapshot(shId: shId);
      await _load();
      _show('Canonical recovery snapshot created.');
    } catch (error) {
      _show('Snapshot creation failed: $error');
    }
  }

  Future<void> _restoreSnapshot(Map<String, dynamic> row) async {
    final id = row['snapshot_id']?.toString().trim() ?? '';
    if (id.isEmpty) {
      _show('Restore blocked: snapshot identity is missing.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore canonical snapshot?'),
        content: const Text(
          'Recovery restore is a runtime mutation of the current SH state. Continue only if this snapshot is the intended recovery point.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _runtime.restoreRecoverySnapshot(snapshotId: id);
      await _load();
      _show('Canonical recovery restore completed.');
    } catch (error) {
      _show('Recovery restore failed: $error');
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _date(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed == null ? '—' : parsed.toLocal().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recovery')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Text(
              'Canonical Recovery',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Recovery state is read from Supabase. Local snapshot files are not treated as the canonical recovery history.',
              style: TextStyle(color: shMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading ? null : _createSnapshot,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create canonical snapshot'),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Text('Recovery read failed: $_error')
            else if (_snapshots.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No canonical recovery snapshots found.'),
              )
            else
              for (final row in _snapshots)
                Card(
                  child: ListTile(
                    title: Text(row['snapshot_kind']?.toString() ?? 'FULL'),
                    subtitle: Text(_date(row['created_at'])),
                    trailing: IconButton(
                      tooltip: 'Restore',
                      icon: const Icon(Icons.restore),
                      onPressed: () => _restoreSnapshot(row),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
