import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/shared/organization/domain/entities/organization_entity.dart';

void main() {
  group('OrganizationEntity', () {
    final testDate = DateTime(2026, 2, 21);

    test('supports value equality', () {
      final org1 = OrganizationEntity(
        id: 'org1',
        name: 'Test Clinic',
        adminUid: 'admin123',
        bookingLinkSlug: 'test-clinic',
        isOpen: true,
        createdAt: testDate,
      );

      final org2 = OrganizationEntity(
        id: 'org1',
        name: 'Test Clinic',
        adminUid: 'admin123',
        bookingLinkSlug: 'test-clinic',
        isOpen: true,
        createdAt: testDate,
      );

      expect(org1, equals(org2));
    });

    test('different ids are not equal', () {
      final org1 = OrganizationEntity(
        id: 'org1',
        name: 'Test Clinic',
        adminUid: 'admin123',
        bookingLinkSlug: 'test-clinic',
        isOpen: true,
        createdAt: testDate,
      );

      final org2 = OrganizationEntity(
        id: 'org2',
        name: 'Test Clinic',
        adminUid: 'admin123',
        bookingLinkSlug: 'test-clinic',
        isOpen: true,
        createdAt: testDate,
      );

      expect(org1, isNot(equals(org2)));
    });

    test('different names are not equal', () {
      final org1 = OrganizationEntity(
        id: 'org1',
        name: 'Test Clinic',
        adminUid: 'admin123',
        bookingLinkSlug: 'test-clinic',
        isOpen: true,
        createdAt: testDate,
      );

      final org2 = OrganizationEntity(
        id: 'org1',
        name: 'Different Clinic',
        adminUid: 'admin123',
        bookingLinkSlug: 'test-clinic',
        isOpen: true,
        createdAt: testDate,
      );

      expect(org1, isNot(equals(org2)));
    });

    test('nullable fields are included in equality', () {
      final org1 = OrganizationEntity(
        id: 'org1',
        name: 'Test Clinic',
        adminUid: 'admin123',
        bookingLinkSlug: 'test-clinic',
        isOpen: true,
        createdAt: testDate,
        address: '123 Main St',
      );

      final org2 = OrganizationEntity(
        id: 'org1',
        name: 'Test Clinic',
        adminUid: 'admin123',
        bookingLinkSlug: 'test-clinic',
        isOpen: true,
        createdAt: testDate,
        address: '456 Oak Ave',
      );

      expect(org1, isNot(equals(org2)));
    });

    test('props includes all fields', () {
      final org = OrganizationEntity(
        id: 'org1',
        name: 'Test Clinic',
        adminUid: 'admin123',
        bookingLinkSlug: 'test-clinic',
        isOpen: true,
        createdAt: testDate,
        qrCodeUrl: 'https://example.com/qr.png',
        address: '123 Main St',
        logoUrl: 'https://example.com/logo.png',
        description: 'A test clinic',
      );

      expect(org.props, [
        'org1',
        'Test Clinic',
        'admin123',
        'test-clinic',
        'https://example.com/qr.png',
        '123 Main St',
        true,
        'https://example.com/logo.png',
        'A test clinic',
        testDate,
      ]);
    });
  });
}
