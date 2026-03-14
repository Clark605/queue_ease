import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/features/shared_domain/models/queue_model.dart';
import 'package:queue_ease/features/shared_domain/entities/queue_status.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('QueueModel', () {
    final testDate = DateTime(2026, 2, 21, 8, 0);
    final testTimestamp = Timestamp.fromDate(testDate);

    test('fromDoc converts Firestore document to QueueModel', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('2026-02-21');
      when(() => mockDoc.data()).thenReturn({
        'orderedAppointmentIds': ['appt1', 'appt2', 'appt3'],
        'currentServingIndex': 1,
        'status': 'active',
        'generatedAt': testTimestamp,
      });

      final model = QueueModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.id, 'org1_2026-02-21');
      expect(model.orgId, 'org1');
      expect(model.date, '2026-02-21');
      expect(model.orderedAppointmentIds, ['appt1', 'appt2', 'appt3']);
      expect(model.currentServingIndex, 1);
      expect(model.status, QueueStatus.active);
      expect(model.generatedAt, testDate);
    });

    test('fromDoc synthesizes composite ID from orgId and date', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('2026-02-21');
      when(() => mockDoc.data()).thenReturn({
        'orderedAppointmentIds': ['appt1'],
        'currentServingIndex': 0,
        'status': 'active',
        'generatedAt': testTimestamp,
      });

      final model = QueueModel.fromDoc(mockDoc, orgId: 'test-org-123');

      expect(model.id, 'test-org-123_2026-02-21');
      expect(model.orgId, 'test-org-123');
      expect(model.date, '2026-02-21');
    });

    test('fromDoc handles all queue statuses', () {
      for (final status in QueueStatus.values) {
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('2026-02-21');
        when(() => mockDoc.data()).thenReturn({
          'orderedAppointmentIds': ['appt1'],
          'currentServingIndex': 0,
          'status': status.name,
          'generatedAt': testTimestamp,
        });

        final model = QueueModel.fromDoc(mockDoc, orgId: 'org1');

        expect(model.status, status);
      }
    });

    test('fromDoc handles empty appointment list', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('2026-02-21');
      when(() => mockDoc.data()).thenReturn({
        'orderedAppointmentIds': [],
        'currentServingIndex': 0,
        'status': 'active',
        'generatedAt': testTimestamp,
      });

      final model = QueueModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.orderedAppointmentIds, isEmpty);
    });

    test('fromDoc defaults to active status for unknown status', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('2026-02-21');
      when(() => mockDoc.data()).thenReturn({
        'orderedAppointmentIds': ['appt1'],
        'currentServingIndex': 0,
        'status': 'unknown_status',
        'generatedAt': testTimestamp,
      });

      final model = QueueModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.status, QueueStatus.active);
    });

    test('toMap converts QueueModel to Firestore map', () {
      final model = QueueModel(
        id: 'org1_2026-02-21',
        orgId: 'org1',
        date: '2026-02-21',
        orderedAppointmentIds: ['appt1', 'appt2', 'appt3'],
        currentServingIndex: 1,
        status: QueueStatus.paused,
        generatedAt: testDate,
      );

      final map = model.toMap();

      expect(map['orgId'], 'org1');
      expect(map['orderedAppointmentIds'], ['appt1', 'appt2', 'appt3']);
      expect(map['currentServingIndex'], 1);
      expect(map['status'], 'paused');
      expect(map['generatedAt'], testTimestamp);
      // Note: 'date' is not in the map because it's stored as the document ID
      expect(map.containsKey('date'), false);
    });

    test('toEntity converts QueueModel to QueueEntity', () {
      final model = QueueModel(
        id: 'org1_2026-02-21',
        orgId: 'org1',
        date: '2026-02-21',
        orderedAppointmentIds: ['appt1', 'appt2'],
        currentServingIndex: 0,
        status: QueueStatus.active,
        generatedAt: testDate,
      );

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.orgId, model.orgId);
      expect(entity.date, model.date);
      expect(entity.orderedAppointmentIds, model.orderedAppointmentIds);
      expect(entity.currentServingIndex, model.currentServingIndex);
      expect(entity.status, model.status);
      expect(entity.generatedAt, model.generatedAt);
    });

    test('round-trip conversion preserves data', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('2026-02-21');
      when(() => mockDoc.data()).thenReturn({
        'orderedAppointmentIds': ['appt1', 'appt2', 'appt3'],
        'currentServingIndex': 1,
        'status': 'closed',
        'generatedAt': testTimestamp,
      });

      final model = QueueModel.fromDoc(mockDoc, orgId: 'org1');
      final map = model.toMap();

      expect(map['orgId'], model.orgId);
      expect(map['orderedAppointmentIds'], model.orderedAppointmentIds);
      expect(map['currentServingIndex'], model.currentServingIndex);
      expect(map['status'], model.status.name);
      expect(map['generatedAt'], Timestamp.fromDate(model.generatedAt));
    });
  });
}
