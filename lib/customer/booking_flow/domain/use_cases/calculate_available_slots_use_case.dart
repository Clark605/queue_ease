import 'package:injectable/injectable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/booking/domain/entities/appointment_status.dart';
import '../../../../shared/booking/domain/repositories/appointment_repository.dart';
import '../../../../shared/organization/domain/entities/working_hours_entity.dart';

/// Pure domain use case: computes available time slots for a given service,
/// date, and working-hours schedule.
///
/// Algorithm (FR-010):
/// 1. Generate candidate slots at [serviceDurationMinutes] intervals
///    from [WorkingHoursEntity.openTime] to [closeTime].
///    Only slots whose END time fits within close time are kept.
/// 2. Remove slots that overlap the optional break window.
/// 3. Fetch existing appointments via [AppointmentRepository].
/// 4. Remove slots whose [scheduledAt] matches an existing active appointment
///    (status ≠ [AppointmentStatus.noShow]).
/// 5. Remove past slots when [date] is today (compared to [currentTime]).
@lazySingleton
class CalculateAvailableSlotsUseCase {
  const CalculateAvailableSlotsUseCase(
    this._appointmentRepository,
    this._logger,
  );

  final AppointmentRepository _appointmentRepository;
  final AppLogger _logger;

  Future<Result<List<DateTime>>> call({
    required String orgId,
    required String serviceId,
    required DateTime date,
    required WorkingHoursEntity workingHours,
    required int serviceDurationMinutes,
    required DateTime currentTime,
  }) => Result.guard(() async {
    _logger.debug(
      'CalculateAvailableSlotsUseCase: orgId=$orgId serviceId=$serviceId '
      'date=${date.toIso8601String()} duration=$serviceDurationMinutes min',
    );

    // Step 1: generate candidate slots
    var slots = _generateSlots(date, workingHours, serviceDurationMinutes);
    _logger.debug(
      'CalculateAvailableSlotsUseCase: ${slots.length} candidate slots generated',
    );

    // Step 2: remove break-window overlaps
    if (workingHours.breakStart != null && workingHours.breakEnd != null) {
      slots = _removeBreakOverlaps(
        slots,
        date,
        workingHours.breakStart!,
        workingHours.breakEnd!,
        serviceDurationMinutes,
      );
      _logger.debug(
        'CalculateAvailableSlotsUseCase: ${slots.length} slots after break removal',
      );
    }

    // Step 3: fetch existing appointments
    final result = await _appointmentRepository
        .getAppointmentsForDateAndService(
          orgId: orgId,
          serviceId: serviceId,
          date: date,
        );

    final existing = switch (result) {
      Success(:final data) => data,
      Failure(:final exception) => throw exception,
    };

    // Step 4: remove taken slots (active appointments only)
    final takenTimes = existing
        .where((a) => a.status != AppointmentStatus.noShow)
        .map((a) => a.scheduledAt)
        .toSet();

    slots = slots.where((s) => !takenTimes.contains(s)).toList();
    _logger.debug(
      'CalculateAvailableSlotsUseCase: ${slots.length} slots after removing taken',
    );

    // Step 5: remove past slots for today
    final isToday =
        date.year == currentTime.year &&
        date.month == currentTime.month &&
        date.day == currentTime.day;
    if (isToday) {
      slots = slots.where((s) => s.isAfter(currentTime)).toList();
      _logger.debug(
        'CalculateAvailableSlotsUseCase: ${slots.length} slots after past removal',
      );
    }

    if (slots.isEmpty) {
      _logger.warning(
        'CalculateAvailableSlotsUseCase: no available slots for '
        'serviceId=$serviceId on ${date.toIso8601String()}',
      );
    }

    return slots;
  });

  List<DateTime> _generateSlots(
    DateTime date,
    WorkingHoursEntity wh,
    int durationMinutes,
  ) {
    final openParts = wh.openTime.split(':');
    final closeParts = wh.closeTime.split(':');

    var current = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(openParts[0]),
      int.parse(openParts[1]),
    );
    final close = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(closeParts[0]),
      int.parse(closeParts[1]),
    );

    final slots = <DateTime>[];
    while (current.isBefore(close)) {
      final slotEnd = current.add(Duration(minutes: durationMinutes));
      // Only include slot if its entire duration fits before close time.
      if (!slotEnd.isAfter(close)) {
        slots.add(current);
      }
      current = current.add(Duration(minutes: durationMinutes));
    }
    return slots;
  }

  List<DateTime> _removeBreakOverlaps(
    List<DateTime> slots,
    DateTime date,
    String breakStart,
    String breakEnd,
    int durationMinutes,
  ) {
    final bsParts = breakStart.split(':');
    final beParts = breakEnd.split(':');
    final breakStartTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(bsParts[0]),
      int.parse(bsParts[1]),
    );
    final breakEndTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(beParts[0]),
      int.parse(beParts[1]),
    );

    return slots.where((slot) {
      final slotEnd = slot.add(Duration(minutes: durationMinutes));
      // A slot overlaps the break if it starts before the break ends
      // AND its end extends past the break start.
      final overlaps =
          slot.isBefore(breakEndTime) && slotEnd.isAfter(breakStartTime);
      return !overlaps;
    }).toList();
  }
}
