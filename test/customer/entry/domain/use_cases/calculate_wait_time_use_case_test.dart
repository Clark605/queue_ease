import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/features/customer/entry/domain/use_cases/calculate_wait_time_use_case.dart';

void main() {
  group('CalculateWaitTimeUseCase', () {
    const useCase = CalculateWaitTimeUseCase();

    test(
      'expectedServiceTime returns correct sum relative to queueUpdatedAt',
      () {
        final now = DateTime(2026, 2, 21, 10, 0);
        final result = useCase.expectedServiceTime(
          durationsAheadMinutes: [15, 20, 10],
          queueUpdatedAt: now,
        );

        expect(result, DateTime(2026, 2, 21, 10, 45));
      },
    );

    test('expectedServiceTime drops negative durations', () {
      final now = DateTime(2026, 2, 21, 10, 0);
      final result = useCase.expectedServiceTime(
        durationsAheadMinutes: [10, -5, 5],
        queueUpdatedAt: now,
      );

      expect(result, DateTime(2026, 2, 21, 10, 15));
    });

    test('expectedServiceTime returns relative to now if updatedAt is null', () {
      final result = useCase.expectedServiceTime(
        durationsAheadMinutes: const [5],
        queueUpdatedAt: null,
      );

      expect(result, isNotNull);
      // Since it uses DateTime.now(), we can just check if it's strictly in the future.
      expect(result!.isAfter(DateTime.now()), isTrue);
    });

    test(
      'expectedServiceTime returns null for empty list and null updatedAt',
      () {
        final result = useCase.expectedServiceTime(
          durationsAheadMinutes: const [],
          queueUpdatedAt: null,
        );

        expect(result, isNull);
      },
    );
  });
}
