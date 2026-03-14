import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/error/app_exception.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';

import '../../domain/repositories/admin_working_hours_repository.dart';
import '../datasources/admin_working_hours_datasource.dart';

@LazySingleton(as: AdminWorkingHoursRepository)
class AdminWorkingHoursRepositoryImpl implements AdminWorkingHoursRepository {
  AdminWorkingHoursRepositoryImpl(this._datasource, this._logger);

  final AdminWorkingHoursDatasource _datasource;
  final AppLogger _logger;

  @override
  Stream<List<WorkingHoursEntity>> watchWorkingHours(String orgId) =>
      _datasource.watchWorkingHours(orgId);

  @override
  Future<Result<void>> saveAllWorkingHours({
    required String orgId,
    required List<WorkingHoursEntity> days,
  }) {
    return Result.guard(() async {
      _validateAll(days);
      _logger.debug(
        'AdminWorkingHoursRepository: saveAllWorkingHours → orgId=$orgId',
      );
      await _datasource.saveAll(orgId, days);
    });
  }

  void _validateAll(List<WorkingHoursEntity> days) {
    for (final day in days.where((d) => d.isOpen)) {
      final open = _toMinutes(day.openTime);
      final close = _toMinutes(day.closeTime);
      if (close <= open) {
        throw ValidationException(
          'Day ${day.dayOfWeek}: close time must be after open time.',
          field: 'closeTime',
        );
      }
      if (day.breakStart != null || day.breakEnd != null) {
        if (day.breakStart == null || day.breakEnd == null) {
          throw const ValidationException(
            'Both break start and end are required when a break is set.',
            field: 'breakStart',
          );
        }
        final bs = _toMinutes(day.breakStart!);
        final be = _toMinutes(day.breakEnd!);
        if (bs < open || be > close || be <= bs) {
          throw ValidationException(
            'Day ${day.dayOfWeek}: break must fall within working hours and have a positive duration.',
            field: 'breakStart',
          );
        }
      }
    }
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
