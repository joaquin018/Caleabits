import 'package:flutter_test/flutter_test.dart';
import 'package:habits/main.dart';

void main() {
  testWidgets('Smoke test for Caleabits', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CaleabitsApp());

    // Verify that some static text is present (e.g., today's month could be tricky,
    // but the 'Hoy' button is stable).
    expect(find.text('Hoy'), findsOneWidget);
  });
}
