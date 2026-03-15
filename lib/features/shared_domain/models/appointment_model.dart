import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/appointment_entity.dart';
import '../entities/appointment_status.dart';

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
    this.orgName,
    this.serviceName,
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
  final String? orgName;
  final String? serviceName;

  /// Creates an [AppointmentModel] from a domain [AppointmentEntity].
  ///
  /// Used by the datasource write path: `AppointmentModel.fromEntity(entity).toMap()`.
  AppointmentModel.fromEntity(AppointmentEntity entity)
    : id = entity.id,
      orgId = entity.orgId,
      serviceId = entity.serviceId,
      customerId = entity.customerId,
      customerName = entity.customerName,
      scheduledAt = entity.scheduledAt,
      status = entity.status,
      createdAt = entity.createdAt,
      customerPhone = entity.customerPhone,
      queuePosition = entity.queuePosition,
      orgName = entity.orgName,
      serviceName = entity.serviceName;

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
      orgName: data['orgName'] as String?,
      serviceName: data['serviceName'] as String?,
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
      if (orgName != null) 'orgName': orgName,
      if (serviceName != null) 'serviceName': serviceName,
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
    orgName: orgName,
    serviceName: serviceName,
  );
}
