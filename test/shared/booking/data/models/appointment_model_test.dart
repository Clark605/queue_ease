import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/shared/booking/data/models/appointment_model.dart';
import 'package:queue_ease/shared/booking/domain/entities/appointment_status.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('AppointmentModel', () {
    final testDate = DateTime(2026, 2, 21, 10, 0);
    final testTimestamp = Timestamp.fromDate(testDate);

    test('fromDoc converts Firestore document to AppointmentModel', () {
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

      final model = AppointmentModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.id, 'appt1');
      expect(model.orgId, 'org1');
      expect(model.serviceId, 'service1');
      expect(model.customerId, 'customer1');
      expect(model.customerName, 'John Doe');
      expect(model.customerPhone, '+1234567890');
      expect(model.scheduledAt, testDate);
      expect(model.status, AppointmentStatus.booked);
      expect(model.queuePosition, 5);
      expect(model.createdAt, testDate);
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

        final model = AppointmentModel.fromDoc(mockDoc, orgId: 'org1');

        expect(model.status, status);
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

      final model = AppointmentModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.customerPhone, isNull);
      expect(model.queuePosition, isNull);
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

      final model = AppointmentModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.status, AppointmentStatus.booked);
    });

    test('toMap converts AppointmentModel to Firestore map', () {
      final model = AppointmentModel(
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

      final map = model.toMap();

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

    test('toEntity converts AppointmentModel to AppointmentEntity', () {
      final model = AppointmentModel(
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

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.orgId, model.orgId);
      expect(entity.serviceId, model.serviceId);
      expect(entity.customerId, model.customerId);
      expect(entity.customerName, model.customerName);
      expect(entity.customerPhone, model.customerPhone);
      expect(entity.scheduledAt, model.scheduledAt);
      expect(entity.status, model.status);
      expect(entity.queuePosition, model.queuePosition);
      expect(entity.createdAt, model.createdAt);
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

      final model = AppointmentModel.fromDoc(mockDoc, orgId: 'org1');
      final map = model.toMap();

      expect(map['orgId'], model.orgId);
      expect(map['serviceId'], model.serviceId);
      expect(map['customerId'], model.customerId);
      expect(map['customerName'], model.customerName);
      expect(map['customerPhone'], model.customerPhone);
      expect(map['scheduledAt'], Timestamp.fromDate(model.scheduledAt));
      expect(map['status'], model.status.name);
      expect(map['queuePosition'], model.queuePosition);
      expect(map['createdAt'], Timestamp.fromDate(model.createdAt));
    });
  });
}
