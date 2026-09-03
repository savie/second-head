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
    final file = await StorageService.recoverySnapshotsFile();
    if (await file.exists()) {
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is List) {
          _items = [
            for (final item in decoded)
              if (item is Map<String, dynamic>) RecoverySnapshot.fromJson(item),
          ];
        }
      } catch (_) {
        _items = const [];
      }
    }

    if (_items.isEmpty) {
      _items = [
        RecoverySnapshot(
          id: 'SH-2026-09-03-001',
          createdAt: DateTime(2026, 9, 3, 10, 30),
          type: 'FULL',
          memoryCount: 3,
          knowledgeCount: 4,
          experienceCount: 2,
          fileCount: 5,
          isDemo: true,
        ),
        RecoverySnapshot(
          id: 'SH-2026-08-30-001',
          createdAt: DateTime(2026, 8, 30, 16, 20),
          type: 'FULL',
          memoryCount: 2,
          knowledgeCount: 3,
          experienceCount: 1,
          fileCount: 4,
          isDemo: true,
        ),
      ];
    }

    _loaded = true;
    notifyListeners();
  }

  Future<RecoverySnapshot> createSnapshot() async {
    await ensureLoaded();
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
    _items = [snapshot, ..._items.where((item) => !item.isDemo)];
    await _persist();
    notifyListeners();
    return snapshot;
  }

  Future<void> _persist() async {
    final file = await StorageService.recoverySnapshotsFile();
    await file.writeAsString(
      jsonEncode(_items.where((item) => !item.isDemo).map((item) => item.toJson()).toList()),
      flush: true,
    );
  }
}
