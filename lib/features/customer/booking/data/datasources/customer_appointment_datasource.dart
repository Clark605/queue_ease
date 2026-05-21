import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:queue_ease/core/error/app_exception.dart';
import 'package:queue_ease/core/utils/app_logger.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';
import 'package:queue_ease/features/shared_domain/models/appointment_model.dart';
import '../../../../../features/shared_domain/entities/queue_entity.dart';
import '../../../../../features/shared_domain/models/queue_model.dart';
import '../../domain/repositories/customer_appointment_repository.dart';

@lazySingleton
class CustomerAppointmentDatasource {
  CustomerAppointmentDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> get _organizations =>
      _firestore.collection('organizations');

  CollectionReference<Map<String, dynamic>> _appointments(String orgId) =>
      _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('appointments');

  CollectionReference<Map<String, dynamic>> _services(String orgId) =>
      _firestore.collection('organizations/$orgId/services');

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

  /// Watches customer's single active queue appointment for [orgId] on [date].
  ///
  /// Queries by customerId + date range, then filters status in memory
  /// (avoids multi-field index on inequality + whereIn).
  /// Returns null if the customer has no trackable appointment for today.
  Stream<AppointmentEntity?> watchCustomerQueueAppointment({
    required String orgId,
    required String customerId,
    required DateTime date,
  }) {
    _logger.debug(
      'CustomerAppointmentDatasource: watchCustomerQueueAppointment '
      'orgId=$orgId customerId=$customerId',
    );
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return _appointments(orgId)
        .where('customerId', isEqualTo: customerId)
        .where(
          'scheduledAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart),
        )
        .where('scheduledAt', isLessThan: Timestamp.fromDate(dayEnd))
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.where((doc) {
            final statusStr = doc.data()['status'] as String?;
            final status = AppointmentStatus.values.firstWhere(
              (s) => s.name == statusStr,
              orElse: () => AppointmentStatus.booked,
            );
            return status == AppointmentStatus.booked ||
                status == AppointmentStatus.inQueue ||
                status == AppointmentStatus.serving ||
                status == AppointmentStatus.noShow;
          });
          if (docs.isEmpty) return null;
          return AppointmentModel.fromDoc(docs.first, orgId: orgId).toEntity();
        })
        .handleError((Object e, StackTrace st) {
          _logger.error(
            'CustomerAppointmentDatasource: watchCustomerQueueAppointment error',
            e,
            st,
          );
          throw DatabaseException(
            'Failed to watch customer queue appointment.',
            stackTrace: st,
          );
        });
  }

  /// Watches the daily queue document for [orgId] on [date].
  ///
  /// Returns [QueueEntity] or null if no queue has been generated yet for
  /// that date.
  Stream<QueueEntity?> watchDailyQueueDoc({
    required String orgId,
    required DateTime date,
  }) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    _logger.debug(
      'CustomerAppointmentDatasource: watchDailyQueueDoc '
      'orgId=$orgId date=$dateKey',
    );

    return _firestore
        .collection('organizations/$orgId/queues')
        .doc(dateKey)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return QueueModel.fromDoc(snapshot, orgId: orgId).toEntity();
        })
        .handleError((Object e, StackTrace st) {
          _logger.error(
            'CustomerAppointmentDatasource: watchDailyQueueDoc error',
            e,
            st,
          );
          throw DatabaseException(
            'Failed to watch daily queue document.',
            stackTrace: st,
          );
        });
  }

  /// Watches all queue-day appointments and resolves service durations.
  ///
  /// Returns minimal [QueueAppointmentWaitEntry] items for wait-time
  /// calculation in customer queue status.
  Stream<List<QueueAppointmentWaitEntry>> watchQueueAppointmentsForDate({
    required String orgId,
    required DateTime date,
  }) {
    _logger.debug(
      'CustomerAppointmentDatasource: watchQueueAppointmentsForDate '
      'orgId=$orgId',
    );

    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return _appointments(orgId)
        .where(
          'scheduledAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart),
        )
        .where('scheduledAt', isLessThan: Timestamp.fromDate(dayEnd))
        .snapshots()
        .asyncMap((snapshot) async {
          final docs = snapshot.docs;
          if (docs.isEmpty) return const <QueueAppointmentWaitEntry>[];

          final serviceIds = docs
              .map((doc) => doc.data()['serviceId'] as String?)
              .whereType<String>()
              .toSet()
              .toList();

          final durationByServiceId = <String, int>{};
          for (final serviceIdChunk in _chunks(serviceIds, 30)) {
            final serviceSnap = await _services(
              orgId,
            ).where(FieldPath.documentId, whereIn: serviceIdChunk).get();
            for (final serviceDoc in serviceSnap.docs) {
              final data = serviceDoc.data();
              final rawDuration = data['durationMinutes'] as int?;
              durationByServiceId[serviceDoc.id] =
                  rawDuration == null || rawDuration < 0 ? 0 : rawDuration;
            }
          }

          return docs
              .map((doc) {
                final data = doc.data();
                final statusName = data['status'] as String?;
                final status = AppointmentStatus.values.firstWhere(
                  (value) => value.name == statusName,
                  orElse: () => AppointmentStatus.booked,
                );
                final serviceId = data['serviceId'] as String?;
                final duration = serviceId == null
                    ? 0
                    : durationByServiceId[serviceId] ?? 0;

                return QueueAppointmentWaitEntry(
                  appointmentId: doc.id,
                  status: status,
                  serviceDurationMinutes: duration,
                );
              })
              .toList(growable: false);
        })
        .handleError((Object e, StackTrace st) {
          _logger.error(
            'CustomerAppointmentDatasource: watchQueueAppointmentsForDate error',
            e,
            st,
          );
          throw DatabaseException(
            'Failed to watch queue-day appointments.',
            stackTrace: st,
          );
        });
  }

  /// Watches the customer's appointments across orgs for the list view.
  ///
  /// Returns appointments within a bounded window anchored at [date]:
  /// - 30 days before [date]
  /// - 7 days after [date]
  /// Includes all appointment statuses, ordered by [scheduledAt].
  /// The orgId is extracted from the document path:
  /// `organizations/{orgId}/appointments/{docId}`.
  Stream<List<AppointmentEntity>> watchCustomerAppointments({
    required String customerId,
    required DateTime date,
  }) {
    _logger.debug(
      'CustomerAppointmentDatasource: watchCustomerAppointments '
      'customerId=$customerId',
    );
    final dayStart = DateTime(date.year, date.month, date.day);
    final windowStart = dayStart.subtract(const Duration(days: 30));
    final windowEnd = dayStart.add(const Duration(days: 7));

    return _firestore
        .collectionGroup('appointments')
        .where('customerId', isEqualTo: customerId)
        .where(
          'scheduledAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(windowStart),
        )
        .where('scheduledAt', isLessThan: Timestamp.fromDate(windowEnd))
        .orderBy('scheduledAt')
        .snapshots()
        .asyncMap(_buildCustomerAppointments)
        .handleError((Object e, StackTrace st) {
          _logger.error(
            'CustomerAppointmentDatasource: watchCustomerAppointments error',
            e,
            st,
          );
          throw DatabaseException(
            'Failed to watch customer appointments.',
            stackTrace: st,
          );
        });
  }

  /// Watches the customer's dashboard appointments across orgs.
  ///
  /// Returns appointments with status in `{booked, inQueue, serving}`:
  /// - `inQueue` / `serving` will only exist for today in practice (set by
  ///   the admin at queue generation time).
  /// - `booked` covers a 30-day horizon, so upcoming future appointments
  ///   are included.
  /// Status filtering is done in memory to avoid a composite index on
  /// inequality range + `whereIn`.
  /// The orgId is extracted from the document path:
  /// `organizations/{orgId}/appointments/{docId}`.
  Stream<List<AppointmentEntity>> watchTodayActiveAppointments({
    required String customerId,
    required DateTime date,
  }) {
    _logger.debug(
      'CustomerAppointmentDatasource: watchTodayActiveAppointments '
      'customerId=$customerId',
    );
    final dayStart = DateTime(date.year, date.month, date.day);
    final horizon = dayStart.add(const Duration(days: 30));

    return _firestore
        .collectionGroup('appointments')
        .where('customerId', isEqualTo: customerId)
        .where(
          'scheduledAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart),
        )
        .where('scheduledAt', isLessThan: Timestamp.fromDate(horizon))
        .orderBy('scheduledAt')
        .snapshots()
        .asyncMap(_buildDashboardAppointments)
        .handleError((Object e, StackTrace st) {
          _logger.error(
            'CustomerAppointmentDatasource: watchTodayActiveAppointments error',
            e,
            st,
          );
          throw DatabaseException(
            'Failed to watch today\'s active appointments.',
            stackTrace: st,
          );
        });
  }

  Future<List<AppointmentEntity>> _buildDashboardAppointments(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final appointmentDocs = snapshot.docs
        .where(_isDashboardAppointment)
        .toList(growable: false);

    return _buildAppointmentsWithNames(appointmentDocs);
  }

  Future<List<AppointmentEntity>> _buildCustomerAppointments(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final appointmentDocs = snapshot.docs.toList(growable: false);

    return _buildAppointmentsWithNames(appointmentDocs);
  }

  Future<List<AppointmentEntity>> _buildAppointmentsWithNames(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> appointmentDocs,
  ) async {
    if (appointmentDocs.isEmpty) {
      return const <AppointmentEntity>[];
    }

    final orgIds = appointmentDocs
        .map((doc) => doc.reference.parent.parent!.id)
        .toSet()
        .toList(growable: false);
    final orgNamesById = await _fetchOrganizationNames(orgIds);
    final serviceNamesByOrgId = await _fetchServiceNames(appointmentDocs);

    return appointmentDocs
        .map((doc) {
          final orgId = doc.reference.parent.parent!.id;
          final appointment = AppointmentModel.fromDoc(
            doc,
            orgId: orgId,
          ).toEntity();
          return AppointmentEntity(
            id: appointment.id,
            orgId: appointment.orgId,
            serviceId: appointment.serviceId,
            customerId: appointment.customerId,
            customerName: appointment.customerName,
            scheduledAt: appointment.scheduledAt,
            status: appointment.status,
            createdAt: appointment.createdAt,
            customerPhone: appointment.customerPhone,
            queuePosition: appointment.queuePosition,
            orgName: orgNamesById[orgId] ?? appointment.orgName,
            serviceName:
                serviceNamesByOrgId[orgId]?[appointment.serviceId] ??
                appointment.serviceName,
          );
        })
        .toList(growable: false);
  }

  bool _isDashboardAppointment(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final statusStr = doc.data()['status'] as String?;
    final status = AppointmentStatus.values.firstWhere(
      (value) => value.name == statusStr,
      orElse: () => AppointmentStatus.booked,
    );

    return status == AppointmentStatus.booked ||
        status == AppointmentStatus.inQueue ||
        status == AppointmentStatus.serving;
  }

  Future<Map<String, String>> _fetchOrganizationNames(
    List<String> orgIds,
  ) async {
    final namesById = <String, String>{};

    for (final orgIdChunk in _chunks(orgIds, 30)) {
      final snapshot = await _organizations
          .where(FieldPath.documentId, whereIn: orgIdChunk)
          .get();

      for (final doc in snapshot.docs) {
        final name = doc.data()['name'] as String?;
        if (name != null && name.isNotEmpty) {
          namesById[doc.id] = name;
        }
      }
    }

    return namesById;
  }

  Future<Map<String, Map<String, String>>> _fetchServiceNames(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> appointmentDocs,
  ) async {
    final serviceIdsByOrgId = <String, Set<String>>{};

    for (final doc in appointmentDocs) {
      final orgId = doc.reference.parent.parent!.id;
      final serviceId = doc.data()['serviceId'] as String?;
      if (serviceId == null || serviceId.isEmpty) {
        continue;
      }

      serviceIdsByOrgId.putIfAbsent(orgId, () => <String>{}).add(serviceId);
    }

    final namesByOrgId = <String, Map<String, String>>{};

    for (final entry in serviceIdsByOrgId.entries) {
      final orgId = entry.key;
      final serviceIds = entry.value.toList(growable: false);
      final serviceNames = <String, String>{};

      for (final serviceIdChunk in _chunks(serviceIds, 30)) {
        final snapshot = await _services(
          orgId,
        ).where(FieldPath.documentId, whereIn: serviceIdChunk).get();

        for (final doc in snapshot.docs) {
          final name = doc.data()['name'] as String?;
          if (name != null && name.isNotEmpty) {
            serviceNames[doc.id] = name;
          }
        }
      }

      namesByOrgId[orgId] = serviceNames;
    }

    return namesByOrgId;
  }

  Iterable<List<T>> _chunks<T>(List<T> values, int size) sync* {
    if (values.isEmpty) return;
    for (var index = 0; index < values.length; index += size) {
      final end = index + size > values.length ? values.length : index + size;
      yield values.sublist(index, end);
    }
  }

  /// Updates the status of a single appointment document.
  Future<void> updateAppointmentStatus({
    required String orgId,
    required String appointmentId,
    required String status,
  }) async {
    _logger.debug(
      'CustomerAppointmentDatasource: updateStatus '
      'orgId=$orgId appointmentId=$appointmentId status=$status',
    );
    try {
      await _appointments(orgId).doc(appointmentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.info(
        'CustomerAppointmentDatasource: status updated successfully',
      );
    } on FirebaseException catch (e, st) {
      _logger.error(
        'CustomerAppointmentDatasource: updateStatus failed',
        e,
        st,
      );
      throw const DatabaseException('Failed to update appointment status.');
    }
  }
}
