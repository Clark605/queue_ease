import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/organization/domain/entities/working_hours_entity.dart';
import '../../../../shared/organization/domain/repositories/working_hours_repository.dart';
import '../../../working_hours/domain/repositories/admin_working_hours_repository.dart';
import 'working_hours_state.dart';

/// Manages working hours configuration state for an organization.
///
/// Uses [WorkingHoursRepository] for the real-time watch stream and
/// [AdminWorkingHoursRepository] for save operations.
@injectable
class WorkingHoursCubit extends Cubit<WorkingHoursState> {
  WorkingHoursCubit(this._repository, this._adminRepository, this._logger)
    : super(const WorkingHoursInitial());

  final WorkingHoursRepository _repository;
  final AdminWorkingHoursRepository _adminRepository;
  final AppLogger _logger;

  StreamSubscription<List<WorkingHoursEntity>>? _subscription;

  /// Begins watching working hours for [orgId] in real-time.
  ///
  /// Any previous subscription is cancelled before starting a new one.
  Future<void> watchWorkingHours(String orgId) async {
    _logger.info('WorkingHoursCubit: watchWorkingHours → $orgId');
    emit(const WorkingHoursLoading());

    await _subscription?.cancel();

    _subscription = _repository
        .watchWorkingHours(orgId)
        .listen(
          (days) {
            _logger.debug(
              'WorkingHoursCubit: received update → ${days.length} days',
            );
            final current = state;
            if (current is WorkingHoursLoaded && current.isDirty) {
              emit(
                WorkingHoursLoaded(
                  days,
                  pendingDays: current.pendingDays,
                  isDirty: true,
                ),
              );
            } else {
              emit(WorkingHoursLoaded(days, pendingDays: List.of(days)));
            }
          },
          onError: (error, stackTrace) {
            _logger.error(
              'WorkingHoursCubit: watchWorkingHours stream error',
              error,
              stackTrace,
            );
            emit(
              WorkingHoursStreamError(
                error is AppException
                    ? error.message
                    : 'Failed to load working hours',
              ),
            );
          },
        );
  }

  /// Persists [days] to Firestore for [orgId].
  ///
  /// Emits [WorkingHoursSaving] while in progress, then either
  /// [WorkingHoursSaveSuccess] or [WorkingHoursSaveError].
  Future<void> saveAll({
    required String orgId,
    required List<WorkingHoursEntity> days,
  }) async {
    _logger.info('WorkingHoursCubit: saveAll → $orgId');
    emit(const WorkingHoursSaving());

    final result = await _adminRepository.saveAllWorkingHours(
      orgId: orgId,
      days: days,
    );

    switch (result) {
      case Success():
        _logger.info('WorkingHoursCubit: saveAll success');
        emit(const WorkingHoursSaveSuccess());
      case Failure(:final exception):
        _logger.warning(
          'WorkingHoursCubit: saveAll failure → ${exception.message}',
        );
        emit(WorkingHoursSaveError(exception.message));
    }
  }

  /// Updates a single day in the pending (unsaved) schedule.
  void updateDay(WorkingHoursEntity updated) {
    final current = state;
    if (current is! WorkingHoursLoaded) return;
    final pending = List.of(current.pendingDays);
    final i = pending.indexWhere((d) => d.dayOfWeek == updated.dayOfWeek);
    if (i != -1) pending[i] = updated;
    emit(current.copyWith(pendingDays: pending, isDirty: true));
  }

  /// Copies Monday's schedule to Tuesday–Friday in the pending schedule.
  void applyMondayToWeekdays() {
    final current = state;
    if (current is! WorkingHoursLoaded) return;
    final monday = current.pendingDays.firstWhere(
      (d) => d.dayOfWeek == 0,
      orElse: () => current.pendingDays.first,
    );
    final updated = current.pendingDays.map((day) {
      if (day.dayOfWeek < 1 || day.dayOfWeek > 4) return day;
      return WorkingHoursEntity(
        orgId: day.orgId,
        dayOfWeek: day.dayOfWeek,
        isOpen: monday.isOpen,
        openTime: monday.openTime,
        closeTime: monday.closeTime,
        breakStart: monday.breakStart,
        breakEnd: monday.breakEnd,
      );
    }).toList();
    emit(current.copyWith(pendingDays: updated, isDirty: true));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
