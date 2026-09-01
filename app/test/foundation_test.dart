import 'package:flutter_test/flutter_test.dart';
import 'package:second_head/main.dart';
import 'package:second_head/core/widgets/sh_brand_mark.dart';

void main() {
  testWidgets('SECOND HEAD foundation renders', (tester) async {
    await tester.pumpWidget(const SecondHeadApp());

    expect(find.text('SECOND HEAD'), findsOneWidget);
    expect(find.byType(ShBrandMark), findsOneWidget);

    // Allow SplashScreen's startup navigation timer to complete before
    // the widget test tears down, avoiding a pending FakeTimer failure.
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump();
  });
}
