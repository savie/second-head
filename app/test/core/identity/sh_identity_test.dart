import 'package:flutter_test/flutter_test.dart';
import 'package:second_head/core/identity/sh_identity.dart';

void main() {
  test('SH identity context stores and clears resolved identity', () {
    final context = ShIdentityContext();
    final identity = ShIdentity(
      accountId: 'account-1',
      shId: 'sh-1',
      ownershipRole: 'OWNER',
    );

    expect(context.hasIdentity, isFalse);

    context.setIdentity(identity);

    expect(context.hasIdentity, isTrue);
    expect(context.identity?.accountId, 'account-1');
    expect(context.identity?.shId, 'sh-1');
    expect(context.identity?.ownershipRole, 'OWNER');

    context.clear();

    expect(context.hasIdentity, isFalse);
    expect(context.identity, isNull);
  });
}
