import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/utils/app_logger.dart';

/// Firestore datasource for all admin queue operations.
///
/// Holds collection-reference helpers for queue documents and appointments.
/// Concrete query/transaction methods are added in Phase 3 per user story.
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

  // ---------------------------------------------------------------------------
  // Queue generation — T029 (Phase 3 / US3)
  // ---------------------------------------------------------------------------

  // TODO(T029): Implement booked-appointment candidate query and queue write.

  // ---------------------------------------------------------------------------
  // Queue watch — T013 (Phase 3 / US1)
  // ---------------------------------------------------------------------------

  // TODO(T013): Implement real-time queue doc + appointment resolution stream.

  // ---------------------------------------------------------------------------
  // Queue action transactions — T013 (Phase 3 / US1)
  // ---------------------------------------------------------------------------

  // TODO(T013): Implement next / skip / noShow / rejoin Firestore transactions.

  // ---------------------------------------------------------------------------
  // Customer queue status — T021 (Phase 4 / US2)
  // ---------------------------------------------------------------------------

  // TODO(T021): Implement customer queue status watch query.
}
