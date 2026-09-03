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

  final List<IntegrationAuthorization> _items = <IntegrationAuthorization>[];
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
            ..addAll(decoded.whereType<Map<String, dynamic>>().map(_decode));
        }
      } catch (_) {
        _items.clear();
      }
    }

    _loaded = true;
    notifyListeners();
  }

  IntegrationAuthorization _decode(Map<String, dynamic> raw) {
    final scope = <String, List<String>>{};
    final rawScope = raw['scope'];

    if (rawScope is Map<String, dynamic>) {
      for (final entry in rawScope.entries) {
        if (entry.value is List) {
          scope[entry.key] = List<String>.from(entry.value as List);
        }
      }
    }

    final status = IntegrationAuthorizationStatus.values.firstWhere(
      (value) => value.name == raw['status'],
      orElse: () => IntegrationAuthorizationStatus.pending,
    );

    return IntegrationAuthorization(
      id: raw['id']?.toString() ?? '',
      type: raw['type']?.toString() ?? '',
      sourceShId: raw['source_sh_id']?.toString() ?? 'Current SH',
      targetAccountId: raw['target_account_id']?.toString() ?? '',
      scope: scope,
      createdAt: DateTime.tryParse(raw['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      status: status,
      incoming: raw['incoming'] == true,
    );
  }

  Future<void> _persist() async {
    final file = await StorageService.integrationAuthorizationsFile();
    final payload = <Map<String, dynamic>>[
      for (final item in _items)
        <String, dynamic>{
          'id': item.id,
          'type': item.type,
          'source_sh_id': item.sourceShId,
          'target_account_id': item.targetAccountId,
          'scope': item.scope,
          'created_at': item.createdAt.toIso8601String(),
          'status': item.status.name,
          'incoming': item.incoming,
        },
    ];

    await file.writeAsString(jsonEncode(payload), flush: true);
  }

  List<IntegrationAuthorization> get items =>
      List<IntegrationAuthorization>.unmodifiable(_items);

  List<IntegrationAuthorization> get pending =>
      List<IntegrationAuthorization>.unmodifiable(
        _items.where(
          (item) => item.status == IntegrationAuthorizationStatus.pending,
        ),
      );

  List<IntegrationAuthorization> get authorized =>
      List<IntegrationAuthorization>.unmodifiable(
        _items.where(
          (item) => item.status == IntegrationAuthorizationStatus.approved,
        ),
      );

  Future<String> addRequest({
    required String type,
    required String targetAccountId,
    required Map<String, List<String>> scope,
  }) async {
    final existing = findRequest(type: type, targetAccountId: targetAccountId, scope: scope);
    if (existing != null) return existing.id;
    final id = 'frontend-auth-' + DateTime.now().microsecondsSinceEpoch.toString();

    _items.insert(
      0,
      IntegrationAuthorization(
        id: id,
        type: type,
        sourceShId: 'Current SH',
        targetAccountId: targetAccountId,
        scope: <String, List<String>>{
          for (final entry in scope.entries)
            entry.key: List<String>.unmodifiable(entry.value),
        },
        createdAt: DateTime.now(),
      ),
    );

    await _persist();
    notifyListeners();
    return id;
  }

  IntegrationAuthorization? findRequest({
    required String type,
    required String targetAccountId,
    required Map<String, List<String>> scope,
  }) {
    final normalizedType = type.trim().toLowerCase();
    final normalizedTarget = targetAccountId.trim().toLowerCase();
    for (final item in _items) {
      if (item.type.trim().toLowerCase() != normalizedType) continue;
      if (item.targetAccountId.trim().toLowerCase() != normalizedTarget) continue;
      if (_scopeEquals(item.scope, scope)) return item;
    }
    return null;
  }

  bool _scopeEquals(Map<String, List<String>> a, Map<String, List<String>> b) {
    final keys = <String>{...a.keys, ...b.keys};
    for (final key in keys) {
      final left = <String>[...(a[key] ?? const <String>[])];
      final right = <String>[...(b[key] ?? const <String>[])];
      left.sort();
      right.sort();
      if (left.length != right.length) return false;
      for (var i = 0; i < left.length; i++) {
        if (left[i] != right[i]) return false;
      }
    }
    return true;
  }

  void approve(String id) {
    final item = _find(id);
    if (item == null) return;
    item.status = IntegrationAuthorizationStatus.approved;
    notifyListeners();
    _persist();
  }

  void reject(String id) {
    final item = _find(id);
    if (item == null) return;
    item.status = IntegrationAuthorizationStatus.rejected;
    notifyListeners();
    _persist();
  }

  void revoke(String id) {
    final item = _find(id);
    if (item == null) return;
    item.status = IntegrationAuthorizationStatus.revoked;
    notifyListeners();
    _persist();
  }

  IntegrationAuthorization? _find(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
