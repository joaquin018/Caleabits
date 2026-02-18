import 'package:flutter_test/flutter_test.dart';
import 'package:habits/main.dart';

void main() {
  testWidgets('Hello World smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HabitsApp());

    // Verify that our "Hello World" text is present.
    expect(find.text('Hello World'), findsOneWidget);
    expect(find.text('Welcome to Habits'), findsOneWidget);
  });
}
