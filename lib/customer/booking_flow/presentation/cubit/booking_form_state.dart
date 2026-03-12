import 'package:equatable/equatable.dart';

import '../../../../shared/booking/domain/entities/appointment_entity.dart';

sealed class BookingFormState extends Equatable {
  const BookingFormState();

  @override
  List<Object?> get props => [];
}

/// Initial ready-to-fill state emitted after the cubit is initialised.
final class BookingFormInitial extends BookingFormState {
  const BookingFormInitial({required this.prefillName});

  final String prefillName;

  @override
  List<Object?> get props => [prefillName];
}

/// Emitted while the appointment write request is in-flight.
final class BookingFormSubmitting extends BookingFormState {
  const BookingFormSubmitting();
}

/// Emitted when the appointment was created successfully.
final class BookingFormSuccess extends BookingFormState {
  const BookingFormSuccess(this.appointment);

  final AppointmentEntity appointment;

  @override
  List<Object?> get props => [appointment];
}

/// Emitted when the chosen slot was taken by a concurrent booking.
///
/// The page should surface this as a snackbar and pop back to slot selection.
final class BookingFormConflict extends BookingFormState {
  const BookingFormConflict(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted on network or unknown errors; the form stays mounted for retry.
final class BookingFormError extends BookingFormState {
  const BookingFormError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
