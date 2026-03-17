import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/queue_entity.dart';
import '../entities/queue_status.dart';

/// Data model for [QueueEntity] with Firestore serialization.
class QueueModel {
  const QueueModel({
    required this.id,
    required this.orgId,
    required this.date,
    required this.orderedAppointmentIds,
    required this.currentServingIndex,
    required this.status,
    required this.generatedAt,
    this.updatedAt,
  });

  final String id;
  final String orgId;

  /// Document ID in Firestore — formatted as "YYYY-MM-DD".
  final String date;
  final List<String> orderedAppointmentIds;
  final int currentServingIndex;
  final QueueStatus status;
  final DateTime generatedAt;
  final DateTime? updatedAt;

  /// Creates a [QueueModel] from a Firestore document.
  ///
  /// The [orgId] parameter is required since queues are stored in a
  /// subcollection and the parent org ID is not in the document itself.
  /// The [id] field is synthesized as "{orgId}_{date}" where the date
  /// comes from [doc.id].
  factory QueueModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String orgId,
  }) {
    final data = doc.data()!;
    final statusValue = data['status'] as String? ?? QueueStatus.active.name;
    final status = QueueStatus.values.firstWhere(
      (s) => s.name == statusValue,
      orElse: () => QueueStatus.active,
    );
    final appointmentIds =
        (data['orderedAppointmentIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final generatedAtValue = data['generatedAt'];
    final fallbackGeneratedAt =
        DateTime.tryParse(doc.id) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final generatedAt = switch (generatedAtValue) {
      Timestamp() => generatedAtValue.toDate(),
      DateTime() => generatedAtValue,
      _ => fallbackGeneratedAt,
    };
    final updatedAtValue = data['updatedAt'];
    final updatedAt = switch (updatedAtValue) {
      Timestamp() => updatedAtValue.toDate(),
      DateTime() => updatedAtValue,
      _ => null,
    };

    return QueueModel(
      id: '${orgId}_${doc.id}',
      orgId: orgId,
      date: doc.id,
      orderedAppointmentIds: appointmentIds,
      currentServingIndex: data['currentServingIndex'] as int? ?? 0,
      status: status,
      generatedAt: generatedAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts this model to a Firestore map.
  Map<String, dynamic> toMap() {
    return {
      'orgId': orgId,
      'orderedAppointmentIds': orderedAppointmentIds,
      'currentServingIndex': currentServingIndex,
      'status': status.name,
      'generatedAt': Timestamp.fromDate(generatedAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Converts this model to a domain [QueueEntity].
  QueueEntity toEntity() => QueueEntity(
    id: id,
    orgId: orgId,
    date: date,
    orderedAppointmentIds: orderedAppointmentIds,
    currentServingIndex: currentServingIndex,
    status: status,
    generatedAt: generatedAt,
    updatedAt: updatedAt,
  );
}
