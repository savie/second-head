import 'package:flutter/foundation.dart';

class ShIdentity {
  const ShIdentity({
    required this.accountId,
    required this.shId,
    required this.ownershipRole,
  });

  final String accountId;
  final String shId;
  final String ownershipRole;
}

class ShIdentityContext extends ChangeNotifier {
  ShIdentity? _identity;

  ShIdentity? get identity => _identity;
  bool get hasIdentity => _identity != null;

  void setIdentity(ShIdentity identity) {
    _identity = identity;
    notifyListeners();
  }

  void clear() {
    if (_identity == null) return;
    _identity = null;
    notifyListeners();
  }
}
