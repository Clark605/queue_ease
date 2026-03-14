import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_ease/core/error/app_exception.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';
import 'package:queue_ease/features/shared_domain/models/appointment_model.dart';

@lazySingleton
class CustomerAppointmentDatasource {
  CustomerAppointmentDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> _appointments(String orgId) =>
      _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('appointments');

  /// Returns all appointments for [orgId] + [serviceId] on [date].
  ///
  /// Excludes appointments with status [AppointmentStatus.noShow].
  Future<List<AppointmentEntity>> getAppointmentsForDateAndService({
    required String orgId,
    required String serviceId,
    required DateTime date,
  }) async {
    _logger.debug(
      'CustomerAppointmentDatasource: getForDateAndService '
      'orgId=$orgId serviceId=$serviceId date=${date.toIso8601String()}',
    );
    try {
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final snapshot = await _appointments(orgId)
          .where('serviceId', isEqualTo: serviceId)
          .where(
            'scheduledAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart),
          )
          .where('scheduledAt', isLessThan: Timestamp.fromDate(dayEnd))
          .get();

      final entities = snapshot.docs
          .map((doc) => AppointmentModel.fromDoc(doc, orgId: orgId).toEntity())
          .where((e) => e.status != AppointmentStatus.noShow)
          .toList();

      _logger.debug(
        'CustomerAppointmentDatasource: found ${entities.length} appointments',
      );
      return entities;
    } on FirebaseException catch (e, st) {
      _logger.error(
        'CustomerAppointmentDatasource: getForDateAndService failed',
        e,
        st,
      );
      throw DatabaseException('Failed to fetch appointments.', stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'CustomerAppointmentDatasource: getForDateAndService unexpected error',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while fetching appointments.',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Creates an appointment with a pre-conflict-check then Firestore write.
  ///
  /// Queries for existing active appointments at the same slot before writing.
  /// Throws [ValidationException] on a detected conflict.
  Future<AppointmentEntity> createAppointmentTransactional(
    AppointmentEntity appointment,
  ) async {
    _logger.debug(
      'CustomerAppointmentDatasource: createTransactional '
      'orgId=${appointment.orgId} serviceId=${appointment.serviceId} '
      'scheduledAt=${appointment.scheduledAt.toIso8601String()}',
    );
    try {
      final conflict = await _appointments(appointment.orgId)
          .where('serviceId', isEqualTo: appointment.serviceId)
          .where(
            'scheduledAt',
            isEqualTo: Timestamp.fromDate(appointment.scheduledAt),
          )
          .where('status', whereNotIn: [AppointmentStatus.noShow.name])
          .limit(1)
          .get();

      if (conflict.docs.isNotEmpty) {
        _logger.warning(
          'CustomerAppointmentDatasource: slot conflict detected '
          'for scheduledAt=${appointment.scheduledAt.toIso8601String()}',
        );
        throw const ValidationException(
          'This time slot is no longer available. Please pick another.',
        );
      }

      final ref = _appointments(appointment.orgId).doc();
      final model = AppointmentModel.fromEntity(
        AppointmentEntity(
          id: ref.id,
          orgId: appointment.orgId,
          serviceId: appointment.serviceId,
          customerId: appointment.customerId,
          customerName: appointment.customerName,
          customerPhone: appointment.customerPhone,
          scheduledAt: appointment.scheduledAt,
          status: appointment.status,
          queuePosition: appointment.queuePosition,
          createdAt: appointment.createdAt,
        ),
      );

      await ref.set(model.toMap());

      _logger.debug(
        'CustomerAppointmentDatasource: appointment created id=${ref.id}',
      );
      return model.toEntity();
    } on AppException {
      rethrow;
    } on FirebaseException catch (e, st) {
      _logger.error(
        'CustomerAppointmentDatasource: createTransactional failed',
        e,
        st,
      );
      throw DatabaseException('Failed to save appointment.', stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'CustomerAppointmentDatasource: createTransactional unexpected error',
        e,
        st,
      );
      throw UnknownException(
        'An unexpected error occurred while saving the appointment.',
        cause: e,
        stackTrace: st,
      );
    }
  }
}
