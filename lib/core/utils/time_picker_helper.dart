import 'package:flutter/material.dart';

abstract final class TimePickerHelper {
  /// Parses a `HH:MM` string into a [TimeOfDay].
  ///
  /// If the input is malformed, logs a warning and falls back to 00:00 rather
  /// than throwing, so UI renders a safe default instead of crashing.
  static TimeOfDay parse(String hhmm) {
    try {
      final parts = hhmm.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      debugPrint(
        'TimePickerHelper.parse: malformed input "$hhmm"; defaulting to 00:00',
      );
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  /// Formats a [TimeOfDay] to `HH:MM` (24-hour, zero-padded).
  static String format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Converts a `HH:MM` string to a 12-hour AM/PM display string.
  static String display(String hhmm) {
    final t = parse(hhmm);
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  /// Shows the system time picker pre-filled with [current] (`HH:MM`).
  ///
  /// Returns the selected [TimeOfDay], or `null` if the user dismissed.
  static Future<TimeOfDay?> pick(BuildContext context, String current) =>
      showTimePicker(context: context, initialTime: parse(current));
}
