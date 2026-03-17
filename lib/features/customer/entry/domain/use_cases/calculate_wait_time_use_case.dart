import 'package:injectable/injectable.dart';

/// Computes deterministic customer wait estimates.
///
/// The estimate relies on the sum of durations ahead and the time elapsed
/// since the queue was last updated (e.g. when the current service started).
@injectable
class CalculateWaitTimeUseCase {
  const CalculateWaitTimeUseCase();

  DateTime? expectedServiceTime({
    required List<int> durationsAheadMinutes,
    required DateTime? queueUpdatedAt,
  }) {
    if (durationsAheadMinutes.isEmpty && queueUpdatedAt == null) return null;
    final totalDuration = durationsAheadMinutes.fold<int>(
      0,
      (total, value) => total + (value < 0 ? 0 : value),
    );
    final referenceTime = queueUpdatedAt ?? DateTime.now();
    return referenceTime.add(Duration(minutes: totalDuration));
  }
}
