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
  /// - After the batch commits, promotes the first entry to `serving`
  ///   (valid: `inQueue → serving`) in a separate write.
  ///   The two-step approach satisfies `isValidStatusTransition` in Firestore rules.
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
      final isFreshQueue = !queueSnap.exists;

      // 6. Build a WriteBatch for all Firestore writes.
      final batch = _firestore.batch();
      String? servingPromotionId;

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
        // transition from booked per Firestore rules). The first entry is
        // promoted to serving after the batch commits (inQueue → serving).
        for (final id in sortedIds) {
          batch.update(appointments(orgId).doc(id), {'status': 'inQueue'});
        }
      } else {
        // --- Existing queue ----------------------------------------------------
        final queueData = queueSnap.data()!;
        final existingIds = List<String>.from(
          queueData['orderedAppointmentIds'] as List? ?? [],
        );
        final currentIndex = queueData['currentServingIndex'] as int? ?? 0;
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

        // If the queue was exhausted (no current serving pointer in-range),
        // promote the pointer target after append so the first active entry
        // is immediately serving.
        if (currentIndex >= existingIds.length &&
            currentIndex < updatedIds.length) {
          servingPromotionId = updatedIds[currentIndex];
        }
      }

      // 7. Commit all writes atomically.
      await batch.commit();

      // 8. For a fresh queue, promote the first entry inQueue → serving so
      //    the admin can immediately call next/skip/markNoShow on it.
      //    This is a separate write because Firestore rules only permit
      //    booked → inQueue directly; inQueue → serving requires its own op.
      if (isFreshQueue && sortedIds.isNotEmpty) {
        await appointments(
          orgId,
        ).doc(sortedIds[0]).update({'status': 'serving'});
      }

      if (!isFreshQueue && servingPromotionId != null) {
        await appointments(
          orgId,
        ).doc(servingPromotionId).update({'status': 'serving'});
      }

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

  /// Marks the current serving appointment as [completed] and promotes the
  /// next entry in `orderedAppointmentIds` to [serving].
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

        if (nextIndex < orderedIds.length) {
          final nextRef = appointments(orgId).doc(orderedIds[nextIndex]);
          txn.update(nextRef, {'status': 'serving'});
        }
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

  /// Moves the current serving appointment to the end of the queue and
  /// promotes the entry that slides into the vacated position.
  ///
  /// Status transition: serving → inQueue.
  /// `currentServingIndex` is unchanged; the list re-order shifts the
  /// next entry into the serving slot.
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

        // Remove from current position, append to end.
        orderedIds.removeAt(currentIndex);
        orderedIds.add(appointmentId);

        // Writes after all reads.
        txn.update(appointmentRef, {'status': 'inQueue'});
        txn.update(queueRef, {'orderedAppointmentIds': orderedIds});

        // The entry now at currentIndex (post-removal) becomes the new current.
        if (currentIndex < orderedIds.length) {
          final newCurrentRef = appointments(
            orgId,
          ).doc(orderedIds[currentIndex]);
          txn.update(newCurrentRef, {'status': 'serving'});
        }
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

  /// Marks the current serving appointment as no-show and promotes the next
  /// entry in `orderedAppointmentIds` to [serving].
  ///
  /// Status transition: serving → noShow.
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

        txn.update(appointmentRef, {'status': 'noShow'});
        txn.update(queueRef, {'currentServingIndex': nextIndex});

        if (nextIndex < orderedIds.length) {
          final nextRef = appointments(orgId).doc(orderedIds[nextIndex]);
          txn.update(nextRef, {'status': 'serving'});
        }
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

  /// Rejoins a no-show appointment by appending it to the end of
  /// `orderedAppointmentIds`. `currentServingIndex` is NOT changed.
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
