/// Time utilities for consistent datetime handling across the application.
///
/// Centralizes all time operations to use UTC normalization and prevent
/// timezone/clock drift issues in business automation logic.
///
/// **Why UTC**: Queue automation deadlines must be consistent regardless of:
/// - Device timezone settings
/// - Daylight saving time transitions
/// - Client-server clock drift
/// - Geographic distribution of users
class TimeUtils {
  TimeUtils._();

  /// Returns the current UTC time.
  ///
  /// Use this instead of `DateTime.now()` for any deadline calculations
  /// or time comparisons in queue automation logic.
  static DateTime nowUtc() => DateTime.now().toUtc();

  /// Normalizes any DateTime to UTC.
  ///
  /// Ensures consistent timezone handling for stored timestamps.
  /// Firestore timestamps are stored in UTC, so this aligns local calculations.
  static DateTime normalizeToUtc(DateTime dateTime) => dateTime.toUtc();

  /// Calculates appointment deadline using UTC normalization.
  ///
  /// This is the canonical method for determining when an appointment
  /// becomes eligible for auto no-show marking.
  ///
  /// - [scheduledAt]: The original appointment scheduled time
  /// - [marginMinutes]: Grace period after scheduled time
  ///
  /// Returns UTC deadline timestamp for consistent comparisons.
  static DateTime calculateDeadline(DateTime scheduledAt, int marginMinutes) {
    final normalizedScheduled = normalizeToUtc(scheduledAt);
    return normalizedScheduled.add(Duration(minutes: marginMinutes));
  }

  /// Calculates remaining time until deadline in seconds.
  ///
  /// Returns null if deadline has already passed.
  /// Used for countdown timer displays in admin UI.
  static int? calculateRemainingSeconds(DateTime deadline) {
    final now = nowUtc();
    final normalizedDeadline = normalizeToUtc(deadline);

    if (now.isAfter(normalizedDeadline)) {
      return null; // Deadline passed
    }

    return normalizedDeadline.difference(now).inSeconds;
  }

  /// Checks if an appointment is currently overdue for no-show.
  ///
  /// - [scheduledAt]: Original appointment time
  /// - [marginMinutes]: Grace period in minutes
  ///
  /// Returns true if current UTC time is past the deadline.
  static bool isOverdue(DateTime scheduledAt, int marginMinutes) {
    final deadline = calculateDeadline(scheduledAt, marginMinutes);
    return nowUtc().isAfter(deadline);
  }

  /// Checks if an appointment is not yet due (scheduled time is in future).
  ///
  /// Used to implement pre-booking action locks in queue management.
  static bool isNotDueYet(DateTime scheduledAt) {
    return nowUtc().isBefore(normalizeToUtc(scheduledAt));
  }

  /// Formats a DateTime to an ISO 8601 UTC string for logging/debugging.
  ///
  /// Provides consistent timestamp format for error logs and audit trails.
  static String toUtcIsoString(DateTime dateTime) {
    return normalizeToUtc(dateTime).toIso8601String();
  }

  /// Formats a Duration to human-readable string for UI display.
  ///
  /// Examples: "2m 30s", "1h 15m", "45s"
  static String formatDuration(Duration duration) {
    if (duration.isNegative) return '0s';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Formats remaining time for countdown displays.
  ///
  /// Returns user-friendly countdown string like "5:30" (5 minutes 30 seconds).
  /// Returns "Overdue" if time has passed.
  static String formatCountdown(int? remainingSeconds) {
    if (remainingSeconds == null || remainingSeconds <= 0) {
      return 'Overdue';
    }

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Validates that a DateTime is within reasonable bounds for queue operations.
  ///
  /// Prevents potential issues from malformed timestamps or extreme dates.
  /// Queue operations should typically be within ±24 hours of current time.
  static bool isReasonableQueueTime(DateTime dateTime) {
    final now = nowUtc();
    final normalized = normalizeToUtc(dateTime);
    final daysBefore = now.difference(normalized).inDays;
    final daysAfter = normalized.difference(now).inDays;

    // Allow 7 days in past (for historical data) and 30 days in future (for bookings)
    return daysBefore <= 7 && daysAfter <= 30;
  }
}