import 'package:equatable/equatable.dart';

import '../../../../shared_domain/entities/appointment_entity.dart';

sealed class CustomerAppointmentsState extends Equatable {
  const CustomerAppointmentsState();

  @override
  List<Object?> get props => [];
}

final class CustomerAppointmentsInitial extends CustomerAppointmentsState {
  const CustomerAppointmentsInitial();
}

final class CustomerAppointmentsLoading extends CustomerAppointmentsState {
  const CustomerAppointmentsLoading();
}

final class CustomerAppointmentsLoaded extends CustomerAppointmentsState {
  const CustomerAppointmentsLoaded({required this.appointments});

  final List<AppointmentEntity> appointments;

  @override
  List<Object?> get props => [appointments];
}

final class CustomerAppointmentsError extends CustomerAppointmentsState {
  const CustomerAppointmentsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
