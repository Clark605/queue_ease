import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/utils/app_logger.dart';

import '../../../../core/error/result.dart';
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
        final isOpen = await _deriveIsCurrentlyOpen(org.id);
        _logger.debug(
          'OrganizationLandingCubit: derived isCurrentlyOpen=$isOpen for orgId=${org.id}',
        );
        emit(OrganizationLandingLoaded(org: org, isCurrentlyOpen: isOpen));
    }
  }

  Future<bool> _deriveIsCurrentlyOpen(String orgId) async {
    try {
      final workingHours = await _workingHoursRepository
          .watchWorkingHours(orgId)
          .first;
      _logger.debug(
        '_deriveIsCurrentlyOpen: fetched ${workingHours.length} working hour entries for orgId=$orgId',
      );

      final now = DateTime.now();
      // dayOfWeek in entity: 0=Monday … 6=Sunday; DateTime.weekday: 1=Mon … 7=Sun
      final todayIndex = now.weekday - 1;
      final today = workingHours.where((wh) => wh.dayOfWeek == todayIndex);
      _logger.debug(
        '_deriveIsCurrentlyOpen: todayIndex=$todayIndex, entryFound=${today.isNotEmpty}',
      );

      if (today.isEmpty || !today.first.isOpen) {
        _logger.debug(
          '_deriveIsCurrentlyOpen: no entry for today or isOpen=false → closed',
        );
        return false;
      }

      final wh = today.first;
      final open = _parseTime(wh.openTime, now);
      final close = _parseTime(wh.closeTime, now);
      _logger.debug(
        '_deriveIsCurrentlyOpen: openTime=${wh.openTime}, closeTime=${wh.closeTime}, now=$now',
      );

      if (now.isBefore(open) || now.isAfter(close)) {
        _logger.debug(
          '_deriveIsCurrentlyOpen: now is outside open–close window → closed',
        );
        return false;
      }

      if (wh.breakStart != null && wh.breakEnd != null) {
        final breakStart = _parseTime(wh.breakStart!, now);
        final breakEnd = _parseTime(wh.breakEnd!, now);
        _logger.debug(
          '_deriveIsCurrentlyOpen: breakWindow=${wh.breakStart}–${wh.breakEnd}',
        );
        if (!now.isBefore(breakStart) && now.isBefore(breakEnd)) {
          _logger.debug(
            '_deriveIsCurrentlyOpen: now is inside break window → closed',
          );
          return false;
        }
      }

      _logger.debug('_deriveIsCurrentlyOpen: organisation is open');
      return true;
    } catch (e) {
      _logger.error('Failed to derive organization open status: $e');
      return false;
    }
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
