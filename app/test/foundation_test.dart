import 'package:flutter_test/flutter_test.dart';
import 'package:second_head/main.dart';
import 'package:second_head/core/widgets/sh_brand_mark.dart';

void main() {
  testWidgets('SECOND HEAD foundation renders', (tester) async {
    await tester.pumpWidget(const SecondHeadApp());

    expect(find.text('SECOND HEAD'), findsOneWidget);
    expect(find.byType(ShBrandMark), findsOneWidget);

    // Splash is intentionally shown on every app entry.
    // Allow its session-routing timer to complete before teardown.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
  });
}
