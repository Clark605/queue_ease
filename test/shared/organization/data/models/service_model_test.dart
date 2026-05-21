import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/features/shared_domain/models/service_model.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('ServiceModel', () {
    final testDate = DateTime(2026, 2, 21, 10, 0);
    final testTimestamp = Timestamp.fromDate(testDate);

    test('fromDoc converts Firestore document to ServiceModel', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.exists).thenReturn(true);
      when(() => mockDoc.id).thenReturn('service1');
      when(() => mockDoc.data()).thenReturn({
        'name': 'Haircut',
        'durationMinutes': 30,
        'timeMarginMinutes': 5,
        'isActive': true,
        'createdAt': testTimestamp,
        'price': 25,
        'queueType': 'manual',
        'description': 'Basic haircut',
      });

      final model = ServiceModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.id, 'service1');
      expect(model.orgId, 'org1');
      expect(model.name, 'Haircut');
      expect(model.durationMinutes, 30);
      expect(model.timeMarginMinutes, 5);
      expect(model.isActive, true);
      expect(model.createdAt, testDate);
      expect(model.price, 25);
      expect(model.queueType, 'manual');
      expect(model.description, 'Basic haircut');
    });

    test('fromDoc falls back when createdAt is null', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.exists).thenReturn(true);
      when(() => mockDoc.id).thenReturn('service1');
      when(() => mockDoc.data()).thenReturn({
        'name': 'Haircut',
        'durationMinutes': 30,
        'createdAt': null,
      });

      final model = ServiceModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('fromDoc falls back when createdAt is missing', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.exists).thenReturn(true);
      when(() => mockDoc.id).thenReturn('service1');
      when(
        () => mockDoc.data(),
      ).thenReturn({'name': 'Haircut', 'durationMinutes': 30});

      final model = ServiceModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('fromDoc handles DateTime createdAt values', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.exists).thenReturn(true);
      when(() => mockDoc.id).thenReturn('service1');
      when(() => mockDoc.data()).thenReturn({
        'name': 'Haircut',
        'durationMinutes': 30,
        'createdAt': testDate,
      });

      final model = ServiceModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.createdAt, testDate);
    });
  });
}
