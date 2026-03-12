import 'package:equatable/equatable.dart';

import '../../../../shared/organization/domain/entities/service_entity.dart';

sealed class ServiceSelectionState extends Equatable {
  const ServiceSelectionState();

  @override
  List<Object?> get props => [];
}

final class ServiceSelectionInitial extends ServiceSelectionState {
  const ServiceSelectionInitial();
}

final class ServiceSelectionLoading extends ServiceSelectionState {
  const ServiceSelectionLoading();
}

final class ServiceSelectionLoaded extends ServiceSelectionState {
  const ServiceSelectionLoaded(this.services);

  final List<ServiceEntity> services;

  @override
  List<Object?> get props => [services];
}

final class ServiceSelectionError extends ServiceSelectionState {
  const ServiceSelectionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
