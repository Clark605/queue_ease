import 'package:equatable/equatable.dart';
import 'package:queue_ease/features/shared_domain/entities/service_entity.dart';

/// Base class for all service management states.
sealed class ServiceState extends Equatable {
  const ServiceState();
}

/// Initial state — emitted before any service data is loaded.
final class ServiceInitial extends ServiceState {
  const ServiceInitial();

  @override
  List<Object?> get props => [];
}

/// Emitted while an async service operation is in progress.
final class ServiceLoading extends ServiceState {
  const ServiceLoading();

  @override
  List<Object?> get props => [];
}

/// Emitted when the service list is successfully loaded.
final class ServiceLoaded extends ServiceState {
  const ServiceLoaded(this.services);

  final List<ServiceEntity> services;

  @override
  List<Object?> get props => [services];
}

/// Emitted when the real-time stream fails to load services.
///
/// Shown inline in the list body — not relevant to form-page mutations.
final class ServiceError extends ServiceState {
  const ServiceError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted when a write operation (create, update, delete) fails.
///
/// Distinct from [ServiceError] so that form pages can listen exclusively
/// for mutation failures without reacting to unrelated stream errors.
final class ServiceMutationError extends ServiceState {
  const ServiceMutationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted after a successful write operation (create, update, delete).
///
/// Used to trigger SnackBar feedback in the UI without clobbering the
/// loaded list state — the underlying stream will push an updated
/// [ServiceLoaded] shortly after.
final class ServiceOperationSuccess extends ServiceState {
  const ServiceOperationSuccess();

  @override
  List<Object?> get props => [];
}
