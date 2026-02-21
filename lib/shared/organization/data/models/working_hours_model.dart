import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/working_hours_entity.dart';

/// Mapper class for converting between [WorkingHoursEntity] and Firestore documents.
class WorkingHoursModel {
  /// Converts a Firestore document to a [WorkingHoursEntity].
  ///
  /// The [orgId] parameter is required since working hours are stored in a
  /// subcollection and the parent org ID is not in the document itself.
  /// The [doc.id] is expected to be the dayOfWeek as a string (e.g., "0", "1", ..., "6").
  static WorkingHoursEntity fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String orgId,
  }) {
    final data = doc.data()!;
    return WorkingHoursEntity(
      orgId: orgId,
      dayOfWeek: int.parse(doc.id),
      isOpen: data['isOpen'] as bool? ?? false,
      openTime: data['openTime'] as String? ?? '09:00',
      closeTime: data['closeTime'] as String? ?? '17:00',
      breakStart: data['breakStart'] as String?,
      breakEnd: data['breakEnd'] as String?,
    );
  }

  /// Converts a [WorkingHoursEntity] to a Firestore map.
  static Map<String, dynamic> toMap(WorkingHoursEntity entity) {
    return {
      'orgId': entity.orgId,
      'isOpen': entity.isOpen,
      'openTime': entity.openTime,
      'closeTime': entity.closeTime,
      'breakStart': entity.breakStart,
      'breakEnd': entity.breakEnd,
    };
  }
}
