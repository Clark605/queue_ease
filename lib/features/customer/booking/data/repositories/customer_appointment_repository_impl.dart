import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/error/app_exception.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/queue_entity.dart';

import '../../../../shared_domain/entities/appointment_status.dart';
import '../../domain/repositories/customer_appointment_repository.dart';
import '../datasources/customer_appointment_datasource.dart';

@LazySingleton(as: CustomerAppointmentRepository)
class CustomerAppointmentRepositoryImpl
    implements CustomerAppointmentRepository {
  const CustomerAppointmentRepositoryImpl(this._datasource, this._logger);

  final CustomerAppointmentDatasource _datasource;
  final AppLogger _logger;

  String _maskId(String value) {
    if (value.isEmpty) return '***';
    if (value.length <= 4) return '***$value';
    return '***${value.substring(value.length - 4)}';
  }

  String _sanitizeMessage(String message) {
    return message
        .replaceAll(
          RegExp(
            r'customer(Name|Phone)?\s*[:=]\s*[^,\s]+',
            caseSensitive: false,
          ),
          'customer=***',
        )
        .replaceAll(
          RegExp(r'phone\s*[:=]\s*[^,\s]+', caseSensitive: false),
          'phone=***',
        );
  }

  Map<String, Object?> _queueLogContext({
    required String operation,
    required String orgId,
    DateTime? date,
    String? customerId,
  }) {
    return {
      'operation': operation,
      'orgId': _maskId(orgId),
      if (customerId != null) 'customerId': _maskId(customerId),
      if (date != null) 'date': date.toIso8601String().split('T').first,
    };
  }

  @override
  Future<Result<AppointmentEntity>> createAppointment(
    AppointmentEntity appointment,
  ) {
    _logger.info(
      'Customer appointment creation requested',
      _queueLogContext(
        operation: 'createAppointment',
        orgId: appointment.orgId,
        customerId: appointment.customerId,
        date: appointment.scheduledAt,
      ),
    );
    return Result.guard(
      () => _datasource.createAppointmentTransactional(appointment),
    ).then(
      (result) => switch (result) {
        Success() => result,
        Failure(:final exception) => () {
          _logger.error(
            'Customer appointment creation failed',
            _sanitizeMessage(exception.message),
          );
          return result;
        }(),
      },
    );
  }

  @override
  Future<Result<List<AppointmentEntity>>> getAppointmentsForDateAndService({
    required String orgId,
    required String serviceId,
    required DateTime date,
  }) {
    _logger.debug('Customer appointment availability requested', {
      ..._queueLogContext(
        operation: 'getAppointmentsForDateAndService',
        orgId: orgId,
        date: date,
      ),
      'serviceId': _maskId(serviceId),
    });
    return Result.guard(
      () => _datasource.getAppointmentsForDateAndService(
        orgId: orgId,
        serviceId: serviceId,
        date: date,
      ),
    );
  }

  // -- Queue status streams (Phase 4, T021/T022) ----------------------------

  @override
  Stream<Result<AppointmentEntity?>> watchCustomerQueueAppointment({
    required String orgId,
    required String customerId,
    required DateTime date,
  }) {
    _logger.info(
      'Customer queue appointment watch started',
      _queueLogContext(
        operation: 'watchCustomerQueueAppointment',
        orgId: orgId,
        customerId: customerId,
        date: date,
      ),
    );
    return _datasource
        .watchCustomerQueueAppointment(
          orgId: orgId,
          customerId: customerId,
          date: date,
        )
        .transform(
          StreamTransformer<
            AppointmentEntity?,
            Result<AppointmentEntity?>
          >.fromHandlers(
            handleData: (data, sink) => sink.add(Success(data)),
            handleError: (e, st, sink) {
              if (e is AppException) {
                _logger.error(
                  'Customer queue appointment watch failed',
                  _sanitizeMessage(e.message),
                );
                sink.add(Failure(e));
              } else {
                _logger.error(
                  'Customer queue appointment watch unexpected failure',
                  e,
                  st,
                );
                sink.add(
                  Failure(
                    UnknownException(
                      'Unexpected error watching customer queue appointment.',
                      cause: e,
                      stackTrace: st,
                    ),
                  ),
                );
              }
            },
          ),
        );
  }

  @override
  Stream<Result<QueueEntity?>> watchDailyQueue({
    required String orgId,
    required DateTime date,
  }) {
    _logger.info(
      'Customer daily queue watch started',
      _queueLogContext(operation: 'watchDailyQueue', orgId: orgId, date: date),
    );
    return _datasource
        .watchDailyQueueDoc(orgId: orgId, date: date)
        .transform(
          StreamTransformer<QueueEntity?, Result<QueueEntity?>>.fromHandlers(
            handleData: (data, sink) => sink.add(Success(data)),
            handleError: (e, st, sink) {
              if (e is AppException) {
                _logger.error(
                  'Customer daily queue watch failed',
                  _sanitizeMessage(e.message),
                );
                sink.add(Failure(e));
              } else {
                _logger.error(
                  'Customer daily queue watch unexpected failure',
                  e,
                  st,
                );
                sink.add(
                  Failure(
                    UnknownException(
                      'Unexpected error watching daily queue.',
                      cause: e,
                      stackTrace: st,
                    ),
                  ),
                );
              }
            },
          ),
        );
  }

  @override
  Stream<Result<List<QueueAppointmentWaitEntry>>>
  watchQueueAppointmentsForDate({
    required String orgId,
    required DateTime date,
  }) {
    _logger.debug(
      'Customer queue day appointments watch started',
      _queueLogContext(
        operation: 'watchQueueAppointmentsForDate',
        orgId: orgId,
        date: date,
      ),
    );
    return _datasource
        .watchQueueAppointmentsForDate(orgId: orgId, date: date)
        .transform(
          StreamTransformer<
            List<QueueAppointmentWaitEntry>,
            Result<List<QueueAppointmentWaitEntry>>
          >.fromHandlers(
            handleData: (data, sink) => sink.add(Success(data)),
            handleError: (e, st, sink) {
              if (e is AppException) {
                _logger.error(
                  'Customer queue day appointments watch failed',
                  _sanitizeMessage(e.message),
                );
                sink.add(Failure(e));
              } else {
                _logger.error(
                  'Customer queue day appointments watch unexpected failure',
                  e,
                  st,
                );
                sink.add(
                  Failure(
                    UnknownException(
                      'Unexpected error watching queue-day appointments.',
                      cause: e,
                      stackTrace: st,
                    ),
                  ),
                );
              }
            },
          ),
        );
  }

  @override
  Stream<Result<List<AppointmentEntity>>> watchTodayActiveAppointments({
    required String customerId,
    required DateTime date,
  }) {
    _logger.info(
      'Customer today active appointments watch started',
      _queueLogContext(
        operation: 'watchTodayActiveAppointments',
        orgId: '(cross-org)',
        customerId: customerId,
        date: date,
      ),
    );
    return _datasource
        .watchTodayActiveAppointments(customerId: customerId, date: date)
        .transform(
          StreamTransformer<
            List<AppointmentEntity>,
            Result<List<AppointmentEntity>>
          >.fromHandlers(
            handleData: (data, sink) => sink.add(Success(data)),
            handleError: (e, st, sink) {
              if (e is AppException) {
                _logger.error(
                  'Customer today active appointments watch failed',
                  _sanitizeMessage(e.message),
                );
                sink.add(Failure(e));
              } else {
                _logger.error(
                  'Customer today active appointments watch unexpected failure',
                  e,
                  st,
                );
                sink.add(
                  Failure(
                    UnknownException(
                      'Unexpected error watching today\'s appointments.',
                      cause: e,
                      stackTrace: st,
                    ),
                  ),
                );
              }
            },
          ),
        );
  }

  @override
  Future<Result<void>> updateAppointmentStatus({
    required String orgId,
    required String appointmentId,
    required AppointmentStatus status,
  }) {
    _logger.info(
      'Customer appointment status update requested',
      _queueLogContext(
        operation: 'updateAppointmentStatus',
        orgId: orgId,
        customerId: appointmentId,
      ),
    );
    return Result.guard(
      () => _datasource.updateAppointmentStatus(
        orgId: orgId,
        appointmentId: appointmentId,
        status: status.name,
      ),
    );
  }
}
