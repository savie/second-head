import 'package:flutter_test/flutter_test.dart';
import 'package:second_head/core/supabase/supabase_client.dart';
import 'package:second_head/core/widgets/sh_brand_mark.dart';
import 'package:second_head/features/auth/auth_screens.dart';
import 'package:second_head/main.dart';

void main() {
  setUpAll(() async {
    await initializeSupabase();
    await AuthSession.service.signOut();
  });

  testWidgets('SECOND HEAD foundation renders', (tester) async {
    await tester.pumpWidget(const SecondHeadApp());

    expect(find.text('Second Head'), findsOneWidget);
    expect(find.text('Human - AI Unity'), findsOneWidget);
    expect(find.byType(ShBrandMark), findsOneWidget);
  });
}
