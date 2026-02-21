import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/shared/booking/data/models/appointment_model.dart';
import 'package:queue_ease/shared/booking/domain/entities/appointment_entity.dart';
import 'package:queue_ease/shared/booking/domain/entities/appointment_status.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('AppointmentModel', () {
    final testDate = DateTime(2026, 2, 21, 10, 0);
    final testTimestamp = Timestamp.fromDate(testDate);

    test('fromDoc converts Firestore document to AppointmentEntity', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('appt1');
      when(() => mockDoc.data()).thenReturn({
        'serviceId': 'service1',
        'customerId': 'customer1',
        'customerName': 'John Doe',
        'customerPhone': '+1234567890',
        'scheduledAt': testTimestamp,
        'status': 'booked',
        'queuePosition': 5,
        'createdAt': testTimestamp,
      });

      final entity = AppointmentModel.fromDoc(mockDoc, orgId: 'org1');

      expect(entity.id, 'appt1');
      expect(entity.orgId, 'org1');
      expect(entity.serviceId, 'service1');
      expect(entity.customerId, 'customer1');
      expect(entity.customerName, 'John Doe');
      expect(entity.customerPhone, '+1234567890');
      expect(entity.scheduledAt, testDate);
      expect(entity.status, AppointmentStatus.booked);
      expect(entity.queuePosition, 5);
      expect(entity.createdAt, testDate);
    });

    test('fromDoc handles all appointment statuses', () {
      for (final status in AppointmentStatus.values) {
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('appt1');
        when(() => mockDoc.data()).thenReturn({
          'serviceId': 'service1',
          'customerId': 'customer1',
          'customerName': 'John Doe',
          'scheduledAt': testTimestamp,
          'status': status.name,
          'createdAt': testTimestamp,
        });

        final entity = AppointmentModel.fromDoc(mockDoc, orgId: 'org1');

        expect(entity.status, status);
      }
    });

    test('fromDoc handles null optional fields', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('appt1');
      when(() => mockDoc.data()).thenReturn({
        'serviceId': 'service1',
        'customerId': 'customer1',
        'customerName': 'John Doe',
        'scheduledAt': testTimestamp,
        'status': 'booked',
        'createdAt': testTimestamp,
      });

      final entity = AppointmentModel.fromDoc(mockDoc, orgId: 'org1');

      expect(entity.customerPhone, isNull);
      expect(entity.queuePosition, isNull);
    });

    test('fromDoc defaults to booked status for unknown status', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('appt1');
      when(() => mockDoc.data()).thenReturn({
        'serviceId': 'service1',
        'customerId': 'customer1',
        'customerName': 'John Doe',
        'scheduledAt': testTimestamp,
        'status': 'unknown_status',
        'createdAt': testTimestamp,
      });

      final entity = AppointmentModel.fromDoc(mockDoc, orgId: 'org1');

      expect(entity.status, AppointmentStatus.booked);
    });

    test('toMap converts AppointmentEntity to Firestore map', () {
      final entity = AppointmentEntity(
        id: 'appt1',
        orgId: 'org1',
        serviceId: 'service1',
        customerId: 'customer1',
        customerName: 'John Doe',
        customerPhone: '+1234567890',
        scheduledAt: testDate,
        status: AppointmentStatus.inQueue,
        queuePosition: 5,
        createdAt: testDate,
      );

      final map = AppointmentModel.toMap(entity);

      expect(map['orgId'], 'org1');
      expect(map['serviceId'], 'service1');
      expect(map['customerId'], 'customer1');
      expect(map['customerName'], 'John Doe');
      expect(map['customerPhone'], '+1234567890');
      expect(map['scheduledAt'], testTimestamp);
      expect(map['status'], 'inQueue');
      expect(map['queuePosition'], 5);
      expect(map['createdAt'], testTimestamp);
    });

    test('round-trip conversion preserves data', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('appt1');
      when(() => mockDoc.data()).thenReturn({
        'serviceId': 'service1',
        'customerId': 'customer1',
        'customerName': 'John Doe',
        'customerPhone': '+1234567890',
        'scheduledAt': testTimestamp,
        'status': 'serving',
        'queuePosition': 5,
        'createdAt': testTimestamp,
      });

      final entity = AppointmentModel.fromDoc(mockDoc, orgId: 'org1');
      final map = AppointmentModel.toMap(entity);

      expect(map['orgId'], entity.orgId);
      expect(map['serviceId'], entity.serviceId);
      expect(map['customerId'], entity.customerId);
      expect(map['customerName'], entity.customerName);
      expect(map['customerPhone'], entity.customerPhone);
      expect(map['scheduledAt'], Timestamp.fromDate(entity.scheduledAt));
      expect(map['status'], entity.status.name);
      expect(map['queuePosition'], entity.queuePosition);
      expect(map['createdAt'], Timestamp.fromDate(entity.createdAt));
    });
  });
}
