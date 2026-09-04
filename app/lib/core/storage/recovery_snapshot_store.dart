import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'storage_service.dart';

class RecoverySnapshot {
  const RecoverySnapshot({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.memoryCount,
    required this.knowledgeCount,
    required this.experienceCount,
    required this.fileCount,
    this.isDemo = false,
  });

  final String id;
  final DateTime createdAt;
  final String type;
  final int memoryCount;
  final int knowledgeCount;
  final int experienceCount;
  final int fileCount;
  final bool isDemo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'type': type,
        'memory_count': memoryCount,
        'knowledge_count': knowledgeCount,
        'experience_count': experienceCount,
        'file_count': fileCount,
        'is_demo': isDemo,
      };

  factory RecoverySnapshot.fromJson(Map<String, dynamic> json) => RecoverySnapshot(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        type: (json['type'] as String?) ?? 'FULL',
        memoryCount: (json['memory_count'] as num?)?.toInt() ?? 0,
        knowledgeCount: (json['knowledge_count'] as num?)?.toInt() ?? 0,
        experienceCount: (json['experience_count'] as num?)?.toInt() ?? 0,
        fileCount: (json['file_count'] as num?)?.toInt() ?? 0,
        isDemo: json['is_demo'] == true,
      );
}

class RecoverySnapshotStore extends ChangeNotifier {
  RecoverySnapshotStore._();

  static final instance = RecoverySnapshotStore._();

  List<RecoverySnapshot> _items = [];
  bool _loaded = false;

  List<RecoverySnapshot> get items => List.unmodifiable(_items);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final files = await StorageService.listRecoverySnapshotFiles();
    final loaded = <RecoverySnapshot>[];
    for (final file in files) {
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map<String, dynamic>) {
          loaded.add(RecoverySnapshot.fromJson(decoded));
        }
      } catch (_) {}
    }
    loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _items = loaded;
    _loaded = true;
    notifyListeners();
  }

  Future<void> refreshFromDisk() async {
    _loaded = false;
    await ensureLoaded();
  }

  Future<void> deleteSnapshot(String id) async {
    await ensureLoaded();
    final files = await StorageService.listRecoverySnapshotFiles();
    for (final file in files) {
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map<String, dynamic> && decoded['id'] == id) {
          await file.delete();
        }
      } catch (_) {}
    }
    await refreshFromDisk();
  }

  Future<RecoverySnapshot> createSnapshot() async {
    var createdAt = DateTime.now();
    var file = await StorageService.recoverySnapshotFileFor(createdAt);

    // The canonical filename has second precision. Never overwrite an
    // existing physical snapshot when two creates happen in the same second.
    while (await file.exists()) {
      createdAt = createdAt.add(const Duration(seconds: 1));
      file = await StorageService.recoverySnapshotFileFor(createdAt);
    }

    final persistentFiles = await StorageService.listPersistentFilesForRecovery();

    var memoryCount = 0;
    var knowledgeCount = 0;
    var experienceCount = 0;
    for (final entry in persistentFiles) {
      if (entry['path'] != 'internal/journey_items.json') continue;
      try {
        final decoded = jsonDecode(
          utf8.decode(base64Decode(entry['bytes_base64'] as String)),
        );
        if (decoded is List) {
          for (final item in decoded) {
            if (item is! Map<String, dynamic>) continue;
            switch (item['type']) {
              case 'Memory':
                memoryCount++;
              case 'Knowledge':
                knowledgeCount++;
              case 'Experience':
                experienceCount++;
            }
          }
        }
      } catch (_) {}
    }

    final snapshot = RecoverySnapshot(
      id: 'SH-${createdAt.year.toString().padLeft(4, '0')}-'
          '${createdAt.month.toString().padLeft(2, '0')}-'
          '${createdAt.day.toString().padLeft(2, '0')}-'
          '${createdAt.microsecondsSinceEpoch.toString().substring(9)}',
      createdAt: createdAt,
      type: 'FULL',
      memoryCount: memoryCount,
      knowledgeCount: knowledgeCount,
      experienceCount: experienceCount,
      fileCount: persistentFiles.length,
    );
    await file.writeAsString(
      jsonEncode({
        ...snapshot.toJson(),
        'state_version': 2,
        'persistent_files': persistentFiles,
      }),
      flush: true,
    );

    final recoveryFiles = await StorageService.listRecoverySnapshotFiles();
    for (final oldFile in recoveryFiles.skip(3)) {
      await oldFile.delete();
    }
    await refreshFromDisk();
    return snapshot;
  }

  Future<void> restoreSnapshot(RecoverySnapshot snapshot) async {
    final files = await StorageService.listRecoverySnapshotFiles();
    File? snapshotFile;
    for (final candidate in files) {
      try {
        final decoded = jsonDecode(await candidate.readAsString());
        if (decoded is Map<String, dynamic> && decoded['id'] == snapshot.id) {
          snapshotFile = candidate;
          break;
        }
      } catch (_) {}
    }
    if (snapshotFile == null) {
      throw StateError('Recovery snapshot file not found: ${snapshot.id}');
    }

    final decoded = jsonDecode(await snapshotFile.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid recovery snapshot payload.');
    }
    final entries = decoded['persistent_files'];
    if (entries is! List) {
      throw const FormatException('Recovery snapshot has no full state payload.');
    }

    final externalRoot = await StorageService.root();
    final internalRoot = await StorageService.internalRoot();
    final snapshotExternalPaths = <String>{};
    final snapshotInternalPaths = <String>{};

    for (final raw in entries) {
      if (raw is! Map<String, dynamic>) continue;
      final storedPath = raw['path'];
      final encoded = raw['bytes_base64'];
      if (storedPath is! String || encoded is! String) continue;

      Directory base;
      String relativePath;
      Set<String> pathSet;
      if (storedPath.startsWith('internal/')) {
        base = internalRoot;
        relativePath = storedPath.substring('internal/'.length);
        pathSet = snapshotInternalPaths;
      } else if (storedPath.startsWith('external/')) {
        base = externalRoot;
        relativePath = storedPath.substring('external/'.length);
        pathSet = snapshotExternalPaths;
      } else if (storedPath.startsWith('temp/')) {
        // Compatibility with snapshots created before the storage-boundary
        // migration: legacy temp data now belongs to internal app data.
        base = internalRoot;
        relativePath = storedPath;
        pathSet = snapshotInternalPaths;
      } else {
        base = externalRoot;
        relativePath = storedPath;
        pathSet = snapshotExternalPaths;
      }

      if (relativePath.startsWith('exports/') ||
          relativePath == 'exports') {
        continue;
      }

      pathSet.add(relativePath);
      final target = File('${base.path}/$relativePath');
      await target.parent.create(recursive: true);
      await target.writeAsBytes(base64Decode(encoded), flush: true);
    }

    Future<void> removeFilesNotInSnapshot(
      Directory base,
      Set<String> keep,
    ) async {
      if (!await base.exists()) return;
      await for (final entity in base.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final relativePath = entity.path.substring(base.path.length + 1);
        if (relativePath.startsWith('exports/')) continue;
        if (!keep.contains(relativePath)) {
          await entity.delete();
        }
      }
    }

    await removeFilesNotInSnapshot(externalRoot, snapshotExternalPaths);
    await removeFilesNotInSnapshot(internalRoot, snapshotInternalPaths);
    await refreshFromDisk();
  }
}
