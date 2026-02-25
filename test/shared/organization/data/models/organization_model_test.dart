import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/shared/organization/data/models/organization_model.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('OrganizationModel', () {
    final testDate = DateTime(2026, 2, 21, 10, 0);
    final testTimestamp = Timestamp.fromDate(testDate);

    test('fromDoc converts Firestore document to OrganizationModel', () {
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

      final model = OrganizationModel.fromDoc(mockDoc);

      expect(model.id, 'org1');
      expect(model.name, 'Test Clinic');
      expect(model.adminUid, 'admin123');
      expect(model.bookingLinkSlug, 'test-clinic');
      expect(model.isOpen, true);
      expect(model.createdAt, testDate);
      expect(model.qrCodeUrl, 'https://example.com/qr.png');
      expect(model.address, '123 Main St');
      expect(model.logoUrl, 'https://example.com/logo.png');
      expect(model.description, 'A test clinic');
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

      final model = OrganizationModel.fromDoc(mockDoc);

      expect(model.qrCodeUrl, isNull);
      expect(model.address, isNull);
      expect(model.logoUrl, isNull);
      expect(model.description, isNull);
    });

    test('toMap converts OrganizationModel to Firestore map', () {
      final model = OrganizationModel(
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

      final map = model.toMap();

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

    test('toEntity converts OrganizationModel to OrganizationEntity', () {
      final model = OrganizationModel(
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

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.name, model.name);
      expect(entity.adminUid, model.adminUid);
      expect(entity.bookingLinkSlug, model.bookingLinkSlug);
      expect(entity.isOpen, model.isOpen);
      expect(entity.createdAt, model.createdAt);
      expect(entity.qrCodeUrl, model.qrCodeUrl);
      expect(entity.address, model.address);
      expect(entity.logoUrl, model.logoUrl);
      expect(entity.description, model.description);
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

      final model = OrganizationModel.fromDoc(mockDoc);
      final map = model.toMap();

      expect(map['name'], model.name);
      expect(map['adminUid'], model.adminUid);
      expect(map['bookingLinkSlug'], model.bookingLinkSlug);
      expect(map['isOpen'], model.isOpen);
      expect(map['createdAt'], Timestamp.fromDate(model.createdAt));
      expect(map['qrCodeUrl'], model.qrCodeUrl);
      expect(map['address'], model.address);
      expect(map['logoUrl'], model.logoUrl);
      expect(map['description'], model.description);
    });
  });
}
