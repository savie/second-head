import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/navigation/sh_navigation_shell.dart';
import '../../../core/theme/sh_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/storage/recovery_snapshot_store.dart';
import '../../../core/state/sh_profile_state.dart';
import '../../journey/journey_data.dart';
import 'data_privacy_widgets.dart';

class ExportDataView extends StatefulWidget {
  const ExportDataView();

  @override
  State<ExportDataView> createState() => _ExportDataViewState();
}

class ExportDataViewState extends State<ExportDataView> {
  bool _loading = true;
  List<RecoverySnapshot> _snapshots = [];
  final Map<String, File> _filesById = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loading) _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final files = await StorageService.listRecoverySnapshotFiles();
    final snapshots = <RecoverySnapshot>[];
    _filesById.clear();
    for (final file in files) {
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map<String, dynamic>) {
          final snapshot = RecoverySnapshot.fromJson(decoded);
          snapshots.add(snapshot);
          _filesById[snapshot.id] = file;
        }
      } catch (_) {}
    }
    snapshots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (mounted) setState(() { _snapshots = snapshots; _loading = false; });
  }

  String _date(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
  }

  String _summary(RecoverySnapshot snapshot) {
    final parts = <String>[];
    if (snapshot.memoryCount > 0) parts.add('${snapshot.memoryCount} Memory');
    if (snapshot.knowledgeCount > 0) parts.add('${snapshot.knowledgeCount} Knowledge');
    if (snapshot.experienceCount > 0) parts.add('${snapshot.experienceCount} Experience');
    if (snapshot.fileCount > 0) parts.add('${snapshot.fileCount} Files');
    return parts.isEmpty ? 'FULL SH snapshot' : parts.join(' · ');
  }

  Future<void> _deleteSnapshot(RecoverySnapshot snapshot) async {
    await RecoverySnapshotStore.instance.deleteSnapshot(snapshot.id);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recovery snapshot deleted from local storage.')),
    );
  }

  Future<void> _shareSnapshot(BuildContext sheetContext, RecoverySnapshot snapshot) async {
    final file = _filesById[snapshot.id];
    if (file == null || !await file.exists()) {
      if (mounted) {
        Navigator.of(sheetContext).pop();
        await _load();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Snapshot file is no longer available.')));
      }
      return;
    }
    Navigator.of(sheetContext).pop();
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'SECOND HEAD Recovery Snapshot',
      text: 'SECOND HEAD Recovery Snapshot: ${snapshot.id}',
    );
  }

  void _openSnapshot(RecoverySnapshot snapshot, int index) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Snapshot #${index + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(snapshot.id, style: const TextStyle(fontSize: 11, color: shMuted)),
                const SizedBox(height: 18),
                _DataExportRow(label: 'Type', value: snapshot.type),
                _DataExportRow(label: 'Created', value: _date(snapshot.createdAt)),
                _DataExportRow(label: 'File', value: _filesById[snapshot.id]?.path.split(Platform.pathSeparator).last ?? 'Unavailable'),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _deleteSnapshot(snapshot);
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _shareSnapshot(sheetContext, snapshot),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share Snapshot'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DPSubPage(
    title: 'Export Data',
    children: [
      const DPSectionLabel('RECOVERY SNAPSHOTS'),
      const SizedBox(height: 8),
      const DPInfoCard(
        icon: Icons.share_outlined,
        title: 'Share existing snapshots',
        description: 'Export reads Recovery snapshot files already stored locally. Sharing opens the device share sheet; no second export copy is created.',
      ),
      const SizedBox(height: 14),
      if (_loading)
        const Padding(padding: EdgeInsets.symmetric(vertical: 34), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
      else if (_snapshots.isEmpty)
        const DPInfoCard(icon: Icons.folder_open_outlined, title: 'No recovery snapshots', description: 'Create a snapshot in Recovery first.')
      else
        for (var i = 0; i < _snapshots.length; i++) ...[
          _RecoveredSnapshotCard(
            snapshot: _snapshots[i],
            index: i + 1,
            summary: _summary(_snapshots[i]),
            date: _date(_snapshots[i].createdAt),
            onTap: () => _openSnapshot(_snapshots[i], i),
          ),
          if (i != _snapshots.length - 1) const SizedBox(height: 10),
        ],
    ],
  );
}

class _RecoveredSnapshotCard extends StatelessWidget {
  const _RecoveredSnapshotCard({
    required this.snapshot,
    required this.index,
    required this.summary,
    required this.date,
    required this.onTap,
  });

  final RecoverySnapshot snapshot;
  final int index;
  final String summary;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 14, 12, 14),
            decoration: BoxDecoration(
              color: shSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: shBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: shSurface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: shCyan.withValues(alpha: .22)),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 21,
                    color: shCyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#$index  ${snapshot.type} Snapshot',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: shMuted),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10.5, color: shMuted),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        date,
                        style: const TextStyle(fontSize: 9.5, color: shMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 22, color: shMuted),
              ],
            ),
          ),
        ),
      );
}

class _DataExportRow extends StatelessWidget {
  const _DataExportRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              child: Text(label, style: const TextStyle(fontSize: 11, color: shMuted)),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}
