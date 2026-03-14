import 'package:equatable/equatable.dart';

import '../../../../shared_domain/entities/organization_entity.dart';
import '../../../../shared_domain/entities/working_hours_entity.dart';

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
    this.todayWorkingHours,
  });

  final OrganizationEntity org;
  final bool isCurrentlyOpen;

  /// Today's working hours entry, or null if the org has none configured.
  final WorkingHoursEntity? todayWorkingHours;

  @override
  List<Object?> get props => [org, isCurrentlyOpen, todayWorkingHours];
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
