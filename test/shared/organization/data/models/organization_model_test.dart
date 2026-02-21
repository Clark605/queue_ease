import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/shared/organization/data/models/organization_model.dart';
import 'package:queue_ease/shared/organization/domain/entities/organization_entity.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('OrganizationModel', () {
    final testDate = DateTime(2026, 2, 21, 10, 0);
    final testTimestamp = Timestamp.fromDate(testDate);

    test('fromDoc converts Firestore document to OrganizationEntity', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('org1');
      when(() => mockDoc.data()).thenReturn({
        'name': 'Test Clinic',
        'adminUid': 'admin123',
        'bookingLinkSlug': 'test-clinic',
        'isOpen': true,
        'createdAt': testTimestamp,
        'qrCodeUrl': 'https://example.com/qr.png',
        'address': '123 Main St',
        'logoUrl': 'https://example.com/logo.png',
        'description': 'A test clinic',
      });

      final entity = OrganizationModel.fromDoc(mockDoc);

      expect(entity.id, 'org1');
      expect(entity.name, 'Test Clinic');
      expect(entity.adminUid, 'admin123');
      expect(entity.bookingLinkSlug, 'test-clinic');
      expect(entity.isOpen, true);
      expect(entity.createdAt, testDate);
      expect(entity.qrCodeUrl, 'https://example.com/qr.png');
      expect(entity.address, '123 Main St');
      expect(entity.logoUrl, 'https://example.com/logo.png');
      expect(entity.description, 'A test clinic');
    });

    test('fromDoc handles null optional fields', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('org1');
      when(() => mockDoc.data()).thenReturn({
        'name': 'Test Clinic',
        'adminUid': 'admin123',
        'bookingLinkSlug': 'test-clinic',
        'isOpen': true,
        'createdAt': testTimestamp,
      });

      final entity = OrganizationModel.fromDoc(mockDoc);

      expect(entity.qrCodeUrl, isNull);
      expect(entity.address, isNull);
      expect(entity.logoUrl, isNull);
      expect(entity.description, isNull);
    });

    test('toMap converts OrganizationEntity to Firestore map', () {
      final entity = OrganizationEntity(
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

      final map = OrganizationModel.toMap(entity);

      expect(map['name'], 'Test Clinic');
      expect(map['adminUid'], 'admin123');
      expect(map['bookingLinkSlug'], 'test-clinic');
      expect(map['isOpen'], true);
      expect(map['createdAt'], testTimestamp);
      expect(map['qrCodeUrl'], 'https://example.com/qr.png');
      expect(map['address'], '123 Main St');
      expect(map['logoUrl'], 'https://example.com/logo.png');
      expect(map['description'], 'A test clinic');
    });

    test('round-trip conversion preserves data', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('org1');
      when(() => mockDoc.data()).thenReturn({
        'name': 'Test Clinic',
        'adminUid': 'admin123',
        'bookingLinkSlug': 'test-clinic',
        'isOpen': true,
        'createdAt': testTimestamp,
        'qrCodeUrl': 'https://example.com/qr.png',
        'address': '123 Main St',
        'logoUrl': 'https://example.com/logo.png',
        'description': 'A test clinic',
      });

      final entity = OrganizationModel.fromDoc(mockDoc);
      final map = OrganizationModel.toMap(entity);

      expect(map['name'], entity.name);
      expect(map['adminUid'], entity.adminUid);
      expect(map['bookingLinkSlug'], entity.bookingLinkSlug);
      expect(map['isOpen'], entity.isOpen);
      expect(map['createdAt'], Timestamp.fromDate(entity.createdAt));
      expect(map['qrCodeUrl'], entity.qrCodeUrl);
      expect(map['address'], entity.address);
      expect(map['logoUrl'], entity.logoUrl);
      expect(map['description'], entity.description);
    });
  });
}
