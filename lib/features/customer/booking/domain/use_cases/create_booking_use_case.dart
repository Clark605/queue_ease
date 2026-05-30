import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../core/utils/time_utils.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';
import '../../../../shared_domain/entities/appointment_status.dart';
import '../../domain/repositories/customer_appointment_repository.dart';

/// Creates a new appointment for the customer booking flow.
///
/// Validates required fields before delegating to [AppointmentRepository],
/// which performs a transactional conflict check before persisting.
@lazySingleton
class CreateBookingUseCase {
  const CreateBookingUseCase(this._appointmentRepository, this._logger);

  static const _bookingHorizonDays = 30;

  final CustomerAppointmentRepository _appointmentRepository;
  final AppLogger _logger;

  Future<Result<AppointmentEntity>> call({
    required String customerId,
    required String orgId,
    required String serviceId,
    required String customerName,
    required DateTime scheduledAt,
    String? customerPhone,
  }) async {
    final trimmedName = customerName.trim();
    if (trimmedName.isEmpty) {
      const exception = ValidationException(
        'Customer name is required.',
        field: 'customerName',
      );
      _logger.warning('CreateBookingUseCase: customerName is empty');
      return const Failure(exception);
    }

    final trimmedPhone = customerPhone?.trim();
    final normalizedScheduledAt = TimeUtils.normalizeToUtc(scheduledAt);
    final maxAllowedSchedule = TimeUtils.nowUtc().add(
      const Duration(days: _bookingHorizonDays),
    );
    if (normalizedScheduledAt.isAfter(maxAllowedSchedule)) {
      final exception = const ValidationException(
        'Bookings are limited to the next $_bookingHorizonDays days.',
        field: 'scheduledAt',
      );
      _logger.warning(
        'CreateBookingUseCase: scheduledAt exceeds horizon '
        'scheduledAt=${normalizedScheduledAt.toIso8601String()} '
        'maxAllowed=${maxAllowedSchedule.toIso8601String()}',
      );
      return Failure(exception);
    }

    final appointment = AppointmentEntity(
      id: '',
      orgId: orgId,
      serviceId: serviceId,
      customerId: customerId,
      customerName: trimmedName,
      customerPhone: (trimmedPhone?.isEmpty ?? true) ? null : trimmedPhone,
      scheduledAt: normalizedScheduledAt,
      status: AppointmentStatus.booked,
      createdAt: TimeUtils.nowUtc(),
    );

    final result = await _appointmentRepository.createAppointment(appointment);
    return switch (result) {
      Success() => result,
      Failure(:final exception) when exception is ValidationException => () {
        _logger.warning(
          'CreateBookingUseCase: slot conflict for '
          'customerId=$customerId scheduledAt=${scheduledAt.toIso8601String()}',
          exception,
          exception.stackTrace,
        );
        return result;
      }(),
      Failure(:final exception) => () {
        _logger.error(
          'CreateBookingUseCase: failed for customerId=$customerId',
          exception,
          exception.stackTrace,
        );
        return result;
      }(),
    };
  }
}
