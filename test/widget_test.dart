// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter_test/flutter_test.dart';

import 'package:offora/main.dart';

void main() {
  testWidgets('Landing page renders core texts', (WidgetTester tester) async {
    // Build the Offora app and trigger a frame.
    await tester.pumpWidget(const OfforaApp());

    // Verify core landing texts are present.
    expect(find.text('Offora'), findsWidgets);
    expect(find.text('Coming Soon'), findsWidgets);
  });
}
