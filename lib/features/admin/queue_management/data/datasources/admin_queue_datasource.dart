import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/utils/app_logger.dart';

/// Firestore datasource for all admin queue operations.
///
/// Holds collection-reference helpers for queue documents and appointments.
/// Transaction methods enforce Firestore's read-before-write ordering: all
/// [Transaction.get] calls are issued before any [Transaction.update] call.
@lazySingleton
class AdminQueueDatasource {
  AdminQueueDatasource(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  // ---------------------------------------------------------------------------
  // Collection helpers
  // ---------------------------------------------------------------------------

  DocumentReference<Map<String, dynamic>> queueDoc(String orgId, String date) =>
      _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('queues')
          .doc(date);

  CollectionReference<Map<String, dynamic>> appointments(String orgId) =>
      _firestore
          .collection('organizations')
          .doc(orgId)
          .collection('appointments');

  CollectionReference<Map<String, dynamic>> services(String orgId) =>
      _firestore.collection('organizations/$orgId/services');

  // ---------------------------------------------------------------------------
  // Queue generation — T029 (Phase 3 / US3)
  // ---------------------------------------------------------------------------

  /// Generates the daily queue for [orgId] on [date] (formatted as 'yyyy-MM-dd').
  ///
  /// Fetches booked appointments, then creates or idempotently refreshes the
  /// queue document using a [WriteBatch].
  ///
  /// **Fresh queue** (queue doc does not yet exist):
  /// - Creates queue doc with all sorted booked IDs.
  /// - Sets all appointments to `inQueue` (valid: `booked → inQueue`).
  ///
  /// **Existing queue** (queue doc already exists):
  /// - Finds new booked appointments whose IDs are NOT in the existing list.
  /// - Appends them to the end of `orderedAppointmentIds` and sets each to
  ///   `inQueue`. Does not touch `currentServingIndex`.
  /// - If no new appointments are found, returns immediately (true no-op).
  ///
  /// Throws [DatabaseException] on Firestore errors.
  Future<void> generateDailyQueue({
    required String orgId,
    required String date,
  }) async {
    try {
      // 1. Compute day boundaries from the date string.
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      final startOfDay = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );
      final endOfDay = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        23,
        59,
        59,
      );

      // 2. Query all booked appointments for the day, ordered by scheduledAt.
      final querySnap = await appointments(orgId)
          .where('status', isEqualTo: 'booked')
          .where(
            'scheduledAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            'scheduledAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          )
          .orderBy('scheduledAt')
          .get();

      // 3. Early exit when nothing is bookable.
      if (querySnap.docs.isEmpty) {
        _logger.info(
          'AdminQueueDatasource.generateDailyQueue',
          'No booked appointments found for $orgId on $date — no-op',
        );
        return;
      }

      // 4. Extract sorted appointment IDs from the query result.
      final sortedIds = querySnap.docs.map((doc) => doc.id).toList();

      // 5. Read the existing queue document.
      final queueRef = queueDoc(orgId, date);
      final queueSnap = await queueRef.get();
      // 6. Build a WriteBatch for all Firestore writes.
      final batch = _firestore.batch();

      if (!queueSnap.exists) {
        // --- Fresh queue -------------------------------------------------------
        // Create the queue document.
        batch.set(queueRef, {
          'orgId': orgId,
          'date': date,
          'orderedAppointmentIds': sortedIds,
          'currentServingIndex': 0,
          'status': 'active',
          'generatedAt': FieldValue.serverTimestamp(),
        });

        // All appointments → inQueue (booked → inQueue is the only valid
        // transition from booked per Firestore rules).
        for (final id in sortedIds) {
          batch.update(appointments(orgId).doc(id), {'status': 'inQueue'});
        }
      } else {
        // --- Existing queue ----------------------------------------------------
        final queueData = queueSnap.data()!;
        final existingIds = List<String>.from(
          queueData['orderedAppointmentIds'] as List? ?? [],
        );
        final existingIdSet = existingIds.toSet();

        // Find appointments not yet tracked in the queue.
        final newIds = sortedIds
            .where((id) => !existingIdSet.contains(id))
            .toList();

        if (newIds.isEmpty) {
          _logger.info(
            'AdminQueueDatasource.generateDailyQueue',
            'Queue already up to date for $orgId on $date — no-op',
          );
          return;
        }

        // Append new IDs and update all new appointments to inQueue.
        final updatedIds = [...existingIds, ...newIds];
        batch.update(queueRef, {'orderedAppointmentIds': updatedIds});

        for (final id in newIds) {
          batch.update(appointments(orgId).doc(id), {'status': 'inQueue'});
        }
      }

      // 7. Commit all writes atomically.
      await batch.commit();

      _logger.info(
        'AdminQueueDatasource.generateDailyQueue',
        'Queue generated for $orgId on $date '
            '(${sortedIds.length} appointment(s))',
      );
    } on ValidationException {
      rethrow;
    } on FirebaseException catch (e, st) {
      throw DatabaseException(
        'Failed to generate daily queue: ${e.message}',
        stackTrace: st,
      );
    } catch (e, st) {
      throw UnknownException(
        'Unexpected error generating daily queue',
        cause: e,
        stackTrace: st,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Queue watch — T013 (Phase 3 / US1)
  // ---------------------------------------------------------------------------

  /// Watches the daily queue document at `organizations/{orgId}/queues/{date}`.
  ///
  /// Emits the raw document data map, or `null` when the document does not
  /// yet exist. Does not wrap in [Result] — the repository handles that.
  Stream<Map<String, dynamic>?> watchDailyQueue(String orgId, String date) {
    _logger.debug('AdminQueueDatasource.watchDailyQueue', '$orgId/$date');
    return queueDoc(
      orgId,
      date,
    ).snapshots().map((snap) => snap.exists ? snap.data() : null);
  }

  /// Watches all appointments for [orgId] whose `scheduledAt` falls within
  /// the calendar day represented by [date] (00:00:00 – 23:59:59 local time).
  ///
  /// Returns typed snapshots so callers can access `.data()` without casting.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  watchAppointmentsByDate(String orgId, DateTime date) {
    _logger.debug(
      'AdminQueueDatasource.watchAppointmentsByDate',
      '$orgId/$date',
    );
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return appointments(orgId)
        .where(
          'scheduledAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('scheduledAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snap) => snap.docs);
  }

