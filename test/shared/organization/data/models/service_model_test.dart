import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/shared/organization/data/models/service_model.dart';
import 'package:queue_ease/shared/organization/domain/entities/service_entity.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('ServiceModel', () {
    final testDate = DateTime(2026, 2, 21, 10, 0);
    final testTimestamp = Timestamp.fromDate(testDate);

    test('fromDoc converts Firestore document to ServiceEntity', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('service1');
      when(() => mockDoc.data()).thenReturn({
        'name': 'Haircut',
        'durationMinutes': 30,
        'timeMarginMinutes': 15,
        'isActive': true,
        'createdAt': testTimestamp,
        'price': 50.0,
        'queueType': 'Priority',
        'description': 'Professional haircut',
      });

      final entity = ServiceModel.fromDoc(mockDoc, orgId: 'org1');

      expect(entity.id, 'service1');
      expect(entity.orgId, 'org1');
      expect(entity.name, 'Haircut');
      expect(entity.durationMinutes, 30);
      expect(entity.timeMarginMinutes, 15);
      expect(entity.isActive, true);
      expect(entity.createdAt, testDate);
      expect(entity.price, 50.0);
      expect(entity.queueType, 'Priority');
      expect(entity.description, 'Professional haircut');
    });

    test('fromDoc handles null optional fields', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('service1');
      when(() => mockDoc.data()).thenReturn({
        'name': 'Haircut',
        'durationMinutes': 30,
        'timeMarginMinutes': 15,
        'isActive': true,
        'createdAt': testTimestamp,
      });

      final entity = ServiceModel.fromDoc(mockDoc, orgId: 'org1');

      expect(entity.price, isNull);
      expect(entity.queueType, isNull);
      expect(entity.description, isNull);
    });

    test('fromDoc handles int price and converts to double', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('service1');
      when(() => mockDoc.data()).thenReturn({
        'name': 'Haircut',
        'durationMinutes': 30,
        'timeMarginMinutes': 15,
        'isActive': true,
        'createdAt': testTimestamp,
        'price': 50, // int instead of double
      });

      final entity = ServiceModel.fromDoc(mockDoc, orgId: 'org1');

      expect(entity.price, 50.0);
      expect(entity.price, isA<double>());
    });

    test('toMap converts ServiceEntity to Firestore map', () {
      final entity = ServiceEntity(
        id: 'service1',
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 15,
        isActive: true,
        createdAt: testDate,
        price: 50.0,
        queueType: 'Priority',
        description: 'Professional haircut',
      );

      final map = ServiceModel.toMap(entity);

      expect(map['orgId'], 'org1');
      expect(map['name'], 'Haircut');
      expect(map['durationMinutes'], 30);
      expect(map['timeMarginMinutes'], 15);
      expect(map['isActive'], true);
      expect(map['createdAt'], testTimestamp);
      expect(map['price'], 50.0);
      expect(map['queueType'], 'Priority');
      expect(map['description'], 'Professional haircut');
    });

    test('round-trip conversion preserves data', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('service1');
      when(() => mockDoc.data()).thenReturn({
        'name': 'Haircut',
        'durationMinutes': 30,
        'timeMarginMinutes': 15,
        'isActive': true,
        'createdAt': testTimestamp,
        'price': 50.0,
        'queueType': 'Priority',
        'description': 'Professional haircut',
      });

      final entity = ServiceModel.fromDoc(mockDoc, orgId: 'org1');
      final map = ServiceModel.toMap(entity);

      expect(map['orgId'], entity.orgId);
      expect(map['name'], entity.name);
      expect(map['durationMinutes'], entity.durationMinutes);
      expect(map['timeMarginMinutes'], entity.timeMarginMinutes);
      expect(map['isActive'], entity.isActive);
      expect(map['createdAt'], Timestamp.fromDate(entity.createdAt));
      expect(map['price'], entity.price);
      expect(map['queueType'], entity.queueType);
      expect(map['description'], entity.description);
    });
  });
}
