import 'package:flutter_test/flutter_test.dart';
import 'package:second_head/main.dart';
import 'package:second_head/core/widgets/sh_brand_mark.dart';
import 'package:second_head/features/auth/auth_screens.dart';

void main() {
  testWidgets('SECOND HEAD foundation renders', (tester) async {
    AuthSession.isAuthenticated = false;
    await tester.pumpWidget(const SecondHeadApp());

    expect(find.text('Second Head'), findsOneWidget);
    expect(find.text('Human - AI Unity'), findsOneWidget);
    expect(find.byType(ShBrandMark), findsOneWidget);
  });
}
