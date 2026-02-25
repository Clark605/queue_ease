import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_status.dart';

/// Data model for [AppointmentEntity] with Firestore serialization.
class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.orgId,
    required this.serviceId,
    required this.customerId,
    required this.customerName,
    required this.scheduledAt,
    required this.status,
    required this.createdAt,
    this.customerPhone,
    this.queuePosition,
  });

  final String id;
  final String orgId;
  final String serviceId;
  final String customerId;
  final String customerName;
  final DateTime scheduledAt;
  final AppointmentStatus status;
  final DateTime createdAt;
  final String? customerPhone;
  final int? queuePosition;

  /// Creates an [AppointmentModel] from a Firestore document.
  ///
  /// The [orgId] parameter is required since appointments are stored in a
  /// subcollection and the parent org ID is not in the document itself.
  factory AppointmentModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String orgId,
  }) {
    final data = doc.data()!;
    final statusValue =
        data['status'] as String? ?? AppointmentStatus.booked.name;
    final status = AppointmentStatus.values.firstWhere(
      (s) => s.name == statusValue,
      orElse: () => AppointmentStatus.booked,
    );

    return AppointmentModel(
      id: doc.id,
      orgId: orgId,
      serviceId: data['serviceId'] as String,
      customerId: data['customerId'] as String,
      customerName: data['customerName'] as String,
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      status: status,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      customerPhone: data['customerPhone'] as String?,
      queuePosition: data['queuePosition'] as int?,
    );
  }

  /// Converts this model to a Firestore map.
  Map<String, dynamic> toMap() {
    return {
      'orgId': orgId,
      'serviceId': serviceId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status.name,
      'queuePosition': queuePosition,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Converts this model to a domain [AppointmentEntity].
  AppointmentEntity toEntity() => AppointmentEntity(
    id: id,
    orgId: orgId,
    serviceId: serviceId,
    customerId: customerId,
    customerName: customerName,
    scheduledAt: scheduledAt,
    status: status,
    createdAt: createdAt,
    customerPhone: customerPhone,
    queuePosition: queuePosition,
  );
}
