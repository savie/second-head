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
        total += await file.length();
        switch (StorageService.categoryFor(file)) {
          case 'images': images++;
          case 'video': videos++;
          case 'audio': audio++;
          default: documents++;
        }
      }
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      if (!mounted) return;
      setState(() {
        _files = files; _totalBytes = total; _images = images; _videos = videos;
        _audio = audio; _documents = documents; _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _size(int b) {
    if (b < 1024) return b.toString() + ' B';
    if (b < 1024 * 1024) return (b / 1024).toStringAsFixed(1) + ' KB';
    if (b < 1024 * 1024 * 1024) return (b / (1024 * 1024)).toStringAsFixed(1) + ' MB';
    return (b / (1024 * 1024 * 1024)).toStringAsFixed(2) + ' GB';
  }

  Future<void> _openCategory(String category) async {
    final files = _files.where((f) => StorageService.categoryFor(f) == category).toList();
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _DataFilesCategoryView(
        title: category == 'images' ? 'Images' : category == 'video' ? 'Videos' : category == 'audio' ? 'Audio' : 'Documents',
        category: category, files: files, size: _size, onChanged: _refresh,
      ),
    ));
    if (mounted) await _refresh();
  }

  Future<void> _clearLocalFiles() async {
    if (_clearing) return;
    setState(() => _clearing = true);
    try {
      for (final file in await StorageService.listFiles()) { await file.delete(); }
      await RecoverySnapshotStore.instance.refreshFromDisk();
    } finally {
      if (mounted) { setState(() => _clearing = false); await _refresh(); }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(children: [
      ShTopBar(
        title: 'Data & Files',
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [shSurface2, shSurface]),
                        borderRadius: BorderRadius.circular(24), border: Border.all(color: shBorder),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('LOCAL STORAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: shMuted)),
                        const SizedBox(height: 8),
                        Text(_size(_totalBytes), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                        Text(_files.length.toString() + ' file' + (_files.length == 1 ? '' : 's') + ' in SH storage', style: const TextStyle(fontSize: 12, color: shMuted)),
                      ]),
                    ),
                    const SizedBox(height: 18),
                    const DPSectionLabel('BY TYPE'),
                    const SizedBox(height: 8),
                    _DPFileStat(icon: Icons.image_outlined, label: 'Images', count: _images, onTap: () => _openCategory('images')),
                    _DPFileStat(icon: Icons.videocam_outlined, label: 'Videos', count: _videos, onTap: () => _openCategory('video')),
                    _DPFileStat(icon: Icons.graphic_eq_rounded, label: 'Audio', count: _audio, onTap: () => _openCategory('audio')),
                    _DPFileStat(icon: Icons.insert_drive_file_outlined, label: 'Documents', count: _documents, onTap: () => _openCategory('documents')),
                    const SizedBox(height: 18),
                    const DPSectionLabel('FILES'),
                    const SizedBox(height: 8),
                    _DPRecentFiles(files: _files.take(8).toList(), onTap: (file) => _openCategory(StorageService.categoryFor(file))),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _clearing || _files.isEmpty ? null : _clearLocalFiles,
                        child: Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: shBorder)),
                          child: Row(children: [
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(color: shSurface2, borderRadius: BorderRadius.circular(13)),
                              child: _clearing ? const Padding(padding: EdgeInsets.all(11), child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cleaning_services_outlined, size: 20, color: Colors.redAccent),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Clear Local Files', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                              SizedBox(height: 3),
                              Text('Removes files from SH local storage only', style: TextStyle(fontSize: 11, color: shMuted)),
                            ])),
                            const Icon(Icons.chevron_right_rounded, size: 22, color: shMuted),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    ]),
  );
}

