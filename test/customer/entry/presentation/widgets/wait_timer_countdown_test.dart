import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/features/customer/entry/presentation/widgets/wait_timer_countdown.dart';

void main() {
  testWidgets('displays fallback minutes and updates on widget change', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WaitTimerCountdown(
            expectedServiceTime: null,
            fallbackWaitMinutes: 10,
          ),
        ),
      ),
    );

    expect(find.text('10 min'), findsOneWidget);

    // Update the fallback value to 5 and verify UI updates
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WaitTimerCountdown(
            expectedServiceTime: null,
            fallbackWaitMinutes: 5,
          ),
        ),
      ),
    );

    // AnimatedSwitcher has animation; pump to settle
    await tester.pumpAndSettle();

    expect(find.text('5 min'), findsOneWidget);
  });

  testWidgets('displays expectedServiceTime minutes and updates when changed', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now().toUtc();
    final expected = now.add(const Duration(minutes: 7));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WaitTimerCountdown(
            expectedServiceTime: expected,
            fallbackWaitMinutes: null,
          ),
        ),
      ),
    );

    // remaining minutes computed from UTC now
    final remaining1 = expected.difference(DateTime.now().toUtc()).inMinutes;
    expect(find.textContaining('$remaining1 min'), findsOneWidget);

    // Change expected time to 3 minutes ahead
    final expected2 = now.add(const Duration(minutes: 3));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WaitTimerCountdown(
            expectedServiceTime: expected2,
            fallbackWaitMinutes: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final remaining2 = expected2.difference(DateTime.now().toUtc()).inMinutes;
    expect(find.textContaining('$remaining2 min'), findsOneWidget);
  });
}
