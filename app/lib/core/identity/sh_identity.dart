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

class ResolvedActorContext {
  const ResolvedActorContext({
    required this.accountId,
    required this.shId,
    required this.ownershipRole,
    required this.actor,
    required this.authority,
    required this.shDesignation,
  });

  final String accountId;
  final String shId;
  final String ownershipRole;
  final String actor;
  final String? authority;
  final String shDesignation;

  factory ResolvedActorContext.fromMap(Map<String, dynamic> map) {
    final accountId = map['account_id'] as String?;
    final shId = map['sh_id'] as String?;
    final ownershipRole = map['ownership_role'] as String?;
    final actor = map['actor'] as String?;
    final shDesignation = map['sh_designation'] as String?;

    if (accountId == null ||
        shId == null ||
        ownershipRole == null ||
        actor == null ||
        shDesignation == null) {
      throw const FormatException('Resolved actor context is incomplete.');
    }

    return ResolvedActorContext(
      accountId: accountId,
      shId: shId,
      ownershipRole: ownershipRole,
      actor: actor,
      authority: map['authority'] as String?,
      shDesignation: shDesignation,
    );
  }

  ShIdentity toIdentity() => ShIdentity(
        accountId: accountId,
        shId: shId,
        ownershipRole: ownershipRole,
      );
}

class ShIdentityContext extends ChangeNotifier {
  ShIdentity? _identity;
  ResolvedActorContext? _actorContext;

  ShIdentity? get identity => _identity;
  ResolvedActorContext? get actorContext => _actorContext;
  bool get hasIdentity => _identity != null;
  bool get hasActorContext => _actorContext != null;

  void setIdentity(ShIdentity identity) {
    _identity = identity;
    notifyListeners();
  }

  void setActorContext(ResolvedActorContext context) {
    _actorContext = context;
    _identity = context.toIdentity();
    notifyListeners();
  }

  void clear() {
    if (_identity == null && _actorContext == null) return;
    _identity = null;
    _actorContext = null;
    notifyListeners();
  }
}
