import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/features/admin/queue_management/domain/services/effective_time_margin_resolver.dart';

void main() {
  group('EffectiveTimeMarginResolver', () {
    late EffectiveTimeMarginResolver resolver;

    setUp(() {
      resolver = const EffectiveTimeMarginResolver();
    });

    group('resolve', () {
      test('returns fallback (2) for null margin', () {
        final result = resolver.resolve(timeMarginMinutes: null);
        expect(result, equals(2));
      });

      test('returns fallback (2) for negative margin', () {
        final result = resolver.resolve(timeMarginMinutes: -1);
        expect(result, equals(2));
      });

      test('returns fallback (2) for margin exceeding 60 minutes', () {
        final result = resolver.resolve(timeMarginMinutes: 61);
        expect(result, equals(2));
      });

      test('returns fallback (2) for margin exactly at invalid boundary', () {
        final result = resolver.resolve(timeMarginMinutes: -999);
        expect(result, equals(2));
      });

      test('returns valid margin for 0 minutes (edge case)', () {
        final result = resolver.resolve(timeMarginMinutes: 0);
        expect(result, equals(0));
      });

      test('returns valid margin for 1 minute', () {
        final result = resolver.resolve(timeMarginMinutes: 1);
        expect(result, equals(1));
      });

      test('returns valid margin for 30 minutes (typical case)', () {
        final result = resolver.resolve(timeMarginMinutes: 30);
        expect(result, equals(30));
      });

      test('returns valid margin for 60 minutes (maximum boundary)', () {
        final result = resolver.resolve(timeMarginMinutes: 60);
        expect(result, equals(60));
      });

      test('returns fallback constant matches expected value', () {
        expect(EffectiveTimeMarginResolver.fallbackMinutes, equals(2));
      });
    });
  });
}