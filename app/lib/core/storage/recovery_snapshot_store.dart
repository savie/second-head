import 'dart:convert';

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
    final now = DateTime.now();
    final snapshot = RecoverySnapshot(
      id: 'SH-${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}-'
          '${now.microsecondsSinceEpoch.toString().substring(9)}',
      createdAt: now,
      type: 'FULL',
      memoryCount: 0,
      knowledgeCount: 0,
      experienceCount: 0,
      fileCount: 0,
    );
    final file = await StorageService.recoverySnapshotFileFor(now);
    await file.writeAsString(jsonEncode(snapshot.toJson()), flush: true);
    await refreshFromDisk();
    return snapshot;
  }

}