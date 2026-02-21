import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_status.dart';

/// Mapper class for converting between [AppointmentEntity] and Firestore documents.
class AppointmentModel {
  /// Converts a Firestore document to an [AppointmentEntity].
  ///
  /// The [orgId] parameter is required since appointments are stored in a
  /// subcollection and the parent org ID is not in the document itself.
  static AppointmentEntity fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String orgId,
  }) {
    final data = doc.data()!;

    // Parse appointment status
    final statusValue =
        data['status'] as String? ?? AppointmentStatus.booked.name;
    final status = AppointmentStatus.values.firstWhere(
      (s) => s.name == statusValue,
      orElse: () => AppointmentStatus.booked,
    );

    return AppointmentEntity(
      id: doc.id,
      orgId: orgId,
      serviceId: data['serviceId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      scheduledAt:
          (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: status,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      customerPhone: data['customerPhone'] as String?,
      queuePosition: data['queuePosition'] as int?,
    );
  }

  /// Converts an [AppointmentEntity] to a Firestore map.
  static Map<String, dynamic> toMap(AppointmentEntity entity) {
    return {
      'orgId': entity.orgId,
      'serviceId': entity.serviceId,
      'customerId': entity.customerId,
      'customerName': entity.customerName,
      'customerPhone': entity.customerPhone,
      'scheduledAt': Timestamp.fromDate(entity.scheduledAt),
      'status': entity.status.name,
      'queuePosition': entity.queuePosition,
      'createdAt': Timestamp.fromDate(entity.createdAt),
    };
  }
}
