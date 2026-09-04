import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/navigation/sh_navigation_shell.dart';
import '../../../core/theme/sh_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/storage/recovery_snapshot_store.dart';
import '../../../core/state/sh_profile_state.dart';
import '../../journey/journey_data.dart';
import '../integrations/integration_authorization_store.dart';
import 'data_privacy_widgets.dart';

class DeleteDataView extends StatefulWidget {
  const DeleteDataView();

  @override
  State<DeleteDataView> createState() => _DeleteDataViewState();
}

class DeleteDataViewState extends State<DeleteDataView> {
  bool _localFiles = true;
  bool _busy = false;

  Future<void> _delete() async {
    if (!_localFiles || _busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear app data?'),
        content: const Text('This clears SH app data and cache on this device. Files in SH local storage remain untouched. Your account is not deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      await StorageService.clearApplicationData();
      await JourneyStore.refreshFromDisk();
      await IntegrationAuthorizationStore.instance.refreshFromDisk();
      await RecoverySnapshotStore.instance.refreshFromDisk();
      if (!mounted) return;
      setState(() => _localFiles = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SH app data and cache cleared.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => DPSubPage(
    title: 'Delete Data',
    children: [
      const DPSectionLabel('CLEAR APP DATA'),
      const SizedBox(height: 8),
      const DPInfoCard(
        icon: Icons.delete_outline_rounded,
        title: 'Clear SH app data',
        description: 'This clears SH app data and cache on this device. It does not delete SH local storage files, the SH account, or server-side data.',
        destructive: true,
      ),
      const SizedBox(height: 14),
      const DPSectionLabel('DATA'),
      const SizedBox(height: 8),
      _DPSelectableCard(
        icon: Icons.folder_copy_outlined,
        title: 'App data',
        subtitle: 'Cache and app-owned internal data stored inside the app sandbox',
        selected: _localFiles,
        onTap: _busy ? null : () => setState(() => _localFiles = !_localFiles),
      ),
      const SizedBox(height: 20),
      DPActionCard(
        icon: Icons.delete_outline_rounded,
        title: _busy ? 'Deleting…' : 'Delete Selected Data',
        subtitle: _localFiles ? 'Clear app data and cache' : 'Nothing selected',
        destructive: true,
        onTap: _busy || !_localFiles ? () {} : _delete,
      ),
    ],
  );
}

class _DPSelectableCard extends StatelessWidget {
  const _DPSelectableCard({required this.icon, required this.title, required this.subtitle, required this.selected, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: shSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? shPurple : shBorder, width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: shSurface2, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 21, color: shMuted),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11.5, color: shMuted)),
          ])),
          Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: selected ? shCyan : shMuted, size: 21),
        ]),
      ),
    ),
  );
}
