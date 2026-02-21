import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/shared/organization/data/models/working_hours_model.dart';
import 'package:queue_ease/shared/organization/domain/entities/working_hours_entity.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('WorkingHoursModel', () {
    test('fromDoc converts Firestore document to WorkingHoursEntity', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('0'); // Monday
      when(() => mockDoc.data()).thenReturn({
        'isOpen': true,
        'openTime': '09:00',
        'closeTime': '17:00',
        'breakStart': '12:00',
        'breakEnd': '13:00',
      });

      final entity = WorkingHoursModel.fromDoc(mockDoc, orgId: 'org1');

      expect(entity.orgId, 'org1');
      expect(entity.dayOfWeek, 0);
      expect(entity.isOpen, true);
      expect(entity.openTime, '09:00');
      expect(entity.closeTime, '17:00');
      expect(entity.breakStart, '12:00');
      expect(entity.breakEnd, '13:00');
    });

    test('fromDoc handles null optional fields', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('0');
      when(
        () => mockDoc.data(),
      ).thenReturn({'isOpen': true, 'openTime': '09:00', 'closeTime': '17:00'});

      final entity = WorkingHoursModel.fromDoc(mockDoc, orgId: 'org1');

      expect(entity.breakStart, isNull);
      expect(entity.breakEnd, isNull);
    });

    test('fromDoc parses dayOfWeek from document ID', () {
      for (int i = 0; i < 7; i++) {
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn(i.toString());
        when(() => mockDoc.data()).thenReturn({
          'isOpen': true,
          'openTime': '09:00',
          'closeTime': '17:00',
        });

        final entity = WorkingHoursModel.fromDoc(mockDoc, orgId: 'org1');

        expect(entity.dayOfWeek, i);
      }
    });

    test('toMap converts WorkingHoursEntity to Firestore map', () {
      const entity = WorkingHoursEntity(
        orgId: 'org1',
        dayOfWeek: 0,
        isOpen: true,
        openTime: '09:00',
        closeTime: '17:00',
        breakStart: '12:00',
        breakEnd: '13:00',
      );

      final map = WorkingHoursModel.toMap(entity);

      expect(map['orgId'], 'org1');
      expect(map['isOpen'], true);
      expect(map['openTime'], '09:00');
      expect(map['closeTime'], '17:00');
      expect(map['breakStart'], '12:00');
      expect(map['breakEnd'], '13:00');
    });

    test('round-trip conversion preserves data', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('0');
      when(() => mockDoc.data()).thenReturn({
        'isOpen': true,
        'openTime': '09:00',
        'closeTime': '17:00',
        'breakStart': '12:00',
        'breakEnd': '13:00',
      });

      final entity = WorkingHoursModel.fromDoc(mockDoc, orgId: 'org1');
      final map = WorkingHoursModel.toMap(entity);

      expect(map['orgId'], entity.orgId);
      expect(map['isOpen'], entity.isOpen);
      expect(map['openTime'], entity.openTime);
      expect(map['closeTime'], entity.closeTime);
      expect(map['breakStart'], entity.breakStart);
      expect(map['breakEnd'], entity.breakEnd);
    });
  });
}
