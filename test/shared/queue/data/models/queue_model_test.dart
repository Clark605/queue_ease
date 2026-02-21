import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/shared/queue/data/models/queue_model.dart';
import 'package:queue_ease/shared/queue/domain/entities/queue_entity.dart';
import 'package:queue_ease/shared/queue/domain/entities/queue_status.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('QueueModel', () {
    final testDate = DateTime(2026, 2, 21, 8, 0);
    final testTimestamp = Timestamp.fromDate(testDate);

    test('fromDoc converts Firestore document to QueueEntity', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('2026-02-21');
      when(() => mockDoc.data()).thenReturn({
        'orderedAppointmentIds': ['appt1', 'appt2', 'appt3'],
        'currentServingIndex': 1,
        'status': 'active',
        'generatedAt': testTimestamp,
      });

      final entity = QueueModel.fromDoc(mockDoc, orgId: 'org1');

      expect(entity.id, 'org1_2026-02-21');
      expect(entity.orgId, 'org1');
      expect(entity.date, '2026-02-21');
      expect(entity.orderedAppointmentIds, ['appt1', 'appt2', 'appt3']);
      expect(entity.currentServingIndex, 1);
      expect(entity.status, QueueStatus.active);
      expect(entity.generatedAt, testDate);
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

      final entity = QueueModel.fromDoc(mockDoc, orgId: 'test-org-123');

      expect(entity.id, 'test-org-123_2026-02-21');
      expect(entity.orgId, 'test-org-123');
      expect(entity.date, '2026-02-21');
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

        final entity = QueueModel.fromDoc(mockDoc, orgId: 'org1');

        expect(entity.status, status);
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

      final entity = QueueModel.fromDoc(mockDoc, orgId: 'org1');

      expect(entity.orderedAppointmentIds, isEmpty);
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

      final entity = QueueModel.fromDoc(mockDoc, orgId: 'org1');

      expect(entity.status, QueueStatus.active);
    });

    test('toMap converts QueueEntity to Firestore map', () {
      final entity = QueueEntity(
        id: 'org1_2026-02-21',
        orgId: 'org1',
        date: '2026-02-21',
        orderedAppointmentIds: ['appt1', 'appt2', 'appt3'],
        currentServingIndex: 1,
        status: QueueStatus.paused,
        generatedAt: testDate,
      );

      final map = QueueModel.toMap(entity);

      expect(map['orgId'], 'org1');
      expect(map['orderedAppointmentIds'], ['appt1', 'appt2', 'appt3']);
      expect(map['currentServingIndex'], 1);
      expect(map['status'], 'paused');
      expect(map['generatedAt'], testTimestamp);
      // Note: 'date' is not in the map because it's stored as the document ID
      expect(map.containsKey('date'), false);
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

      final entity = QueueModel.fromDoc(mockDoc, orgId: 'org1');
      final map = QueueModel.toMap(entity);

      expect(map['orgId'], entity.orgId);
      expect(map['orderedAppointmentIds'], entity.orderedAppointmentIds);
      expect(map['currentServingIndex'], entity.currentServingIndex);
      expect(map['status'], entity.status.name);
      expect(map['generatedAt'], Timestamp.fromDate(entity.generatedAt));
    });
  });
}
