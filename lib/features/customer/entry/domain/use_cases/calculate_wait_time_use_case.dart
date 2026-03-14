import 'package:injectable/injectable.dart';

/// Computes deterministic customer wait estimates.
///
/// The estimate is defined as the sum of service durations (minutes) for all
/// active queue entries ahead of the current customer.
@injectable
class CalculateWaitTimeUseCase {
  const CalculateWaitTimeUseCase();

  int call(List<int> durationsAheadMinutes) {
    final sum = durationsAheadMinutes.fold<int>(
      0,
      (total, value) => total + (value < 0 ? 0 : value),
    );
    return sum < 0 ? 0 : sum;
  }
}
