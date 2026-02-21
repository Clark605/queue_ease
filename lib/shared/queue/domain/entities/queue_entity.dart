import 'package:equatable/equatable.dart';

import 'queue_status.dart';

/// Represents a daily queue for an organization.
///
/// Each queue manages the order and flow of appointments for a specific date,
/// tracking which appointment is currently being served.
class QueueEntity extends Equatable {
  const QueueEntity({
    required this.id,
    required this.orgId,
    required this.date,
    required this.orderedAppointmentIds,
    required this.currentServingIndex,
    required this.status,
    required this.generatedAt,
  });

  /// Synthesized identifier in format "{orgId}_{date}".
  ///
  /// Note: This is NOT read from the Firestore doc.id (which is just the date).
  /// The model's fromDoc must construct this from orgId + doc.id.
  final String id;

  /// Organization ID this queue belongs to.
  final String orgId;

  /// Date of the queue in "YYYY-MM-DD" format.
  final String date;

  /// Ordered list of appointment IDs in queue sequence.
  final List<String> orderedAppointmentIds;

  /// Index of the appointment currently being served.
  final int currentServingIndex;

  /// Current operational status of the queue.
  final QueueStatus status;

  /// Timestamp when the queue was generated.
  final DateTime generatedAt;

  @override
  List<Object?> get props => [
    id,
    orgId,
    date,
    orderedAppointmentIds,
    currentServingIndex,
    status,
    generatedAt,
  ];
}
