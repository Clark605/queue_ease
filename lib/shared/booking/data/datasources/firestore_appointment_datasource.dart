import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_status.dart';
import '../models/appointment_model.dart';

/// Firestore datasource for appointment read and write operations.
///
/// Appointments are stored at:
///   `organizations/{orgId}/appointments/{appointmentId}`
@lazySingleton
class FirestoreAppointmentDatasource {
  FirestoreAppointmentDatasource(this._firestore, this._logger);

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
      'FirestoreAppointmentDatasource: getForDateAndService '
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
          .toList();

      _logger.debug(
        'FirestoreAppointmentDatasource: found ${entities.length} appointments',
      );
      return entities;
    } on FirebaseException catch (e, st) {
      _logger.error(
        'FirestoreAppointmentDatasource: getForDateAndService failed',
        e,
        st,
      );
      throw DatabaseException('Failed to fetch appointments.', stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'FirestoreAppointmentDatasource: getForDateAndService unexpected error',
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

  /// Creates an appointment using a pre-conflict-check then Firestore write.
  ///
  /// Queries for existing active appointments at the same [appointment.scheduledAt]
  /// before writing. Throws [ValidationException] on a detected conflict.
  ///
  /// Note: Firestore transactions do not support query reads, so the conflict
  /// check is performed outside the write transaction. This is the standard
  /// Firestore pattern when deterministic document IDs are not used.
  Future<AppointmentEntity> createAppointmentTransactional(
    AppointmentEntity appointment,
  ) async {
    _logger.debug(
      'FirestoreAppointmentDatasource: createTransactional '
      'orgId=${appointment.orgId} serviceId=${appointment.serviceId} '
      'scheduledAt=${appointment.scheduledAt.toIso8601String()}',
    );
    try {
      // Pre-check: query for conflicting active bookings at the same slot.
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
          'FirestoreAppointmentDatasource: slot conflict detected '
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
        'FirestoreAppointmentDatasource: appointment created id=${ref.id}',
      );
      return model.toEntity();
    } on AppException {
      rethrow;
    } on FirebaseException catch (e, st) {
      _logger.error(
        'FirestoreAppointmentDatasource: createTransactional failed',
        e,
        st,
      );
      throw DatabaseException('Failed to save appointment.', stackTrace: st);
    } catch (e, st) {
      _logger.error(
        'FirestoreAppointmentDatasource: createTransactional unexpected error',
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
