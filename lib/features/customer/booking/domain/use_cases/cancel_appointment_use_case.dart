import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../shared_domain/entities/appointment_status.dart';
import '../repositories/customer_appointment_repository.dart';

/// Cancels a customer's appointment by updating its status to [AppointmentStatus.cancelled].
///
/// Only appointments with status [AppointmentStatus.booked] can be cancelled.
/// Other statuses will return a [ValidationException].
@injectable
class CancelAppointmentUseCase {
  const CancelAppointmentUseCase(this._repository, this._logger);

  final CustomerAppointmentRepository _repository;
  final AppLogger _logger;

  Future<Result<void>> call({
    required String orgId,
    required String appointmentId,
    required AppointmentStatus currentStatus,
  }) async {
    // Validate that the appointment can be cancelled. Allow cancelling
    // both `booked` and `inQueue` statuses per issue #31.
    if (currentStatus != AppointmentStatus.booked &&
        currentStatus != AppointmentStatus.inQueue) {
      final exception = ValidationException(
        cancellationMessage(currentStatus),
        field: 'status',
      );
      _logger.warning(
        'CancelAppointmentUseCase: cannot cancel appointment with status $currentStatus',
      );
      return Failure(exception);
    }

    _logger.info(
      'CancelAppointmentUseCase: cancelling appointment $appointmentId',
    );

    return _repository.updateAppointmentStatus(
      orgId: orgId,
      appointmentId: appointmentId,
      status: AppointmentStatus.cancelled,
    );
  }

  /// Returns a human-readable message explaining why cancellation is not allowed.
  String cancellationMessage(AppointmentStatus status) {
    return switch (status) {
      AppointmentStatus.completed => 'This appointment is already completed.',
      AppointmentStatus.serving =>
        'This appointment is currently being served.',
      AppointmentStatus.inQueue => 'This booking is currently in the queue.',
      AppointmentStatus.cancelled => 'This booking has already been cancelled.',
      AppointmentStatus.noShow => 'This booking was marked as no-show.',
      _ => 'This booking can no longer be cancelled.',
    };
  }
}
