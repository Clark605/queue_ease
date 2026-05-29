import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/features/admin/queue_management/data/datasources/admin_queue_datasource.dart';

void main() {
  group('AdminQueueDatasource.findNextInQueueIndex', () {
    test('returns next inQueue index when present after current', () {
      final ordered = ['a', 'b', 'c', 'd', 'e'];
      final statuses = {
        'a': 'completed',
        'b': 'completed',
        'c': 'inQueue',
        'd': 'inQueue',
        'e': 'booked',
      };

      final next = AdminQueueDatasource.findNextInQueueIndex(
        ordered,
        0,
        statuses,
      );
      expect(next, 2);
    });

    test('returns currentIndex+1 when no inQueue found after current', () {
      final ordered = ['a', 'b', 'c'];
      final statuses = {'a': 'completed', 'b': 'noShow', 'c': 'completed'};

      final next = AdminQueueDatasource.findNextInQueueIndex(
        ordered,
        0,
        statuses,
      );
      expect(next, 1);
    });

    test('handles empty tail gracefully', () {
      final ordered = ['a'];
      final statuses = {'a': 'serving'};
      final next = AdminQueueDatasource.findNextInQueueIndex(
        ordered,
        0,
        statuses,
      );
      expect(next, 1);
    });

    test('skips null/missing statuses and still returns default', () {
      final ordered = ['a', 'b', 'c'];
      final statuses = {'a': 'serving'}; // b and c missing
      final next = AdminQueueDatasource.findNextInQueueIndex(
        ordered,
        0,
        statuses,
      );
      expect(next, 1);
    });
  });
}
