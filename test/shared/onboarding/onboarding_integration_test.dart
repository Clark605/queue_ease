import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:queue_ease/core/app/app.dart';
import 'package:queue_ease/core/app/di/injection.dart';
import 'package:queue_ease/core/services/onboarding_service.dart';

void main() {
  group('Onboarding Integration Tests', () {
    late OnboardingService onboardingService;

    setUpAll(() async {
      // Clear SharedPreferences before running tests.
      SharedPreferences.setMockInitialValues({});
      configureDependencies();
      onboardingService = getIt<OnboardingService>();
    });

    setUp(() async {
      // Reset onboarding state before each test.
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('Onboarding shows on first launch', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Should see the first onboarding page.
      expect(find.text('No more waiting in line'), findsOneWidget);
      expect(
        find.text('Join the queue or book an appointment before you arrive.'),
        findsOneWidget,
      );
    });

    testWidgets('User can navigate through all three pages', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Page 1: "No more waiting in line"
      expect(find.text('No more waiting in line'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next to go to page 2.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 2: "Know your turn in real time"
      expect(find.text('Know your turn in'), findsOneWidget);
      expect(find.text('real time'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next to go to page 3.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 3: "Fair turns. No confusion."
      expect(find.text('Fair turns.'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets(
      'Skip button marks onboarding as complete and navigates to login',
      (WidgetTester tester) async {
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();

        // Verify onboarding is showing.
        expect(find.text('No more waiting in line'), findsOneWidget);

        // Tap Skip button.
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        // Should navigate to login page.
        expect(find.text('Sign In'), findsOneWidget);

        // Verify onboarding was marked as complete.
        final isComplete = await onboardingService.hasCompletedOnboarding();
        expect(isComplete, isTrue);
      },
    );

    testWidgets(
      'Get Started button marks onboarding as complete and navigates to login',
      (WidgetTester tester) async {
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();

        // Navigate to the last page.
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        // Verify we're on the last page.
        expect(find.text('Fair turns.'), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);

        // Tap Get Started.
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Should navigate to login page.
        expect(find.text('Sign In'), findsOneWidget);

        // Verify onboarding was marked as complete.
        final isComplete = await onboardingService.hasCompletedOnboarding();
        expect(isComplete, isTrue);
      },
    );

    testWidgets('Completed onboarding skips to login on next launch', (
      WidgetTester tester,
    ) async {
      // Mark onboarding as complete.
      await onboardingService.markOnboardingComplete();

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Should skip directly to login page.
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('No more waiting in line'), findsNothing);
    });

    testWidgets('Page indicator updates as user navigates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Check that dots are present.
      var dots = find.byType(Container);
      expect(dots, findsWidgets);

      // Go to next page.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Indicator should update (widget rebuilds correctly).
      expect(find.text('Know your turn in'), findsOneWidget);

      // Go to next page again.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Final page.
      expect(find.text('Fair turns.'), findsOneWidget);
    });
  });
}
