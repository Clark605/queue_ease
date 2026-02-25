import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/shared/booking/domain/entities/appointment_entity.dart';
import 'package:queue_ease/shared/booking/domain/entities/appointment_status.dart';

void main() {
  group('AppointmentEntity', () {
    final testDate = DateTime(2026, 2, 21, 10, 0);

    test('supports value equality', () {
      final appointment1 = AppointmentEntity(
        id: 'appt1',
        orgId: 'org1',
        serviceId: 'service1',
        customerId: 'customer1',
        customerName: 'John Doe',
        scheduledAt: testDate,
        status: AppointmentStatus.booked,
        createdAt: testDate,
      );

      final appointment2 = AppointmentEntity(
        id: 'appt1',
        orgId: 'org1',
        serviceId: 'service1',
        customerId: 'customer1',
        customerName: 'John Doe',
        scheduledAt: testDate,
        status: AppointmentStatus.booked,
        createdAt: testDate,
      );

      expect(appointment1, equals(appointment2));
    });

    test('different ids are not equal', () {
      final appointment1 = AppointmentEntity(
        id: 'appt1',
        orgId: 'org1',
        serviceId: 'service1',
        customerId: 'customer1',
        customerName: 'John Doe',
        scheduledAt: testDate,
        status: AppointmentStatus.booked,
        createdAt: testDate,
      );

      final appointment2 = AppointmentEntity(
        id: 'appt2',
        orgId: 'org1',
        serviceId: 'service1',
        customerId: 'customer1',
        customerName: 'John Doe',
        scheduledAt: testDate,
        status: AppointmentStatus.booked,
        createdAt: testDate,
      );

      expect(appointment1, isNot(equals(appointment2)));
    });

    test('different statuses are not equal', () {
      final appointment1 = AppointmentEntity(
        id: 'appt1',
        orgId: 'org1',
        serviceId: 'service1',
        customerId: 'customer1',
        customerName: 'John Doe',
        scheduledAt: testDate,
        status: AppointmentStatus.booked,
        createdAt: testDate,
      );

      final appointment2 = AppointmentEntity(
        id: 'appt1',
        orgId: 'org1',
        serviceId: 'service1',
        customerId: 'customer1',
        customerName: 'John Doe',
        scheduledAt: testDate,
        status: AppointmentStatus.serving,
        createdAt: testDate,
      );

      expect(appointment1, isNot(equals(appointment2)));
    });

    test('nullable fields are included in equality', () {
      final appointment1 = AppointmentEntity(
        id: 'appt1',
        orgId: 'org1',
        serviceId: 'service1',
        customerId: 'customer1',
        customerName: 'John Doe',
        scheduledAt: testDate,
        status: AppointmentStatus.booked,
        createdAt: testDate,
        queuePosition: 5,
      );

      final appointment2 = AppointmentEntity(
        id: 'appt1',
        orgId: 'org1',
        serviceId: 'service1',
        customerId: 'customer1',
        customerName: 'John Doe',
        scheduledAt: testDate,
        status: AppointmentStatus.booked,
        createdAt: testDate,
        queuePosition: 6,
      );

      expect(appointment1, isNot(equals(appointment2)));
    });

    test('props includes all fields', () {
      final appointment = AppointmentEntity(
        id: 'appt1',
        orgId: 'org1',
        serviceId: 'service1',
        customerId: 'customer1',
        customerName: 'John Doe',
        scheduledAt: testDate,
        status: AppointmentStatus.booked,
        createdAt: testDate,
        customerPhone: '+1234567890',
        queuePosition: 5,
      );

      expect(appointment.props, [
        'appt1',
        'org1',
        'service1',
        'customer1',
        'John Doe',
        '+1234567890',
        testDate,
        AppointmentStatus.booked,
        5,
        testDate,
      ]);
    });
  });
}
