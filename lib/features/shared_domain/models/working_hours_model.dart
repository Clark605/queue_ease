import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/working_hours_entity.dart';

/// Data model for [WorkingHoursEntity] with Firestore serialization.
class WorkingHoursModel {
  const WorkingHoursModel({
    required this.orgId,
    required this.dayOfWeek,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    this.breakStart,
    this.breakEnd,
  });

  final String orgId;

  /// Day of the week (0 = Monday, 6 = Sunday), sourced from the document ID.
  final int dayOfWeek;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final String? breakStart;
  final String? breakEnd;

  /// Creates a [WorkingHoursModel] from a Firestore document.
  ///
  /// The [orgId] parameter is required since working hours are stored in a
  /// subcollection and the parent org ID is not in the document itself.
  /// The [doc.id] is expected to be the dayOfWeek as a string (e.g., "0"–"6").
  factory WorkingHoursModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String orgId,
  }) {
    final data = doc.data()!;
    return WorkingHoursModel(
      orgId: orgId,
      dayOfWeek: int.parse(doc.id),
      isOpen: data['isOpen'] as bool? ?? false,
      openTime: data['openTime'] as String? ?? '09:00',
      closeTime: data['closeTime'] as String? ?? '17:00',
      breakStart: data['breakStart'] as String?,
      breakEnd: data['breakEnd'] as String?,
    );
  }

  /// Converts this model to a Firestore map.
  Map<String, dynamic> toMap() {
    return {
      'orgId': orgId,
      'isOpen': isOpen,
      'openTime': openTime,
      'closeTime': closeTime,
      'breakStart': breakStart,
      'breakEnd': breakEnd,
    };
  }

  /// Converts this model to a domain [WorkingHoursEntity].
  WorkingHoursEntity toEntity() => WorkingHoursEntity(
    orgId: orgId,
    dayOfWeek: dayOfWeek,
    isOpen: isOpen,
    openTime: openTime,
    closeTime: closeTime,
    breakStart: breakStart,
    breakEnd: breakEnd,
  );
}
