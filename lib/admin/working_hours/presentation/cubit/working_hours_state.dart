import 'package:equatable/equatable.dart';

import '../../../../shared/organization/domain/entities/working_hours_entity.dart';

sealed class WorkingHoursState extends Equatable {
  const WorkingHoursState();
}

final class WorkingHoursInitial extends WorkingHoursState {
  const WorkingHoursInitial();

  @override
  List<Object?> get props => [];
}

final class WorkingHoursLoading extends WorkingHoursState {
  const WorkingHoursLoading();

  @override
  List<Object?> get props => [];
}

final class WorkingHoursLoaded extends WorkingHoursState {
  const WorkingHoursLoaded(
    this.days, {
    this.pendingDays = const [],
    this.isDirty = false,
  });

  final List<WorkingHoursEntity> days;
  final List<WorkingHoursEntity> pendingDays;
  final bool isDirty;

  WorkingHoursLoaded copyWith({
    List<WorkingHoursEntity>? pendingDays,
    bool? isDirty,
  }) =>
      WorkingHoursLoaded(
        days,
        pendingDays: pendingDays ?? this.pendingDays,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  List<Object?> get props => [days, pendingDays, isDirty];
}

final class WorkingHoursSaving extends WorkingHoursState {
  const WorkingHoursSaving();

  @override
  List<Object?> get props => [];
}

final class WorkingHoursSaveSuccess extends WorkingHoursState {
  const WorkingHoursSaveSuccess();

  @override
  List<Object?> get props => [];
}

final class WorkingHoursSaveError extends WorkingHoursState {
  const WorkingHoursSaveError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class WorkingHoursStreamError extends WorkingHoursState {
  const WorkingHoursStreamError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
