import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/shared/organization/data/models/service_model.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('ServiceModel', () {
    final testDate = DateTime(2026, 2, 21, 10, 0);
    final testTimestamp = Timestamp.fromDate(testDate);

    test('fromDoc converts Firestore document to ServiceModel', () {
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

      final model = ServiceModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.id, 'service1');
      expect(model.orgId, 'org1');
      expect(model.name, 'Haircut');
      expect(model.durationMinutes, 30);
      expect(model.timeMarginMinutes, 15);
      expect(model.isActive, true);
      expect(model.createdAt, testDate);
      expect(model.price, 50.0);
      expect(model.queueType, 'Priority');
      expect(model.description, 'Professional haircut');
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

      final model = ServiceModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.price, isNull);
      expect(model.queueType, isNull);
      expect(model.description, isNull);
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

      final model = ServiceModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.price, 50.0);
      expect(model.price, isA<double>());
    });

    test('toMap converts ServiceModel to Firestore map', () {
      final model = ServiceModel(
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

      final map = model.toMap();

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

    test('toEntity converts ServiceModel to ServiceEntity', () {
      final model = ServiceModel(
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

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.orgId, model.orgId);
      expect(entity.name, model.name);
      expect(entity.durationMinutes, model.durationMinutes);
      expect(entity.timeMarginMinutes, model.timeMarginMinutes);
      expect(entity.isActive, model.isActive);
      expect(entity.createdAt, model.createdAt);
      expect(entity.price, model.price);
      expect(entity.queueType, model.queueType);
      expect(entity.description, model.description);
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

      final model = ServiceModel.fromDoc(mockDoc, orgId: 'org1');
      final map = model.toMap();

      expect(map['orgId'], model.orgId);
      expect(map['name'], model.name);
      expect(map['durationMinutes'], model.durationMinutes);
      expect(map['timeMarginMinutes'], model.timeMarginMinutes);
      expect(map['isActive'], model.isActive);
      expect(map['createdAt'], Timestamp.fromDate(model.createdAt));
      expect(map['price'], model.price);
      expect(map['queueType'], model.queueType);
      expect(map['description'], model.description);
    });
  });
}
