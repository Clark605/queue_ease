import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/shared/queue/domain/entities/queue_entity.dart';
import 'package:queue_ease/shared/queue/domain/entities/queue_status.dart';

void main() {
  group('QueueEntity', () {
    final testDate = DateTime(2026, 2, 21);

    test('supports value equality', () {
      final queue1 = QueueEntity(
        id: 'org1_2026-02-21',
        orgId: 'org1',
        date: '2026-02-21',
        orderedAppointmentIds: ['appt1', 'appt2', 'appt3'],
        currentServingIndex: 0,
        status: QueueStatus.active,
        generatedAt: testDate,
      );

      final queue2 = QueueEntity(
        id: 'org1_2026-02-21',
        orgId: 'org1',
        date: '2026-02-21',
        orderedAppointmentIds: ['appt1', 'appt2', 'appt3'],
        currentServingIndex: 0,
        status: QueueStatus.active,
        generatedAt: testDate,
      );

      expect(queue1, equals(queue2));
    });

    test('different ids are not equal', () {
      final queue1 = QueueEntity(
        id: 'org1_2026-02-21',
        orgId: 'org1',
        date: '2026-02-21',
        orderedAppointmentIds: ['appt1', 'appt2', 'appt3'],
        currentServingIndex: 0,
        status: QueueStatus.active,
        generatedAt: testDate,
      );

      final queue2 = QueueEntity(
        id: 'org1_2026-02-22',
        orgId: 'org1',
        date: '2026-02-22',
        orderedAppointmentIds: ['appt1', 'appt2', 'appt3'],
        currentServingIndex: 0,
        status: QueueStatus.active,
        generatedAt: testDate,
      );

      expect(queue1, isNot(equals(queue2)));
    });

    test('different statuses are not equal', () {
      final queue1 = QueueEntity(
        id: 'org1_2026-02-21',
        orgId: 'org1',
        date: '2026-02-21',
        orderedAppointmentIds: ['appt1', 'appt2', 'appt3'],
        currentServingIndex: 0,
        status: QueueStatus.active,
        generatedAt: testDate,
      );

      final queue2 = QueueEntity(
        id: 'org1_2026-02-21',
        orgId: 'org1',
        date: '2026-02-21',
        orderedAppointmentIds: ['appt1', 'appt2', 'appt3'],
        currentServingIndex: 0,
        status: QueueStatus.paused,
        generatedAt: testDate,
      );

      expect(queue1, isNot(equals(queue2)));
    });

    test('different ordered lists are not equal', () {
      final queue1 = QueueEntity(
        id: 'org1_2026-02-21',
        orgId: 'org1',
        date: '2026-02-21',
        orderedAppointmentIds: ['appt1', 'appt2', 'appt3'],
        currentServingIndex: 0,
        status: QueueStatus.active,
        generatedAt: testDate,
      );

      final queue2 = QueueEntity(
        id: 'org1_2026-02-21',
        orgId: 'org1',
        date: '2026-02-21',
        orderedAppointmentIds: ['appt1', 'appt3', 'appt2'],
        currentServingIndex: 0,
        status: QueueStatus.active,
        generatedAt: testDate,
      );

      expect(queue1, isNot(equals(queue2)));
    });

    test('props includes all fields', () {
      final queue = QueueEntity(
        id: 'org1_2026-02-21',
        orgId: 'org1',
        date: '2026-02-21',
        orderedAppointmentIds: ['appt1', 'appt2', 'appt3'],
        currentServingIndex: 1,
        status: QueueStatus.active,
        generatedAt: testDate,
      );

      expect(queue.props, [
        'org1_2026-02-21',
        'org1',
        '2026-02-21',
        ['appt1', 'appt2', 'appt3'],
        1,
        QueueStatus.active,
        testDate,
      ]);
    });
  });
}
