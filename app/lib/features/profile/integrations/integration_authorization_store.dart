import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/backend/backend_client.dart';
import '../../../core/state/sh_profile_state.dart';
import '../../../core/storage/storage_service.dart';

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

  Future<void> refreshFromDisk() async {
    _loaded = false;
    await ensureLoaded();
  }

  Future<void> refreshFromBackend() async {
    try {
      final backendItems = <IntegrationAuthorization>[];
      final currentAccount = profileAccountId.value.trim();

      final inheritanceRows = await backendClient
          .from('inheritance_authorizations')
          .select('authorization_id,source_sh_id,target_account_id,source_account_id,status,scope,created_at')
          .order('created_at', ascending: false);
      for (final raw in inheritanceRows.whereType<Map>()) {
        final row = Map<String, dynamic>.from(raw);
        backendItems.add(_backendItem(
          type: 'Inheritance',
          id: row['authorization_id']?.toString() ?? '',
          sourceShId: row['source_sh_id']?.toString() ?? '',
          targetAccountId: row['target_account_id']?.toString() ?? '',
          status: row['status']?.toString() ?? 'PENDING',
          scope: row['scope'],
          createdAt: row['created_at'],
          incoming: row['source_account_id']?.toString() == currentAccount,
        ));
      }

      final successionRows = await backendClient
          .from('succession_rules')
          .select('succession_id,source_sh_id,successor_account_id,status,scope,created_at')
          .order('created_at', ascending: false);
      for (final raw in successionRows.whereType<Map>()) {
        final row = Map<String, dynamic>.from(raw);
        final dbStatus = row['status']?.toString().toUpperCase() ?? 'ACTIVE';
        backendItems.add(_backendItem(
          type: 'Succession',
          id: row['succession_id']?.toString() ?? '',
          sourceShId: row['source_sh_id']?.toString() ?? '',
          targetAccountId: row['successor_account_id']?.toString() ?? '',
          status: dbStatus == 'REVOKED'
              ? 'REVOKED'
              : dbStatus == 'CONSUMED'
                  ? 'APPROVED'
                  : 'APPROVED',
          scope: row['scope'],
          createdAt: row['created_at'],
          incoming: row['successor_account_id']?.toString() == currentAccount,
        ));
      }

      final backendIds = backendItems.map((item) => item.id).where((id) => id.isNotEmpty).toSet();
      _items.removeWhere((item) => backendIds.contains(item.id));
      _items.insertAll(0, backendItems);
      await _persist();
      notifyListeners();
    } catch (_) {
      // Backend refresh is additive; local authorization state remains usable
      // if the backend is temporarily unreachable.
    }
  }

  IntegrationAuthorization _backendItem({
    required String type,
    required String id,
    required String sourceShId,
    required String targetAccountId,
    required String status,
    required dynamic scope,
    required dynamic createdAt,
    required bool incoming,
  }) {
    final mappedStatus = switch (status.toUpperCase()) {
      'APPROVED' || 'ACTIVE' || 'CONSUMED' => IntegrationAuthorizationStatus.approved,
      'REVOKED' => IntegrationAuthorizationStatus.revoked,
      _ => IntegrationAuthorizationStatus.pending,
    };
    return IntegrationAuthorization(
      id: id,
      type: type,
      sourceShId: sourceShId,
      targetAccountId: targetAccountId,
      scope: _scopeMap(scope),
      createdAt: DateTime.tryParse(createdAt?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      status: mappedStatus,
      incoming: incoming,
    );
  }

  Map<String, List<String>> _scopeMap(dynamic rawScope) {
    final scope = <String, List<String>>{};
    if (rawScope is Map) {
      for (final entry in rawScope.entries) {
        if (entry.value is List) {
          scope[entry.key.toString()] = List<String>.from(entry.value as List);
        }
      }
    }
    return scope;
  }

  IntegrationAuthorization _decode(Map<String, dynamic> raw) {
    return IntegrationAuthorization(
      id: raw['id']?.toString() ?? '',
      type: raw['type']?.toString() ?? '',
      sourceShId: raw['source_sh_id']?.toString() ?? 'Current SH',
      targetAccountId: raw['target_account_id']?.toString() ?? '',
      scope: _scopeMap(raw['scope']),
      createdAt: DateTime.tryParse(raw['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      status: IntegrationAuthorizationStatus.values.firstWhere(
        (value) => value.name == raw['status'],
        orElse: () => IntegrationAuthorizationStatus.pending,
      ),
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

  List<IntegrationAuthorization> get items => List<IntegrationAuthorization>.unmodifiable(_items);
  List<IntegrationAuthorization> get pending => List<IntegrationAuthorization>.unmodifiable(_items.where((item) => item.status == IntegrationAuthorizationStatus.pending));
  List<IntegrationAuthorization> get authorized => List<IntegrationAuthorization>.unmodifiable(_items.where((item) => item.status == IntegrationAuthorizationStatus.approved));

  Future<String> addRequest({
    required String type,
    required String targetAccountId,
    required Map<String, List<String>> scope,
  }) async {
    final existing = findRequest(type: type, targetAccountId: targetAccountId, scope: scope);
    if (existing != null) return existing.id;
    final id = 'frontend-auth-' + DateTime.now().microsecondsSinceEpoch.toString();
    _items.insert(0, IntegrationAuthorization(
      id: id,
      type: type,
      sourceShId: 'Current SH',
      targetAccountId: targetAccountId,
      scope: {for (final entry in scope.entries) entry.key: List<String>.unmodifiable(entry.value)},
      createdAt: DateTime.now(),
    ));
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

  Future<void> deleteRequest(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _items.removeAt(index);
    await _persist();
    notifyListeners();
  }

  Future<void> removeRequestsReferencingKeys(Set<String> keys) async {
    if (keys.isEmpty) return;
    final normalized = keys.map((key) => key.trim()).where((key) => key.isNotEmpty).toSet();
    if (normalized.isEmpty) return;
    final before = _items.length;
    _items.removeWhere((item) {
      if (!{'Inheritance', 'Succession', 'Legacy'}.contains(item.type)) return false;
      return item.scope.values.any((values) => values.any(normalized.contains));
    });
    if (_items.length == before) return;
    await _persist();
    notifyListeners();
  }

  Future<void> approve(String id) async {
    final item = _find(id);
    if (item == null) return;
    if (item.type == 'Inheritance' && _looksLikeUuid(id)) {
      await backendClient.rpc('runtime_approve_inheritance_authorization', params: {'p_authorization_id': id});
      await refreshFromBackend();
      return;
    }
    item.status = IntegrationAuthorizationStatus.approved;
    await _persist();
    notifyListeners();
  }

  Future<void> reject(String id) async {
    final item = _find(id);
    if (item == null) return;
    item.status = IntegrationAuthorizationStatus.rejected;
    await _persist();
    notifyListeners();
  }

  Future<void> revoke(String id) async {
    final item = _find(id);
    if (item == null) return;
    item.status = IntegrationAuthorizationStatus.revoked;
    await _persist();
    notifyListeners();
  }

  bool _looksLikeUuid(String value) => RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$').hasMatch(value);

  IntegrationAuthorization? _find(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
