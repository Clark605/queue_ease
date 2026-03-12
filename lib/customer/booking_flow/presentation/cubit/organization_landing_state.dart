import 'package:equatable/equatable.dart';

import '../../../../shared/organization/domain/entities/organization_entity.dart';

sealed class OrganizationLandingState extends Equatable {
  const OrganizationLandingState();

  @override
  List<Object?> get props => [];
}

final class OrganizationLandingInitial extends OrganizationLandingState {
  const OrganizationLandingInitial();
}

final class OrganizationLandingLoading extends OrganizationLandingState {
  const OrganizationLandingLoading();
}

final class OrganizationLandingLoaded extends OrganizationLandingState {
  const OrganizationLandingLoaded({
    required this.org,
    required this.isCurrentlyOpen,
  });

  final OrganizationEntity org;
  final bool isCurrentlyOpen;

  @override
  List<Object?> get props => [org, isCurrentlyOpen];
}

final class OrganizationLandingNotFound extends OrganizationLandingState {
  const OrganizationLandingNotFound();
}

final class OrganizationLandingError extends OrganizationLandingState {
  const OrganizationLandingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
