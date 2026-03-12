import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/utils/app_logger.dart';

import '../../../../core/error/result.dart';
import '../../../../shared/organization/domain/entities/organization_entity.dart';
import '../../../../shared/organization/domain/entities/working_hours_entity.dart';
import '../../../../shared/organization/domain/repositories/working_hours_repository.dart';
import '../../domain/use_cases/get_organization_by_slug_use_case.dart';
import 'organization_landing_state.dart';

@injectable
class OrganizationLandingCubit extends Cubit<OrganizationLandingState> {
  OrganizationLandingCubit(
    this._getOrganizationBySlug,
    this._workingHoursRepository,
    this._logger,
  ) : super(const OrganizationLandingInitial());

  final GetOrganizationBySlugUseCase _getOrganizationBySlug;
  final WorkingHoursRepository _workingHoursRepository;
  final AppLogger _logger;

  StreamSubscription<List<WorkingHoursEntity>>? _workingHoursSubscription;

  Future<void> loadOrganization(String slug) async {
    emit(const OrganizationLandingLoading());

    final result = await _getOrganizationBySlug(slug);

    switch (result) {
      case Failure(:final exception):
        _logger.error(
          'OrganizationLandingCubit: failed to load slug=$slug',
          exception,
        );
        emit(OrganizationLandingError(exception.message));
      case Success(:final data) when data == null:
        _logger.warning(
          'OrganizationLandingCubit: no organisation found for slug=$slug',
        );
        emit(const OrganizationLandingNotFound());
      case Success(:final data):
        final org = data!;
        _logger.debug(
          'OrganizationLandingCubit: loaded orgId=${org.id} for slug=$slug',
        );
        _subscribeToWorkingHours(org);
    }
  }

  void _subscribeToWorkingHours(OrganizationEntity org) {
    _workingHoursSubscription?.cancel();
    _logger.debug(
      'OrganizationLandingCubit: subscribing to working hours → orgId=${org.id}',
    );

    _workingHoursSubscription = _workingHoursRepository
        .watchWorkingHours(org.id)
        .listen(
          (workingHours) {
            _logger.debug(
              'OrganizationLandingCubit: working hours updated → '
              '${workingHours.length} entries for orgId=${org.id}',
            );
            final (isOpen, todayHours) = _deriveOpenStatus(workingHours);
            _logger.debug(
              'OrganizationLandingCubit: derived isCurrentlyOpen=$isOpen for orgId=${org.id}',
            );
            emit(
              OrganizationLandingLoaded(
                org: org,
                isCurrentlyOpen: isOpen,
                todayWorkingHours: todayHours,
              ),
            );
          },
          onError: (Object e, StackTrace st) {
            _logger.error(
              'OrganizationLandingCubit: working hours stream error for orgId=${org.id}',
              e,
              st,
            );
            emit(const OrganizationLandingError('Failed to load working hours.'));
          },
        );
  }

  /// Returns `(isOpen, todayEntry)` derived synchronously from [workingHours].
  (bool, WorkingHoursEntity?) _deriveOpenStatus(
    List<WorkingHoursEntity> workingHours,
  ) {
    try {
      final now = DateTime.now();
      // dayOfWeek in entity: 0=Monday … 6=Sunday; DateTime.weekday: 1=Mon … 7=Sun
      final todayIndex = now.weekday - 1;
      final todayMatches = workingHours.where((wh) => wh.dayOfWeek == todayIndex);
      _logger.debug(
        '_deriveOpenStatus: todayIndex=$todayIndex, entryFound=${todayMatches.isNotEmpty}',
      );

      if (todayMatches.isEmpty || !todayMatches.first.isOpen) {
        _logger.debug(
          '_deriveOpenStatus: no entry for today or isOpen=false → closed',
        );
        return (false, todayMatches.isNotEmpty ? todayMatches.first : null);
      }

      final wh = todayMatches.first;
      final open = _parseTime(wh.openTime, now);
      final close = _parseTime(wh.closeTime, now);
      _logger.debug(
        '_deriveOpenStatus: openTime=${wh.openTime}, closeTime=${wh.closeTime}, now=$now',
      );

      if (now.isBefore(open) || !now.isBefore(close)) {
        _logger.debug(
          '_deriveOpenStatus: now is outside open–close window → closed',
        );
        return (false, wh);
      }

      if (wh.breakStart != null && wh.breakEnd != null) {
        final breakStart = _parseTime(wh.breakStart!, now);
        final breakEnd = _parseTime(wh.breakEnd!, now);
        _logger.debug(
          '_deriveOpenStatus: breakWindow=${wh.breakStart}–${wh.breakEnd}',
        );
        if (!now.isBefore(breakStart) && now.isBefore(breakEnd)) {
          _logger.debug(
            '_deriveOpenStatus: now is inside break window → closed',
          );
          return (false, wh);
        }
      }

      _logger.debug('_deriveOpenStatus: organisation is open');
      return (true, wh);
    } catch (e, st) {
      _logger.error('_deriveOpenStatus: unexpected error', e, st);
      return (false, null);
    }
  }

  @override
  Future<void> close() {
    _workingHoursSubscription?.cancel();
    return super.close();
  }

  DateTime _parseTime(String hhmm, DateTime reference) {
    final parts = hhmm.split(':');
    return DateTime(
      reference.year,
      reference.month,
      reference.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
