import 'package:equatable/equatable.dart';

import 'appointment_status.dart';

/// Represents an appointment booked by a customer for a specific service.
///
/// Appointments are created when a customer books a time slot and can
/// transition through various statuses as they move through the queue.
class AppointmentEntity extends Equatable {
  const AppointmentEntity({
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

  /// Unique identifier for the appointment.
  final String id;

  /// Organization ID where the appointment is booked.
  final String orgId;

  /// Service ID for this appointment.
  final String serviceId;

  /// Firebase Auth UID of the customer who booked.
  final String customerId;

  /// Name of the customer.
  final String customerName;

  /// Optional phone number of the customer.
  final String? customerPhone;

  /// Scheduled date and time for the appointment.
  final DateTime scheduledAt;

  /// Current status of the appointment.
  final AppointmentStatus status;

  /// Queue position assigned when the daily queue is generated.
  final int? queuePosition;

  /// Timestamp when the appointment was created.
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    orgId,
    serviceId,
    customerId,
    customerName,
    customerPhone,
    scheduledAt,
    status,
    queuePosition,
    createdAt,
  ];
}
