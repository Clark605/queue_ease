import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/features/customer/entry/domain/use_cases/calculate_wait_time_use_case.dart';

void main() {
  group('CalculateWaitTimeUseCase', () {
    const useCase = CalculateWaitTimeUseCase();

    test('returns sum of all positive durations ahead', () {
      final result = useCase([15, 20, 10]);

      expect(result, 45);
    });

    test('clamps negative durations to zero contribution', () {
      final result = useCase([10, -5, 5]);

      expect(result, 15);
    });

    test('returns zero for empty durations list', () {
      final result = useCase(const []);

      expect(result, 0);
    });
  });
}
