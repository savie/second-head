import 'package:flutter/foundation.dart';

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
    notifyListeners();
    return id;
  }

  void approve(String id) {
    final item = _find(id);
    if (item == null) return;
    item.status = IntegrationAuthorizationStatus.approved;
    notifyListeners();
  }

  void reject(String id) {
    final item = _find(id);
    if (item == null) return;
    item.status = IntegrationAuthorizationStatus.rejected;
    notifyListeners();
  }

  void revoke(String id) {
    final item = _find(id);
    if (item == null) return;
    item.status = IntegrationAuthorizationStatus.revoked;
    notifyListeners();
  }

  IntegrationAuthorization? _find(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
