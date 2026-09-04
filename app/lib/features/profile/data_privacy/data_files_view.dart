import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/navigation/sh_navigation_shell.dart';
import '../../../core/theme/sh_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/storage/recovery_snapshot_store.dart';
import 'data_privacy_widgets.dart';

class DataFilesView extends StatefulWidget {
  const DataFilesView();
  @override
  State<DataFilesView> createState() => DataFilesViewState();
}

class DataFilesViewState extends State<DataFilesView> {
  bool _loading = true, _clearing = false;
  int _totalBytes = 0, _images = 0, _videos = 0, _audio = 0, _documents = 0;
  List<File> _files = [];

  @override
  void initState() { super.initState(); _refresh(); }

  Future<void> _refresh() async {
    if (mounted) setState(() => _loading = true);
    try {
      final files = await StorageService.listFiles(includeExports: true);
      int total = 0, images = 0, videos = 0, audio = 0, documents = 0;
      for (final file in files) {
        final size = await file.length();
        total += size;
        final ext = file.path.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
          images++;
        } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
          videos++;
        } else if (['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(ext)) {
          audio++;
        } else {
          documents++;
        }
      }
      if (!mounted) return;
      setState(() {
        _files = files;
        _totalBytes = total;
        _images = images;
        _videos = videos;
        _audio = audio;
        _documents = documents;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _clearAll() async {
    if (_clearing) return;
    setState(() => _clearing = true);
    try {
      await StorageService.clearFiles();
      await RecoverySnapshotStore.clear();
    } finally {
      if (mounted) setState(() => _clearing = false);
      await _refresh();
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
      body: Column(
        children: [
          const ShTopBar(title: 'Data Files'),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        DPStatCard(
                          title: 'Storage Used',
                          value: _formatBytes(_totalBytes),
                          icon: Icons.storage_outlined,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: DPStatCard(title: 'Images', value: '$_images', icon: Icons.image_outlined)),
                            const SizedBox(width: 8),
                            Expanded(child: DPStatCard(title: 'Videos', value: '$_videos', icon: Icons.video_library_outlined)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: DPStatCard(title: 'Audio', value: '$_audio', icon: Icons.audiotrack_outlined)),
                            const SizedBox(width: 8),
                            Expanded(child: DPStatCard(title: 'Documents', value: '$_documents', icon: Icons.description_outlined)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (_files.isEmpty)
                          const DPEmptyState(
                            icon: Icons.folder_open_outlined,
                            title: 'No files',
                            message: 'There are no stored data files.',
                          )
                        else
                          ..._files.map(
                            (file) => DPFileTile(
                              file: file,
                              onOpen: () async {
                                final uri = Uri.file(file.path);
                                await launchUrl(uri);
                              },
                            ),
                          ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: _clearing ? null : _clearAll,
                          icon: const Icon(Icons.delete_outline),
                          label: Text(_clearing ? 'Clearing...' : 'Clear Stored Files'),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
