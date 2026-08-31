import 'package:flutter_test/flutter_test.dart';
import 'package:second_head/main.dart';

void main() {
  testWidgets('SECOND HEAD foundation renders', (tester) async {
    await tester.pumpWidget(const SecondHeadApp());

    expect(find.text('SECOND HEAD'), findsOneWidget);
  });
}
