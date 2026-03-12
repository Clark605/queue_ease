import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/result.dart';
import '../../../../shared/organization/domain/repositories/working_hours_repository.dart';
import '../../domain/use_cases/get_organization_by_slug_use_case.dart';
import 'organization_landing_state.dart';

@injectable
class OrganizationLandingCubit extends Cubit<OrganizationLandingState> {
  OrganizationLandingCubit(
    this._getOrganizationBySlug,
    this._workingHoursRepository,
  ) : super(const OrganizationLandingInitial());

  final GetOrganizationBySlugUseCase _getOrganizationBySlug;
  final WorkingHoursRepository _workingHoursRepository;

  Future<void> loadOrganization(String slug) async {
    emit(const OrganizationLandingLoading());

    final result = await _getOrganizationBySlug(slug);

    switch (result) {
      case Failure(:final exception):
        emit(OrganizationLandingError(exception.message));
      case Success(:final data) when data == null:
        emit(const OrganizationLandingNotFound());
      case Success(:final data):
        final org = data!;
        final isOpen = await _deriveIsCurrentlyOpen(org.id);
        emit(OrganizationLandingLoaded(org: org, isCurrentlyOpen: isOpen));
    }
  }

  Future<bool> _deriveIsCurrentlyOpen(String orgId) async {
    try {
      final workingHours = await _workingHoursRepository
          .watchWorkingHours(orgId)
          .first;

      final now = DateTime.now();
      // dayOfWeek in entity: 0=Monday … 6=Sunday; DateTime.weekday: 1=Mon … 7=Sun
      final todayIndex = now.weekday - 1;
      final today = workingHours.where((wh) => wh.dayOfWeek == todayIndex);

      if (today.isEmpty || !today.first.isOpen) return false;

      final wh = today.first;
      final open = _parseTime(wh.openTime, now);
      final close = _parseTime(wh.closeTime, now);

      if (now.isBefore(open) || now.isAfter(close)) return false;

      if (wh.breakStart != null && wh.breakEnd != null) {
        final breakStart = _parseTime(wh.breakStart!, now);
        final breakEnd = _parseTime(wh.breakEnd!, now);
        if (!now.isBefore(breakStart) && now.isBefore(breakEnd)) return false;
      }

      return true;
    } catch (_) {
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
