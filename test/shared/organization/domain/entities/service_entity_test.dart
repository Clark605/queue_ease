import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/shared/organization/domain/entities/service_entity.dart';

void main() {
  group('ServiceEntity', () {
    final testDate = DateTime(2026, 2, 21);

    test('supports value equality', () {
      final service1 = ServiceEntity(
        id: 'service1',
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 15,
        isActive: true,
        createdAt: testDate,
      );

      final service2 = ServiceEntity(
        id: 'service1',
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 15,
        isActive: true,
        createdAt: testDate,
      );

      expect(service1, equals(service2));
    });

    test('different ids are not equal', () {
      final service1 = ServiceEntity(
        id: 'service1',
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 15,
        isActive: true,
        createdAt: testDate,
      );

      final service2 = ServiceEntity(
        id: 'service2',
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 15,
        isActive: true,
        createdAt: testDate,
      );

      expect(service1, isNot(equals(service2)));
    });

    test('different durations are not equal', () {
      final service1 = ServiceEntity(
        id: 'service1',
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 15,
        isActive: true,
        createdAt: testDate,
      );

      final service2 = ServiceEntity(
        id: 'service1',
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 45,
        timeMarginMinutes: 15,
        isActive: true,
        createdAt: testDate,
      );

      expect(service1, isNot(equals(service2)));
    });

    test('nullable fields are included in equality', () {
      final service1 = ServiceEntity(
        id: 'service1',
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 15,
        isActive: true,
        createdAt: testDate,
        price: 50.0,
      );

      final service2 = ServiceEntity(
        id: 'service1',
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 15,
        isActive: true,
        createdAt: testDate,
        price: 60.0,
      );

      expect(service1, isNot(equals(service2)));
    });

    test('props includes all fields', () {
      final service = ServiceEntity(
        id: 'service1',
        orgId: 'org1',
        name: 'Haircut',
        durationMinutes: 30,
        timeMarginMinutes: 15,
        isActive: true,
        createdAt: testDate,
        price: 50.0,
        queueType: 'Priority',
        description: 'Professional haircut service',
      );

      expect(service.props, [
        'service1',
        'org1',
        'Haircut',
        30,
        15,
        true,
        50.0,
        'Priority',
        'Professional haircut service',
        testDate,
      ]);
    });
  });
}
