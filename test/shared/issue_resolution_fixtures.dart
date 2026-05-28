import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_status.dart';
import 'package:queue_ease/features/shared_domain/entities/service_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';

DateTime issueResolutionReferenceDate = DateTime.utc(2026, 2, 21, 10, 0);
DateTime issueResolutionCreatedAt = DateTime.utc(2026, 2, 20, 9, 30);

AppointmentEntity issueResolutionAppointment({
  String id = 'appt1',
  String orgId = 'org1',
  String serviceId = 'service1',
  String customerId = 'customer1',
  String customerName = 'Test Customer',
  String? customerPhone,
  DateTime? scheduledAt,
  AppointmentStatus status = AppointmentStatus.booked,
  int? queuePosition,
  DateTime? createdAt,
  String? orgName,
  String? serviceName,
}) {
  return AppointmentEntity(
    id: id,
    orgId: orgId,
    serviceId: serviceId,
    customerId: customerId,
    customerName: customerName,
    customerPhone: customerPhone,
    scheduledAt: scheduledAt ?? issueResolutionReferenceDate,
    status: status,
    queuePosition: queuePosition,
    createdAt: createdAt ?? issueResolutionCreatedAt,
    orgName: orgName,
    serviceName: serviceName,
  );
}

ServiceEntity issueResolutionService({
  String id = 'service1',
  String orgId = 'org1',
  String name = 'Test Service',
  int durationMinutes = 30,
  int timeMarginMinutes = 15,
  bool isActive = true,
  double? price,
  String? queueType,
  String? description,
  DateTime? createdAt,
}) {
  return ServiceEntity(
    id: id,
    orgId: orgId,
    name: name,
    durationMinutes: durationMinutes,
    timeMarginMinutes: timeMarginMinutes,
    isActive: isActive,
    price: price,
    queueType: queueType,
    description: description,
    createdAt: createdAt ?? issueResolutionCreatedAt,
  );
}

WorkingHoursEntity issueResolutionWorkingHours({
  String orgId = 'org1',
  int dayOfWeek = 1,
  bool isOpen = true,
  String openTime = '09:00',
  String closeTime = '17:00',
  String? breakStart,
  String? breakEnd,
}) {
  return WorkingHoursEntity(
    orgId: orgId,
    dayOfWeek: dayOfWeek,
    isOpen: isOpen,
    openTime: openTime,
    closeTime: closeTime,
    breakStart: breakStart,
    breakEnd: breakEnd,
  );
}
