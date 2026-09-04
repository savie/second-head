import 'dart:convert';

import '../../core/storage/storage_service.dart';
export '../../core/navigation/sh_navigation_shell.dart';

class JourneyItem {
  JourneyItem(
    this.title,
    this.subtitle,
    this.date,
    this.type,
    this.content,
    this.isPrivate, {
    this.semanticSourceId,
  });

  String title;
  String subtitle;
  String date;
  String type;
  String content;
  bool isPrivate;
  final String? semanticSourceId;

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'date': date,
        'type': type,
        'content': content,
        'is_private': isPrivate,
        'semantic_source_id': semanticSourceId,
      };

  factory JourneyItem.fromJson(Map<String, dynamic> json) => JourneyItem(
        (json['title'] as String?) ?? '',
        (json['subtitle'] as String?) ?? '',
        (json['date'] as String?) ?? 'Memory',
        (json['type'] as String?) ?? 'Memory',
        (json['content'] as String?) ?? '',
        json['is_private'] != false,
        semanticSourceId: json['semantic_source_id'] as String?,
      );
}

List<JourneyItem> shJourneyItems = [];

class JourneyStore {
  static bool _loaded = false;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    await refreshFromDisk();
  }

  static Future<void> refreshFromDisk() async {
    final file = await StorageService.journeyItemsFile();
    if (!await file.exists()) {
      shJourneyItems = [];
      _loaded = true;
      return;
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is List) {
        shJourneyItems = [
          for (final raw in decoded)
            if (raw is Map<String, dynamic>) JourneyItem.fromJson(raw),
        ];
      } else {
        shJourneyItems = [];
      }
    } catch (_) {
      shJourneyItems = [];
    }
    _loaded = true;
  }

  static Future<void> persist() async {
    final file = await StorageService.journeyItemsFile();
    await file.writeAsString(
      jsonEncode([for (final item in shJourneyItems) item.toJson()]),
      flush: true,
    );
    _loaded = true;
  }
}
