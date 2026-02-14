import 'package:flutter_test/flutter_test.dart';

import 'package:queue_ease/core/app/app.dart';

void main() {
  testWidgets('App renders login page on startup', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text('QueueEase'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
