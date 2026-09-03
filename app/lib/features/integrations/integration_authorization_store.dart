import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/storage/storage_service.dart';

enum IntegrationAuthorizationStatus {
  pending,
  approved,
  rejected,
  revoked,
}

class IntegrationAuthorization {
  IntegrationAuthorization({
    required this.id,
    required this.type,
    required this.sourceShId,
    required this.targetAccountId,
    required this.scope,
    required this.createdAt,
    this.status = IntegrationAuthorizationStatus.pending,
    this.incoming = false,
  });

  final String id;
  final String type;
  final String sourceShId;
  final String targetAccountId;
  final Map<String, List<String>> scope;
  final DateTime createdAt;
  final bool incoming;
  IntegrationAuthorizationStatus status;
}

class IntegrationAuthorizationStore extends ChangeNotifier {
  IntegrationAuthorizationStore._();

  static final instance = IntegrationAuthorizationStore._();

  final List<IntegrationAuthorization> _items = [];
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final file = await StorageService.integrationAuthorizationsFile();
    if (await file.exists()) {
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is List) {
          _items
            ..clear()
            ..addAll([
              for (final raw in decoded)
                if (raw is Map<String, dynamic>)
                  IntegrationAuthorization(
                    id: raw['id'] as String,
                    type: raw['type'] as String,
                    sourceShId: raw['source_sh_id'] as String? ?? 'Current SH',
                    targetAccountId: raw['target_account_id'] as String,
                    scope: {
                      for (final entry in (raw['scope'] as Map<String, dynamic>? ?? {}).entries)
                        entry.key: List<String>.from(entry.value as List? ?? const []),
                    },
                    createdAt: DateTime.parse(raw['created_at'] as String),
                    status: IntegrationAuthorizationStatus.values.firstWhere(
                      (value) => value.name == raw['status'],
                      orElse: () => IntegrationAuthorizationStatus.pending,
                    ),
                    incoming: raw['incoming'] == true,
                  ),
            ]);
      } catch (_) {
        _items.clear();
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final file = await StorageService.integrationAuthorizationsFile();
    await file.writeAsString(jsonEncode([
      for (final item in _items)
        {
          'id': item.id,
          'type': item.type,
          'source_sh_id': item.sourceShId,
          'target_account_id': item.targetAccountId,
          'scope': item.scope,
          'created_at': item.createdAt.toIso8601String(),
          'status': item.status.name,
          'incoming': item.incoming,
        },
    ]), flush: true);
  }

  List<IntegrationAuthorization> get items => List.unmodifiable(_items);

  List<IntegrationAuthorization> get pending => List.unmodifiable(
        _items.where(
          (item) => item.status == IntegrationAuthorizationStatus.pending,
        ),
      );

  List<IntegrationAuthorization> get authorized => List.unmodifiable(
        _items.where(
          (item) => item.status == IntegrationAuthorizationStatus.approved,
        ),
      );

  String addRequest({
    required String type,
    required String targetAccountId,
    required Map<String, List<String>> scope,
  }) {
    final id = 'frontend-auth-${DateTime.now().microsecondsSinceEpoch}';
    _items.insert(
      0,
      IntegrationAuthorization(
        id: id,
        type: type,
        sourceShId: 'Current SH',
        targetAccountId: targetAccountId,
        scope: {
          for (final entry in scope.entries)
            entry.key: List.unmodifiable(entry.value),
        },
        createdAt: DateTime.now(),
      ),
    );
    _persist();
    notifyListeners();
    return id;
  }

  void approve(String id) {
    final item = _find(id);
    if (item == null) return;
    item.status = IntegrationAuthorizationStatus.approved;
    _persist();
    notifyListeners();
  }

  void reject(String id) {
    final item = _find(id);
    if (item == null) return;
    item.status = IntegrationAuthorizationStatus.rejected;
    _persist();
    notifyListeners();
  }

  void revoke(String id) {
    final item = _find(id);
    if (item == null) return;
    item.status = IntegrationAuthorizationStatus.revoked;
    _persist();
    notifyListeners();
  }

  IntegrationAuthorization? _find(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
