import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/queue_entity.dart';
import '../../domain/entities/queue_status.dart';

/// Mapper class for converting between [QueueEntity] and Firestore documents.
class QueueModel {
  /// Converts a Firestore document to a [QueueEntity].
  ///
  /// The [orgId] parameter is required since queues are stored in a
  /// subcollection and the parent org ID is not in the document itself.
  /// The entity's [id] field is synthesized as "{orgId}_{date}" where
  /// the date comes from [doc.id].
  static QueueEntity fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String orgId,
  }) {
    final data = doc.data()!;

    // Parse queue status
    final statusValue = data['status'] as String? ?? QueueStatus.active.name;
    final status = QueueStatus.values.firstWhere(
      (s) => s.name == statusValue,
      orElse: () => QueueStatus.active,
    );

    // Parse ordered appointment IDs
    final appointmentIds =
        (data['orderedAppointmentIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];

    return QueueEntity(
      id: '${orgId}_${doc.id}', // Synthesized composite ID
      orgId: orgId,
      date: doc.id, // Document ID is the date
      orderedAppointmentIds: appointmentIds,
      currentServingIndex: data['currentServingIndex'] as int? ?? 0,
      status: status,
      generatedAt:
          (data['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts a [QueueEntity] to a Firestore map.
  static Map<String, dynamic> toMap(QueueEntity entity) {
    return {
      'orgId': entity.orgId,
      'orderedAppointmentIds': entity.orderedAppointmentIds,
      'currentServingIndex': entity.currentServingIndex,
      'status': entity.status.name,
      'generatedAt': Timestamp.fromDate(entity.generatedAt),
    };
  }
}
