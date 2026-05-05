import 'package:equatable/equatable.dart';
import 'package:queue_ease/features/shared_domain/entities/organization_entity.dart';

/// Base class for all organization states.
sealed class OrganizationState extends Equatable {
  const OrganizationState();
}

/// Initial state — emitted before any organization data is loaded.
final class OrganizationInitial extends OrganizationState {
  const OrganizationInitial();

  @override
  List<Object?> get props => [];
}

/// Emitted while an async organization operation is in progress.
final class OrganizationLoading extends OrganizationState {
  const OrganizationLoading();

  @override
  List<Object?> get props => [];
}

/// Emitted when organization data is successfully loaded.
final class OrganizationLoaded extends OrganizationState {
  const OrganizationLoaded(this.organization);

  final OrganizationEntity organization;

  @override
  List<Object?> get props => [organization];
}

/// Emitted when an organization operation fails.
final class OrganizationError extends OrganizationState {
  const OrganizationError(this.message, {this.organization});

  final String message;
  final OrganizationEntity? organization;

  @override
  List<Object?> get props => [message, organization];
}
