import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'firestore.rules includes cancellation transitions and customer rule',
    () async {
      final file = File('firestore.rules');
      final content = await file.readAsString();

      // Ensure cancellationTransition logic exists
      expect(
        content.contains("from == 'inQueue' && to == 'cancelled'"),
        isTrue,
        reason: 'Expected inQueue -> cancelled transition to be whitelisted.',
      );
      expect(
        content.contains("from == 'booked' && to == 'cancelled'"),
        isTrue,
        reason: 'Expected booked -> cancelled transition to be whitelisted.',
      );

      // Ensure customer cancellation update rule allows inQueue cancellations
      expect(
        content.contains(
          "resource.data.status == 'booked' || resource.data.status == 'inQueue'",
        ),
        isTrue,
        reason: 'Expected customer cancellation rule to permit inQueue status.',
      );

      // Ensure affectedKeys check allows updatedAt
      expect(
        content.contains("affectedKeys().hasOnly(['status', 'updatedAt'])"),
        isTrue,
        reason:
            'Expected customer cancellation update to allow updatedAt only.',
      );
    },
  );
}
