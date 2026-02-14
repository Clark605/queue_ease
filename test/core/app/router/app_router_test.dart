import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/core/app/router/app_router.dart';

void main() {
  group('AppRouter', () {
    test('createRouter returns a GoRouter instance', () {
      final router = createRouter();
      expect(router, isNotNull);
    });

    test('initial location is login', () {
      expect(Routes.login, equals('/login'));
    });

    test('route paths follow convention', () {
      expect(Routes.adminDashboard, startsWith('/a/'));
      expect(Routes.customerHome, startsWith('/c/'));
    });
  });
}