  // ---------------------------------------------------------------------------
  // Queue action transactions — T013 (Phase 3 / US1)
  // ---------------------------------------------------------------------------

  /// Marks the current serving appointment as [completed] and advances the
  /// queue pointer.
  ///
  /// Preconditions (validated inside the transaction):
  /// - Queue document exists for [date].
  /// - Appointment [appointmentId] has status `serving`.
  /// - `orderedAppointmentIds[currentServingIndex] == appointmentId`.
  ///
  /// Throws [ValidationException] when a precondition fails.
  /// Throws [DatabaseException] on Firestore errors.
  Future<void> transactionNext({
    required String orgId,
    required String date,
    required String appointmentId,
  }) async {
    try {
      await _firestore.runTransaction((txn) async {
        final queueRef = queueDoc(orgId, date);
        final appointmentRef = appointments(orgId).doc(appointmentId);

        // All reads must precede all writes in a Firestore transaction.
        final queueSnap = await txn.get(queueRef);
        final appointmentSnap = await txn.get(appointmentRef);

        if (!queueSnap.exists) {
          throw ValidationException(
            'Queue document does not exist for date $date',
          );
        }

        final queueData = queueSnap.data()!;
        final appointmentData = appointmentSnap.data();

        if (appointmentData == null) {
          throw ValidationException('Appointment $appointmentId not found');
        }

        final currentStatus = appointmentData['status'] as String?;
        if (currentStatus != 'serving') {
          throw ValidationException(
            'Appointment $appointmentId is not currently serving '
            '(status: $currentStatus)',
          );
        }

        final orderedIds = List<String>.from(
          queueData['orderedAppointmentIds'] as List? ?? [],
        );
        final currentIndex = queueData['currentServingIndex'] as int? ?? 0;

        if (currentIndex >= orderedIds.length ||
            orderedIds[currentIndex] != appointmentId) {
          throw ValidationException(
            'Appointment $appointmentId is not the current serving entry',
          );
        }

        final nextIndex = currentIndex + 1;

        // Writes after all reads.
        txn.update(appointmentRef, {'status': 'completed'});
        txn.update(queueRef, {'currentServingIndex': nextIndex});
      });
      _logger.info(
        'AdminQueueDatasource.transactionNext',
        'Advanced queue for $orgId on $date — completed $appointmentId',
      );
    } on ValidationException {
      rethrow;
    } on FirebaseException catch (e, st) {
      throw DatabaseException(
        'Failed to advance queue: ${e.message}',
        stackTrace: st,
      );
    } catch (e, st) {
      throw UnknownException(
        'Unexpected error advancing queue',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Moves the current front appointment to the end of the queue.
  ///
  /// Status transition: serving → inQueue OR inQueue → inQueue.
  /// `currentServingIndex` is unchanged; the list re-order shifts the
  /// next entry into the front slot.
  ///
  /// Throws [ValidationException] when a precondition fails.
  /// Throws [DatabaseException] on Firestore errors.
  Future<void> transactionSkip({
    required String orgId,
    required String date,
    required String appointmentId,
  }) async {
    try {
      await _firestore.runTransaction((txn) async {
        final queueRef = queueDoc(orgId, date);
        final appointmentRef = appointments(orgId).doc(appointmentId);

        final queueSnap = await txn.get(queueRef);
        final appointmentSnap = await txn.get(appointmentRef);

        if (!queueSnap.exists) {
          throw ValidationException(
            'Queue document does not exist for date $date',
          );
        }

        final queueData = queueSnap.data()!;
        final appointmentData = appointmentSnap.data();

        if (appointmentData == null) {
          throw ValidationException('Appointment $appointmentId not found');
        }

        final currentStatus = appointmentData['status'] as String?;
        final isSkippable =
            currentStatus == 'serving' || currentStatus == 'inQueue';
        if (!isSkippable) {
          throw ValidationException(
            'Appointment $appointmentId cannot be skipped '
            '(status: $currentStatus)',
          );
        }

        final orderedIds = List<String>.from(
          queueData['orderedAppointmentIds'] as List? ?? [],
        );
        final currentIndex = queueData['currentServingIndex'] as int? ?? 0;

        if (currentIndex >= orderedIds.length ||
            orderedIds[currentIndex] != appointmentId) {
          throw ValidationException(
            'Appointment $appointmentId is not the current serving entry',
          );
        }

        // Remove from current position, append to end.
        orderedIds.removeAt(currentIndex);
        orderedIds.add(appointmentId);

        // Writes after all reads.
        if (currentStatus == 'serving') {
          txn.update(appointmentRef, {'status': 'inQueue'});
        }
        txn.update(queueRef, {'orderedAppointmentIds': orderedIds});
      });
      _logger.info(
        'AdminQueueDatasource.transactionSkip',
        'Skipped $appointmentId for $orgId on $date',
      );
    } on ValidationException {
      rethrow;
    } on FirebaseException catch (e, st) {
      throw DatabaseException(
        'Failed to skip appointment: ${e.message}',
        stackTrace: st,
      );
    } catch (e, st) {
      throw UnknownException(
        'Unexpected error skipping appointment',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Marks the current front appointment as no-show and advances pointer.
  ///
  /// Status transition: inQueue → noShow.
  ///
  /// Throws [ValidationException] when a precondition fails.
  /// Throws [DatabaseException] on Firestore errors.
  Future<void> transactionMarkNoShow({
    required String orgId,
    required String date,
    required String appointmentId,
  }) async {
    try {
      await _firestore.runTransaction((txn) async {
        final queueRef = queueDoc(orgId, date);
        final appointmentRef = appointments(orgId).doc(appointmentId);

        final queueSnap = await txn.get(queueRef);
        final appointmentSnap = await txn.get(appointmentRef);

        if (!queueSnap.exists) {
          throw ValidationException(
            'Queue document does not exist for date $date',
          );
        }

        final queueData = queueSnap.data()!;
        final appointmentData = appointmentSnap.data();

        if (appointmentData == null) {
          throw ValidationException('Appointment $appointmentId not found');
        }

        final currentStatus = appointmentData['status'] as String?;
        if (currentStatus != 'inQueue') {
          throw ValidationException(
            'Appointment $appointmentId is not currently in queue '
            '(status: $currentStatus)',
          );
        }

        final orderedIds = List<String>.from(
          queueData['orderedAppointmentIds'] as List? ?? [],
        );
        final currentIndex = queueData['currentServingIndex'] as int? ?? 0;

        if (currentIndex >= orderedIds.length ||
            orderedIds[currentIndex] != appointmentId) {
          throw ValidationException(
            'Appointment $appointmentId is not the current serving entry',
          );
        }

        final nextIndex = currentIndex + 1;

        txn.update(appointmentRef, {'status': 'noShow'});
        txn.update(queueRef, {'currentServingIndex': nextIndex});
      });
      _logger.info(
        'AdminQueueDatasource.transactionMarkNoShow',
        'Marked $appointmentId as no-show for $orgId on $date',
      );
    } on ValidationException {
      rethrow;
    } on FirebaseException catch (e, st) {
      throw DatabaseException(
        'Failed to mark no-show: ${e.message}',
        stackTrace: st,
      );
    } catch (e, st) {
      throw UnknownException(
        'Unexpected error marking no-show',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Marks a current front overdue non-serving entry as no-show.
  Future<void> transactionMarkOverdueNoShow({
    required String orgId,
    required String date,
    required String appointmentId,
  }) {
    return transactionMarkNoShow(
      orgId: orgId,
      date: date,
      appointmentId: appointmentId,
    );
  }

  /// Explicitly starts serving for the current front queue entry.
  ///
  /// Status transition: `inQueue → serving`.
  Future<void> transactionStartServing({
    required String orgId,
    required String date,
    required String appointmentId,
  }) async {
    try {
      await _firestore.runTransaction((txn) async {
        final queueRef = queueDoc(orgId, date);
        final appointmentRef = appointments(orgId).doc(appointmentId);

        final queueSnap = await txn.get(queueRef);
        final appointmentSnap = await txn.get(appointmentRef);

        if (!queueSnap.exists) {
          throw ValidationException(
            'Queue document does not exist for date $date',
          );
        }

        final queueData = queueSnap.data()!;
        final appointmentData = appointmentSnap.data();

        if (appointmentData == null) {
          throw ValidationException('Appointment $appointmentId not found');
        }

        final orderedIds = List<String>.from(
          queueData['orderedAppointmentIds'] as List? ?? [],
        );
        final currentIndex = queueData['currentServingIndex'] as int? ?? 0;

        if (currentIndex >= orderedIds.length ||
            orderedIds[currentIndex] != appointmentId) {
          throw ValidationException(
            'Appointment $appointmentId is not the current queue entry',
          );
        }

        final status = appointmentData['status'] as String?;
        if (status != 'inQueue') {
          throw ValidationException(
            'Appointment $appointmentId cannot start serving (status: $status)',
          );
        }

        txn.update(appointmentRef, {'status': 'serving'});
        // Touch the queue document so the watchDailyQueue Firestore stream
        // re-fires and the snapshot reflects the new 'serving' status.
        txn.update(queueRef, {'updatedAt': FieldValue.serverTimestamp()});
      });

      _logger.info(
        'AdminQueueDatasource.transactionStartServing',
        'Started serving $appointmentId for $orgId on $date',
      );
    } on ValidationException {
      rethrow;
    } on FirebaseException catch (e, st) {
      throw DatabaseException(
        'Failed to start serving: ${e.message}',
        stackTrace: st,
      );
    } catch (e, st) {
      throw UnknownException(
        'Unexpected error starting serving',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Rejoins a no-show appointment by appending it to the end of
  /// `orderedAppointmentIds` and refreshing its booking-time eligibility.
  /// `currentServingIndex` is NOT changed.
  ///
  /// Status transition: noShow → inQueue.
  ///
  /// Throws [ValidationException] when a precondition fails.
  /// Throws [DatabaseException] on Firestore errors.
  Future<void> transactionRejoin({
    required String orgId,
    required String date,
    required String appointmentId,
  }) async {
    try {
      await _firestore.runTransaction((txn) async {
        final queueRef = queueDoc(orgId, date);
        final appointmentRef = appointments(orgId).doc(appointmentId);

        final queueSnap = await txn.get(queueRef);
        final appointmentSnap = await txn.get(appointmentRef);

        if (!queueSnap.exists) {
          throw ValidationException(
            'Queue document does not exist for date $date',
          );
        }

        final queueData = queueSnap.data()!;
        final appointmentData = appointmentSnap.data();

        if (appointmentData == null) {
          throw ValidationException('Appointment $appointmentId not found');
        }

        final currentStatus = appointmentData['status'] as String?;
        if (currentStatus != 'noShow') {
          throw ValidationException(
            'Appointment $appointmentId is not a no-show '
            '(status: $currentStatus)',
          );
        }

        final orderedIds = List<String>.from(
          queueData['orderedAppointmentIds'] as List? ?? [],
        );

        orderedIds.removeWhere((id) => id == appointmentId);
        orderedIds.add(appointmentId);

        txn.update(appointmentRef, {'status': 'inQueue'});
        txn.update(queueRef, {'orderedAppointmentIds': orderedIds});
        // currentServingIndex is intentionally unchanged.
      });
      _logger.info(
        'AdminQueueDatasource.transactionRejoin',
        'Rejoined $appointmentId for $orgId on $date',
      );
    } on ValidationException {
      rethrow;
    } on FirebaseException catch (e, st) {
      throw DatabaseException(
        'Failed to rejoin appointment: ${e.message}',
        stackTrace: st,
      );
    } catch (e, st) {
      throw UnknownException(
        'Unexpected error rejoining appointment',
        cause: e,
        stackTrace: st,
      );
    }
  }
}