class _DPRecentFiles extends StatelessWidget {
  const _DPRecentFiles({required this.files, required this.onTap});
  final List<File> files;
  final ValueChanged<File> onTap;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const DPInfoCard(icon: Icons.folder_open_outlined, title: 'No local files', description: 'Files created or selected by SH will appear here.');
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: files.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (_, index) {
          final file = files[index], category = StorageService.categoryFor(file);
          final isImage = category == 'images';
          final name = file.path.split(Platform.pathSeparator).last;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18), onTap: () => onTap(file),
              child: Container(
                width: 118,
                decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: shBorder)),
                clipBehavior: Clip.antiAlias,
                child: isImage
                    ? Image.file(file, fit: BoxFit.cover)
                    : Stack(children: [
                        Center(child: Icon(category == 'video' ? Icons.videocam_outlined : category == 'audio' ? Icons.graphic_eq_rounded : Icons.insert_drive_file_outlined, size: 34, color: shMuted)),
                        Positioned(left: 10, right: 10, bottom: 8, child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
                      ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DataFilesCategoryView extends StatefulWidget {
  const _DataFilesCategoryView({required this.title, required this.category, required this.files, required this.size, required this.onChanged});
  final String title, category;
  final List<File> files;
  final String Function(int) size;
  final Future<void> Function() onChanged;
  @override State<_DataFilesCategoryView> createState() => _DataFilesCategoryViewState();
}

class _DataFilesCategoryViewState extends State<_DataFilesCategoryView> {
  late List<File> _files = List<File>.from(widget.files);

  Future<void> _delete(File file) async {
    await file.delete();
    if (!mounted) return;
    setState(() => _files.remove(file));
    await widget.onChanged();
  }

  Future<void> _openExternal(File file) async {
    final opened = await launchUrl(Uri.file(file.path), mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada aplikasi yang dapat membuka file ini.'), behavior: SnackBarBehavior.floating));
    }
  }

  void _openImage(File file) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _DPImageViewer(file: file)));
  }

  @override
  Widget build(BuildContext context) {
    final gallery = widget.category == 'images' || widget.category == 'video';
    return Scaffold(
      backgroundColor: shBackground,
      body: Column(children: [
        ShTopBar(
          title: widget.title,
          leading: IconButton(tooltip: 'Back', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded)),
        ),
        Expanded(
          child: _files.isEmpty
              ? const Center(child: DPInfoCard(icon: Icons.folder_open_outlined, title: 'No files', description: 'No local files of this type are currently stored.'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
                  children: [
                    if (gallery)
                      _DPMediaGrid(files: _files, category: widget.category, onTap: widget.category == 'images' ? _openImage : _openExternal)
                    else
                      _DPAttachmentList(files: _files, category: widget.category, size: widget.size, onTap: _openExternal, onDelete: _delete),
                  ],
                ),
        ),
      ]),
    );
  }
}

class _DPMediaGrid extends StatelessWidget {
  const _DPMediaGrid({required this.files, required this.category, required this.onTap});
  final List<File> files;
  final String category;
  final ValueChanged<File> onTap;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
    itemCount: files.length,
    itemBuilder: (_, index) {
      final file = files[index], isImage = category == 'images';
      return Material(
        color: shSurface, borderRadius: BorderRadius.circular(10), clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onTap(file),
          child: isImage
              ? Image.file(file, fit: BoxFit.cover)
              : Stack(alignment: Alignment.center, children: [
                  const Icon(Icons.play_circle_outline_rounded, size: 44),
                  Positioned(left: 6, right: 6, bottom: 6, child: Text(file.path.split(Platform.pathSeparator).last, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))),
                ]),
        ),
      );
    },
  );
}

class _DPImageViewer extends StatelessWidget {
  const _DPImageViewer({required this.file});
  final File file;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(children: [
      ShTopBar(title: 'Image', leading: IconButton(tooltip: 'Back', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded))),
      Expanded(child: Center(child: InteractiveViewer(minScale: .8, maxScale: 4, child: Image.file(file, fit: BoxFit.contain)))),
    ]),
  );
}

class _DPAttachmentList extends StatelessWidget {
  const _DPAttachmentList({required this.files, required this.category, required this.size, required this.onTap, required this.onDelete});
  final List<File> files;
  final String category;
  final String Function(int) size;
  final ValueChanged<File> onTap;
  final ValueChanged<File> onDelete;

  @override
  Widget build(BuildContext context) {
    final icon = category == 'audio' ? Icons.graphic_eq_rounded : Icons.insert_drive_file_outlined;
    return Column(children: [
      for (final file in files)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: shBorder)),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: shSurface2, borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 21, color: shMuted)),
              const SizedBox(width: 12),
              Expanded(child: InkWell(
                onTap: () => onTap(file),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(file.path.split(Platform.pathSeparator).last, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(size(file.statSync().size), style: const TextStyle(fontSize: 11, color: shMuted)),
                ]),
              )),
              IconButton(tooltip: 'Delete', onPressed: () => onDelete(file), icon: const Icon(Icons.delete_outline_rounded, size: 19)),
            ]),
          ),
        ),
    ]);
  }
}

class _DPFileStat extends StatelessWidget {
  const _DPFileStat({required this.icon, required this.label, required this.count, required this.onTap});
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: shSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: shBorder),
        ),
        child: Row(children: [
          Icon(icon, size: 19, color: shMuted),
          const SizedBox(width: 11),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Text(count.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: shMuted)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 20, color: shMuted),
        ]),
      ),
    ),
  );
}
